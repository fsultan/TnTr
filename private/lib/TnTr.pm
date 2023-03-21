package TnTr;

use strict;
use base 'CGI::Application';

use CGI::Application::Plugin::AutoRunmode;
use CGI::Application::Plugin::Config::Simple;
use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);
use CGI::Application::Plugin::Forward;
use CGI::Application::Plugin::ValidateRM;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::Authorization;

#TODO is this plugin really being used?
#use CGI::Application::Plugin::HTMLPrototype;
#BEGIN { $ENV{'CAP_DEVPOPUP_EXEC'} = 1; }
use CGI::Application::Plugin::DevPopup;
use CGI::Application::Plugin::DevPopup::Timing;
use CGI::Application::Plugin::DevPopup::HTTPHeaders;

use TnTr::CAPDevPopUp_Extra;
use TnTrDB::Schema;

#use TnTr::Roles;
use List::Compare;

use Carp;
use DateTime;
use Data::Dumper;

my $app_base = $ENV{'TNTR_APP_BASE'};

################################################################################
# overide methods

sub cgiapp_init
{    # overrides        # called before setup() - keep in base class
    my ( $self, %params ) = @_;
    $self->config_file( $app_base . '/private/config/default.cfg' );
    $self->add_callback( 'load_tmpl', \&_set_default_t_params );

    my @dbh_config_args = $self->_dbh_config_args;

    #XXX C:A loads lazily, but do I need to disconnect later?
    $self->dbh_config(@dbh_config_args);

    $self->session_config(
        CGI_SESSION_OPTIONS => [
            $self->config_param('cgi_session_dsn'), $self->query,
            { Handle => $self->dbh }
        ],
        DEFAULT_EXPIRY => $self->config_param('cgi_session_expiry'),
        COOKIE_PARAMS  => {

            #            -domain     => $self->config_param('cookie_domain'),
            -expires => $self->config_param('cookie_expiry'),
            -path    => $self->config_param('cookie_path'),
        },
        SEND_COOKIE => 1,
    );
    $self->authen->config(
        DRIVER => [
            'DBI',
            DBH         => $self->dbh,
            TABLE       => [ 'users', 'domains' ],
            JOIN_ON     => 'users.domain = domains.id',
            CONSTRAINTS => {
                'users.username' => '__CREDENTIAL_1__',
##				'MD5_base64:u_password'	=> '__CREDENTIAL_2__' # 22 bytes
                'SHA1_base64:password' => '__CREDENTIAL_2__',    # 27 bytes
                'domains.name'         => '__CREDENTIAL_3__',
            },
        ],
        CREDENTIALS =>
          [ 'authen_username', 'authen_password', 'authen_domain' ],
        STORE          => 'Session',
        LOGOUT_RUNMODE => '_logout',
        LOGIN_SESSION_TIMEOUT =>
          { IDLE_FOR => $self->config_param('authen_idle_expiry') },
        RENDER_LOGIN => \&login_form,

        #        LOGIN_RUNMODE => 'login',
##        LOGIN_FORM => {
##            TITLE			=> 'Sign In'
##            ,COMMENT		=> 'Please enter your username and password'
##            ,REMEMBERUSER_OPTION=> 0
##            ,REGISTER_URL	=> 'user.cgi'
##            ,REGISTER_LABEL=> 'Create an account'
##            ,FORGOTPASSWORD_URL => 'http://...'
##            ,BASE_COLOUR => '#D0D0C4'
##        }
    );

    $self->param('dfv_defaults')
      || $self->param(
        'dfv_defaults',
        {
            missing_optional_valid => 1,
            filters                => 'trim',
            msgs                   => {
                any_errors => 'dfv_errors',
                prefix     => 'err_',
                invalid    => '* Invalid',
                missing    => '* Missing',

                #    format => '<span class="dfv-errors">%s</span>',
                format => '%s',
            },
            constraint_methods => {
                name => qr/^[a-zA-Z0-9_' \.-]{1,32}$/
                ,    #' - . spaces and letters are valid
                description => qr/^[a-zA-Z0-9' \.-]{1,32}$/,
            },
        }
      );

}

sub _dbh_config_args {
    my $self         = shift;
    my %db_supported = (
        SQLite => 1,
        mysql  => 1,
    );
    my @dbh_config_args;

    my $db_type = $self->config_param('dbi');

    if ( !$db_supported{$db_type} ) {
        croak 'Database type in config is not supported!';
    }
    my $dsn = 'dbi:' . $db_type;

    if ( $db_type == 'SQLite' ) {
        my $db_file = $self->config_param('dbn');
        if ( !-e $db_file ) {
            croak 'SQLite database file not found : ', $db_file;
        }
        $dsn .= ':dbname=' . $db_file;
        push @dbh_config_args, ( $dsn, '', '' );
        return @dbh_config_args;
    }

    if ( $db_type == 'mysql' ) {
        my $db_host = $self->config_param('db_host');
    }
}

sub cgiapp_get_query {    # overrides
    require CGI::Simple;    # uploads are disabled by default in CGI::Simple
    CGI::Simple->new();
}

#sub teardown {				# overrides
#	my $self = shift;
#	$self->session->flush if $self->session_loaded;
#		# required, auto-flushing may not be reliable. See CGI::Session doc
#}

################################################################################
# callbacks

sub _set_default_t_params {
    my ( $self, undef, $tmpl_params, undef ) = @_;

    if ( $self->param('skip_set_default_t_params') ) {
        return;
    }

    #my $self = shift;
    $tmpl_params->{default_css_url} = $self->config_param('default_css_url');
    $tmpl_params->{site_base_url}   = $self->config_param('site_base_url');
    $tmpl_params->{app_base_url}    = $self->config_param('app_base_url');

    my @javascript_links;
    my %jscripts = (
        jquery => {
            site_base_url => $self->config_param('site_base_url'),
            js_url        => $self->config_param('jquery_js'),
        },
        jq_validate => {
            site_base_url => $self->config_param('site_base_url'),
            js_url        => '/javascript/jquery.validate.js',
        },
        utilities => {
            site_base_url => $self->config_param('site_base_url'),
            js_url        => '/javascript/utilities.js',
        }
    );
    foreach my $key ( keys %jscripts ) {
        push @javascript_links, $jscripts{$key};
    }

    $tmpl_params->{include_javascripts} = \@javascript_links;

    #set and clear flash_msg (home-brew)
    $tmpl_params->{flash_msg} = $self->session->param('flash_msg');
    warn "SETUP and CLEAR FLASH: ", $self->session->param('flash_msg');
    $self->session->param( flash_msg => '' );

    #    my $cookie = $self->query->cookie( -name      => 'xsessionID',
    #                -value     => 'xyzzy',
    #                -expires   => '+1h',
    #                -path      => '/',
    #                -secure    => 1
    #                );
    #    $self->header_add(-cookie => [$cookie]);
    $tmpl_params->{authen_username} = $self->authen->username;
}

################################################################################
# run modes

sub report_error : Runmode {
    my $self = shift;

    #TODO report a AJAX compatible page? and for others?
    # can I check the htpp headers at this point?
    #TODO option to return to orignal page?
    my $t = $self->load_tmpl('error.tpl');
    $t->param( report_error => $self->param('report_error') );
    $t->output;
}

################################################################################
# error handling

sub report_db_obj_error {
    my $self         = shift;
    my $db_obj_error = shift;
    my $task_was     = shift;

    #TODO replace warn with log?
    warn 'DB ERROR: ', $db_obj_error;
    $self->param( 'report_error', "Unable to $task_was!" );
    return $self->forward('report_error');
}

################################################################################
# authorization
# rights
# validations

# user_has_rights_for should really never be called directly from runmodes!!
# each model/module should have it own sub that calls this with its name as app_name
# and extra args (for future)

sub authen_user_rs {
    my $self = shift;
    return $self->{schema}->resultset('Users')
      ->find( { username => $self->authen->username }, );

#  ->find( { username => $self->authen->username }, { columns => [qw/id domain/], }, );
}

#  Login & Logout -----------------------------------------

sub _login {
    my $self = shift;

    #TODO set login sucess destination to refering page or default!
    $self->query->param(
        destination => $self->config_param('app_base_url') . '/default' );
    $self->login_form;
}

sub login_form {
    my $self = shift;
    my $q    = $self->query;
    my $a    = $self->authen;
    my $t    = $self->load_tmpl('auth/login_form.tpl');
    $t->param( destination => $q->param('destination') || $q->self_url );
    if ( !$a->is_authenticated && $a->login_attempts ) {
        $t->param( login_error   => 'Invalid username or password' );
        $t->param( login_attempt => $a->login_attempts );
    }
    $t->output;
}

sub _logout {
    my $self = shift;
    $self->authen->logout();
    my $t = $self->load_tmpl('error.tpl');
    $t->param( 'report_error', 'You have been logged out!' );
    $t->output;
}

################################################################################
# time related

sub time_update_allowable {
    my $self      = shift;
    my $time_id   = shift;
    my $auth_user = shift;

    #my $time_id = shift;
    #TODO fill in, remove override
    my $_is_valid = 0;
    $_is_valid = 1;    #temporary override!!
    return $_is_valid;
}

sub _is_valid_month {
    my $self  = shift;
    my $month = shift;
    if ( ( $month >= 1 ) && ( $month <= 12 ) ) {
        return 1;
    }
    return 0;
}

sub _is_valid_year {
    my $self = shift;
    my $year = shift;

    my $dt = DateTime->now;

    #TODO consider the timezone? could be next year somewhere ..
    #set year upper limit to current year + 1.
    my $year_upper_limit = $dt->year + 1;

    if ( ( $year >= 1977 ) && ( $year <= $year_upper_limit ) ) {
        return 1;
    }
    return 0;
}

# misc common utilities ------------------

sub _load_schema {
    my $self = shift;
    if ( !$self->{schema} ) {
        my $schema = TnTrDB::Schema->connect( $self->_dbh_config_args );
        $self->{schema} = $schema;
        $self->{schema}->storage->debug(1);
    }
}

sub redirect {
    my $self     = shift;
    my $location = shift;
    $self->header_add( -location => $location );
    $self->header_type('redirect');
    $self->param( redirect => 1 );
}

sub tr_time_human {
    my $self = shift;
    my $time = shift;
    if ( !$time > 0 ) {
        return 0;
    }
    return ( scalar localtime $time );
}

sub tr_time_sepoch {
    my $self                = shift;
    my $_seconds_from_epoch = shift;

    #    warn "seconds $_seconds_from_epoch";
    #    if (! $_seconds_from_epoch > 0 ) {
    #    	return 0;
    #    }
    #	my $dt = DateTime->from_epoch( epoch => $_seconds_from_epoch);
    #    return $dt->iso8601;
    if ( !$_seconds_from_epoch > 0 ) {
        return 0;
    }
    return ( scalar localtime $_seconds_from_epoch );
}

sub is_user_record_creator {
    my $self      = shift;
    my $auth_user = shift;
    my $app       = shift;
    my $app_id    = shift;
    warn "checking if user is record creator!";
    my $rs = $self->{schema}->resultset($app)->search(
        {
            id         => $app_id,
            creator_id => $auth_user->id
        },
        { columns => [qw/id/] }
    );

    if ( defined $rs && $rs->first ) {
        warn "user is record creator!";
        return 1;
    }
    return 0;
}

## Roles

sub is_user_task_user {
    my $self      = shift;
    my $auth_user = shift;

    return 0;
}

sub is_user_projectadmin {
    my $self      = shift;
    my $auth_user = shift;

	my $roles = $self->{schema}->resultset('Roles')->find( 
    	{ 'user.username' => $self->authen->username,
    		'name' => 'projectadmin',
   			'level' => '1',
      	},
      	{ join => { 'user_role' => 'user',},
      	  columns => [qw/id/],
      	},
	);
	if (defined $roles) {
		return 1;
	}
    return 0;
}

sub is_user_projectadmin_in_client_group {
    my $self      = shift;
    my $auth_user = shift;
    my $client_id = shift;

    my $rs = $self->{schema}->resultset('Clients')->find($client_id)->groups;
}

sub is_user_clientadmin {
    my $self      = shift;
    my $auth_user = shift;

	my $roles = $self->{schema}->resultset('Roles')->find( 
    	{ 'user.username' => $self->authen->username,
    		'name' => 'clientadmin',
   			'level' => '1',
      	},
      	{ join => { 'user_role' => 'user',},
      	  columns => [qw/id/],
      	},
	);
	if (defined $roles) {
		return 1;
	}
    return 0;
}

sub is_user_siteadmin {
    my $self      = shift;
    my $auth_user = shift;

	my $roles = $self->{schema}->resultset('Roles')->find( 
    	{ 'user.username' => $self->authen->username,
    		'name' => 'siteadmin',
   			'level' => '1',
      	},
      	{ join => { 'user_role' => 'user',},
      	  columns => [qw/id/],
      	},
	);
	if (defined $roles) {
		return 1;
	}
    return 0;
}

sub is_user_superuser {
    my $self      = shift;
    my $auth_user = shift;

	my $roles = $self->{schema}->resultset('Roles')->find( 
    	{ 'user.username' => $self->authen->username,
    		'name' => 'superuser',
   			'level' => '1',
      	},
      	{ join => { 'user_role' => 'user',},
      	  columns => [qw/id/],
      	},
	);
	if (defined $roles) {
		return 1;
	}
    return 0;
}

#
sub is_user_clientadmin_in_client_group {
    my $self      = shift;
    my $auth_user = shift;
    my $client_id = shift;

# this logic seems to work!
    my $client_groups_rs = $self->{schema}->resultset('Clients')->find($client_id)->groups;
    my $result = $client_groups_rs->search(
        { 'user.id' => $auth_user->id, 'role.level' => '1', 'role.name' => 'clientadmin',},
        {
            join => { 'user_group' => { 'user' => { 'user_role' => 'role' } } },
       #     '+select' => ['role.level'],
       #     '+as'     => ['role_level']
       		columns => [qw/id/],		#this id is the group id of the client!
        }
    )->first;

    if ( defined $result && $result->id > 0 ) {
        return 1;
    }
    return 0;
}

sub is_usergroup_project_admin {
    my $self       = shift;
    my $auth_user  = shift;
    my $project_id = shift;

    return 0;
}

###########  OLD RIGHTS STUFF ##############################

sub group_ids_for_app {
    my $self     = shift;
    my $app_name = shift;
    my $app_id   = shift;

    my $rs = $self->{schema}->resultset($app_name)->find($app_id)->groups;
    if ( !defined $rs ) {
        return undef;
    }
    my @group_ids;
    while ( my $group_rs = $rs->next ) {
        push( @group_ids, $group_rs->id );
        warn "found group ", $group_rs->id;
    }
    if (wantarray) {
        return @group_ids;
    }
    else {
        return \@group_ids;
    }
}


#  Checks and Balances -----------------------------------------

sub client_id_is_in_auth_users_domain {
    my $self      = shift;
    my $client_id = shift;
    my $auth_user = shift;

    warn "checking is_client_in_auth_user_domain";

    #just in case we don't get the auth user in ..
    if ( !ref $auth_user ) {
        $auth_user = $self->authen_user_rs;
    }

    #constraint only restricts client list by user' domain.
    my $clients_constraint =
      [ -and => [ { domain => $auth_user->domain->id }, { id => $client_id } ],
      ];

    my $result =
      $self->{schema}->resultset('Clients')
      ->search( $clients_constraint, { columns => [qw/id domain/], }, );
    if ( defined $result->first ) {
        return 1;
    }
    return 0;
}

sub group_id_is_in_auth_users_domain {
    my $self      = shift;
    my $group_id  = shift;
    my $auth_user = shift;

    #just in case we don't get the auth user in ..
    if ( !ref $auth_user ) {
        $auth_user = $self->authen_user_rs;
    }

    #constraint only restricts client list by user' domain.
    my $group_constraints =
      [ -and => [ { domain => $auth_user->domain->id }, { id => $group_id } ],
      ];

    my $result =
      $self->{schema}->resultset('Groups')
      ->search_rs( $group_constraints, { columns => [qw/id domain/], }, );
    if ( defined $result->first ) {
        return 1;
    }
    return 0;
}

sub user_id_is_in_auth_users_domain {
    my $self      = shift;
    my $user_id   = shift;
    my $auth_user = shift;

    #just in case we don't get the auth user in ..
    if ( !ref $auth_user ) {
        $auth_user = $self->authen_user_rs;
    }

    #constraint only restricts client list by user' domain.
    my $users_constraints =
      [ -and => [ { domain => $auth_user->domain->id }, { id => $user_id } ], ];

    my $result =
      $self->{schema}->resultset('Users')
      ->search_rs( $users_constraints, { columns => [qw/id domain/], }, );
    if ( defined $result->first ) {
        return 1;
    }
    return 0;
}

sub project_id_is_in_auth_users_domain {
    my $self       = shift;
    my $project_id = shift;
    my $auth_user  = shift;

    #just in case we don't get the auth user in ..
    if ( !ref $auth_user ) {
        $auth_user = $self->authen_user_rs;
    }

   #constraint only restricts client list by user' domain.
   #my $users_constraints =
   #  [ -and => [{ domain => $auth_user->domain->id }, { id => $project_id}], ];

    my $result = $self->{schema}->resultset('Projects')->search_rs(
        {
            -and =>
              [ { domain => $auth_user->domain->id }, { id => $project_id } ]
        },
        {
            join    => { 'clients' => 'domains' },
            columns => [qw/id domain/],
        },
    );
    if ( defined $result->first ) {
        return 1;
    }
    return 0;
}

sub task_id_is_in_auth_users_domain {
    my $self      = shift;
    my $task_id   = shift;
    my $auth_user = shift;

    #just in case we don't get the auth user in ..
    if ( !ref $auth_user ) {
        $auth_user = $self->authen_user_rs;
    }

    return 0;
}

sub user_owns_app {
    my $self     = shift;
    my $user_id  = shift;
    my $app_name = shift;
    my $app_id   = shift;
    my $rs       = $self->{schema}->resultset($app_name)->search(
        {
            id         => $app_id,
            creator_id => $user_id,
        },
        { columns => [qw/id/], },
    );
    if ( defined $rs->first ) {
        return 1;
    }
    return 0;
}

#

sub valid_app {

    #should we return a resultset for the valid owner???
    my $self     = shift;
    my $app_name = $self->valid_app_name(shift);
    my $app_id   = $self->valid_app_id(shift);

    if ( $app_id == 0 ) {
        return 1;
    }
    if ( defined $app_name && defined $app_id ) {

        #check if the app exist in db
        my $app = $self->{schema}->resultset($app_name)->find($app_id);
        if ( defined $app ) {
            return 1;
        }
    }
    return undef;
}

sub valid_app_name {
    my $self       = shift;
    my $arg        = shift;
    my %valid_apps = (
        tasks    => 'Tasks',
        projects => 'Projects',
        clients  => 'Clients',
        users    => 'Users',

        #        groups	=> 'Groups',
    );
    $arg =~ /(^[a-zA-Z]+)$/;
    my $app_name_arg = lc($1);
    return ( $valid_apps{$app_name_arg} || undef );
}

sub valid_app_id {
    my $self   = shift;
    my $app_id = shift;
    my $valid_app_id =
        ( $app_id eq 'default' ) ? 0
      : ( $app_id =~ /^\d+$/ ) ? $app_id
      :                          undef;
    return $valid_app_id;
}

# general apps

################################################################################
# client related

sub clients_rs_in_user_domain {
    my $self      = shift;
    my $auth_user = shift;

    #this constraint restricts clients returned to those is auth_user's domain
    my $clients_constraint = [ { domain => $auth_user->domain->id } ];
    my $clients_rs =
      $self->{schema}->resultset('Clients')
      ->search( $clients_constraint, { columns => [qw/id name/], }, );
    if ( !defined $clients_rs ) {
        $self->param( 'report_error', 'Could not find any suitable Clients!' );
        return $self->forward('report_error');
    }
    return $clients_rs;
}

sub clients_for_user_rs {
	my $self      = shift;
    my $auth_user = shift;
    
    if ( $self->is_user_superuser($auth_user) ) {
        return $self->clients_rs_in_user_domain($auth_user);
    }
    
}

sub clients_select_hash_list {
    my $self                = shift;
    my $clients_rs          = shift;
    my $current_selected_id = shift;

    my @client_list;
    while ( my $client = $clients_rs->next ) {
        my %client_option = (
            client_id   => $client->id,
            client_name => $client->name,
        );
        if ( $client->id == $current_selected_id ) {
            $client_option{'selected'} = 1;
        }
        push @client_list, \%client_option;
    }
    return \@client_list;
}

sub client_update_allowable {
    my $self      = shift;
    my $client_id = shift;
    my $auth_user = shift;

    my $_is_valid = 0;
    $_is_valid =
      $self->is_client_in_auth_user_domain( $client_id, $auth_user ) ? 1 : 0;

    #TODO add more checks based on user/group rights!
    return $_is_valid;
}


################################################################################
# project related

sub projects_for_client_rs {
    my $self      = shift;
    my $auth_user = shift;
    my $client_id = shift;

    # client_id in $client_id should have already been sanitized!
    my $projects_constraint = [ { client => $client_id } ];
    my $projects_rs =
      $self->{schema}->resultset('Projects')
      ->search( $projects_constraint, { columns => [qw/id name/], }, );
    if ( !defined $projects_rs ) {
        $self->param( 'report_error', 'Could not find any suitable Clients!' );
        return $self->forward('report_error');
    }
    return $projects_rs;
}

sub projects_select_hash_list {
    my $self                = shift;
    my $projects_rs         = shift;
    my $current_selected_id = shift;

    my @project_list;
    while ( my $project = $projects_rs->next ) {
        my %project_option = (
            project_id   => $project->id,
            project_name => $project->name,
        );
        if ( $project->id == $current_selected_id ) {
            $project_option{'selected'} = 1;
        }
        push @project_list, \%project_option;
    }
    return \@project_list;
}

################################################################################
# user related

sub users_for_domain_rs {
    my $self = shift;
    my $user = shift;

    my $users_constraint = [ { domain => $user->domain->id } ];
    my $users_rs =
      $self->{schema}->resultset('Users')
      ->search( $users_constraint, { columns => [qw/id name/], }, );
    if ( !defined $users_rs ) {
        $self->param( 'report_error', 'Could not find any suitable Users!' );
        return $self->forward('report_error');
    }
    return $users_rs;
}

sub users_select_hash_list {
    my $self                = shift;
    my $users_rs            = shift;
    my $current_selected_id = shift;

    my @user_list;
    while ( my $user = $users_rs->next ) {
        my %user_option = (
            user_id   => $user->id,
            user_name => $user->name,
        );
        if ( $user->id == $current_selected_id ) {
            $user_option{'selected'} = 1;
        }
        push @user_list, \%user_option;
    }
    return \@user_list;
}

sub user_update_allowable {
    my $self      = shift;
    my $user_id   = shift;
    my $auth_user = shift;

#$_is_valid = ($self->is_user_in_auth_user_domain($user_id,$auth_user) == 0) ? 1 : 0;
#$self->is_user_in_auth_user_domain($user_id,$auth_user) == 0 ? 1 : ($_is_valid = 0);
    if ( $self->userid_is_in_authuser_domain( $user_id, $auth_user ) == 1 ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub userid_is_in_authuser_domain {
	my $self = shift;
	my $user_id = shift;
	my $auth_user = shift;
	
	my $userid_domainid = $self->{schema}->resultset('Users')->find( { 'id' => $user_id,},)->domain->id;
	
	if ( $userid_domainid == $auth_user->domain->id ) {
		return 1;
	}
	return 0;
}
################################################################################
# group related

sub groups_for_domain_rs {
    my $self = shift;
    my $user = shift;

    my $users_constraint = [ { domain => $user->domain->id } ];
    my $groups_rs =
      $self->{schema}->resultset('Groups')
      ->search( $users_constraint, { columns => [qw/id name/], }, );
    if ( !defined $groups_rs ) {
        $self->param( 'report_error', 'Could not find any suitable Groups!' );
        return $self->forward('report_error');
    }
    return $groups_rs;
}

sub groups_select_list {
    my $self                = shift;
    my $groups_rs           = shift;
    my $current_selected_id = shift;

    my @groups_list;
    while ( my $group = $groups_rs->next ) {
        my %group_option = (
            group_id   => $group->id,
            group_name => $group->name,
        );
        if ( $group->id == $current_selected_id ) {
            $group_option{'selected'} = 1;
        }
        push @groups_list, \%group_option;
    }
    return \@groups_list;
}

#TODO change this group_update_allowable thing
sub group_update_allowable {
    my $self      = shift;
    my $group_id  = shift;
    my $auth_user = shift;

#TODO add more checks based on user/group rights!
#$_is_valid = ($self->is_user_in_auth_user_domain($user_id,$auth_user) == 0) ? 1 : 0;
#$self->is_user_in_auth_user_domain($user_id,$auth_user) == 0 ? 1 : ($_is_valid = 0);
    if ( $self->is_group_in_auth_user_domain( $group_id, $auth_user ) == 1 ) {
        return 1;
    }
    else {
        return 0;
    }
}

################################################################################
# userrights related

sub rightsapps_rs {
    my $self = shift;

    #my $user = shift;

    my $rightsapps_rs = $self->{schema}->resultset('RightApps')->search();
    if ( !defined $rightsapps_rs ) {
        $self->param( 'report_error',
            'Could not find any suitable RightApps!' );
        return $self->forward('report_error');
    }
    return $rightsapps_rs;
}

sub rightsapps_select_hash_list {
    my $self                = shift;
    my $rightsapps_rs       = shift;
    my $current_selected_id = shift;

    my @rightsapp_list;
    while ( my $rightsapp = $rightsapps_rs->next ) {
        my %rightsapp_option = (
            app_id   => $rightsapp->id,
            app_name => $rightsapp->name,
        );
        if ( $rightsapp->id == $current_selected_id ) {
            $rightsapp_option{'selected'} = 1;
        }
        push @rightsapp_list, \%rightsapp_option;
    }
    return \@rightsapp_list;
}

sub rightsapps_form_select_html : Runmode {
    my $self = shift;

    #my $id_p = $self->query->param('project');

    # set this before loading the template that doesn't have general var tags
    $self->param( 'skip_set_default_t_params', 1 );
    my $t = $self->load_tmpl('rightsapps/create_rightsapps_select.tpl');

    $self->_load_schema;

    my $username = $self->authen->username;
    my $auth_user =
      $self->{schema}->resultset('Users')
      ->find( { username => $username }, { columns => [qw/domain/], }, );

    #validate  for auth_user

    #my $project_id = $id_p;  #change this!!
    #generate list of tasks
    $t->param( task_list =>
          $self->rightsapps_select_hash_list( $self->rightsapps_rs(), undef ),
    );
    $t->output;
}

################################################################################
# task related

sub tasks_for_project_rs {
    my $self       = shift;
    my $auth_user  = shift;
    my $project_id = shift;

    # project_id in $project_id should have already been sanitized!
    my $tasks_constraint = [ { project => $project_id } ];
    my $tasks_rs =
      $self->{schema}->resultset('Tasks')
      ->search( $tasks_constraint, { columns => [qw/id name/], }, );
    if ( !defined $tasks_rs ) {
        $self->param( 'report_error', 'Could not find any suitable Tasks!' );
        return $self->forward('report_error');
    }
    return $tasks_rs;
}

sub tasks_select_hash_list {
    my $self                = shift;
    my $tasks_rs            = shift;
    my $current_selected_id = shift;

    my @task_list;
    while ( my $task = $tasks_rs->next ) {
        my %task_option = (
            task_id   => $task->id,
            task_name => $task->name,
        );
        if ( $task->id == $current_selected_id ) {
            $task_option{'selected'} = 1;
        }
        push @task_list, \%task_option;
    }
    return \@task_list;
}

sub task_update_allowable {
    my $self      = shift;
    my $task_id   = shift;
    my $auth_user = shift;
    my $_is_valid = 0;

 #TODO replace with suitable
 #TODO add more checks based on user/group rights!
 # $_is_valid = $self->is_task_in_auth_user_domain($task_id,$auth_user) ? 1 : 0;
    $_is_valid = 1;    #temporary override!!
    return $_is_valid;
}

#--
1;
