package TnTr::Projects;

use strict;
use base 'TnTr';

sub setup {    # overrides     # called after cgiapp_init()
    my $self = shift;
#    $self->authen->protected_runmodes(':all');
}

sub may_user_create_project {
	my $self = shift;
	my $auth_user = shift;
	my $client_id = shift;
	
	#check client_id ?
	if ($self->is_user_superuser || 
		$self->is_user_at_least_project_admin_in_client_group($auth_user, $client_id) ||
		$self->is_user_record_creator($auth_user,'Clients',$client_id)){
			return 1;
		}
		
	$self->is_usergroup_at_least_project_admin($auth_user);
	 
	 return 0;
}

sub may_user_edit_project {
	my $self = shift;
	my $auth_user = shift;
	my $project_id = shift;
	
	my @args = @_;
	
    #yes if user is superuser, site-admin, or creator, or project-admin in group  

	if ($self->is_user_superuser || 
		$self->is_user_site_admin($auth_user) ||
		$self->is_user_record_creator($auth_user,'Projects', $project_id) ||
		$self->is_user_projectadmin_in_project_group($auth_user,$project_id) ){
			return 1;
		}
	return 0;
}

sub may_user_delete_project {
	my $self = shift;
	my $auth_user = shift;
	my $project_id = shift;
	
	my @args = @_;
	
    #yes if user is superuser, site-admin, or creator, 

	if ($self->is_user_superuser || 
		$self->is_user_site_admin($auth_user) ||
		$self->is_user_record_creator($auth_user,'Projects', $project_id)){
			return 1;
		}
	return 0;
}

#sub get_user_rights_for {
#    my $self = shift;
#    my $auth_user = shift;
#    my $right = shift;
#    my $app_id = shift;
#
#    my @args = @_;
#    my $app_name = 'Projects';
#    
#    $self->get_user_app_rights_for( $auth_user, $right, $app_name, $app_id, @args );
#}
#sub user_rights_create_project_for_client {
#	my $self = shift;
#	my $auth_user = shift;
#	my $client_id = shift;
#    my @args = @_;
#    my $app_name = 'Projects';
#    
#    #just in case we don't get the auth user in .. 
#    if (! ref $auth_user){
#    	$auth_user = $self->authen_user_rs;
#    }
#
#    # no user is domain owner, no need to check that here
#    if ($client_id > 1){
#    	! $self->client_id_is_in_auth_users_domain($client_id) && return 0;
#    }
#    if ($self->user_rights_create_child($auth_user,'Clients',[0, $client_id])){
#    	warn "allowed: user_rights_domain_create_child";
#    	return 1;
#    }
#    return 0;
#}
#
#sub user_rights_edit_project {
#	my $self = shift;
#	my $auth_user = shift;
#	my $app_id = shift;
#	
#	my @args = @_;
#    my $app_name = 'Projects';
#	return $self->user_rights_edit_app($auth_user,$app_name, $app_id);
#    if ( $self->project_id_is_in_auth_users_domain($app_id) && $self->user_rights_edit_app($auth_user,$app_name, $app_id)) {
#    	return 1;
#    }
#	return 0;
#}
#
#sub user_rights_delete_project {
#	my $self = shift;
#	my $auth_user = shift;
#	my $app_id = shift;
#	
#	my @args = @_;
#    my $app_name = 'Projects';
#
#    if ( $self->project_id_is_in_auth_users_domain($app_id) && $self->user_rights_delete_app($auth_user,$app_name, $app_id)) {
#    	return 1;
#    }
#	return 0;
#}

sub default : StartRunmode {
    my $self = shift;

    #my $q = $self->query;
    my $t = $self->load_tmpl('projects/default.tpl');
    my $total_projects =
      $self->dbh->selectrow_array('select count(*) from projects');
    $t->param( total_projects => $total_projects );
    return $t->output;
}

sub create_display : Runmode {
    my $self = shift;
    my $errs = shift;

    #TODO check if user is allowed to create project.


    $self->_load_schema;

    my $auth_user = $self->authen_user_rs;

    #check if user is allowed to create a client for their domain
    if ( ! $self->may_user_create_project($auth_user) ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    }
    
    my $t = $self->load_tmpl('projects/edit.tpl');
    
    #TODO show only those with child create perms ... ??
        
    $t->param(
        client_list => $self->clients_select_hash_list(
            $self->clients_for_user_rs($auth_user), undef
        ),
    );
    $errs && $t->param($errs);
    $t->output;
}

sub create_process : Runmode {
    my $self = shift;

    #TODO check if user is allowed to create project.
    my $dfv_results = $self->check_rm( 'create_display', '_create_dfv_rules' )
      || return $self->check_rm_error_page;

    $self->_load_schema();

    my $auth_user = $self->authen_user_rs;
    
    #check if user is allowed to create a client for their domain
    if ( ! $self->may_user_create_project($auth_user, $dfv_results->valid('client')) ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    }

    my $project = $self->{schema}->resultset('Projects')->create(
        {
            name        => $dfv_results->valid('name'),
            creator_id		=> $auth_user->id,
            description => $dfv_results->valid('description'),
            client      => $dfv_results->valid('client'),
        }
    );

    #TODO check if it was _really_ created!!
    if ( !$project ) {
        $self->report_db_obj_error( $project->db_obj_error, 'Create' );
    }

    $self->session->param( flash_msg => 'Project created!' );
    $self->redirect( $self->config_param('app_base_url')
          . '/projects/show/'
          . $project->id );
}

sub edit_display : Runmode {
    my $self = shift;
    my $errs = shift;
    my $id_p = $self->param('id');

    #TODO check if user is allowed to update project.
    my $search_id         = undef;
    my $search_constraint = undef;

    #if args starts with a number set the constraint
    if ( $id_p =~ /^(\d+)/ ) {
        $search_id = $1;
        $search_constraint = [ { id => $search_id }, ];
    }
    else {

        # nothing passed in to constrain search, oops!
        $self->param( 'report_error', 'Edit requires an id' );
        return $self->forward('report_error');
    }

    $self->_load_schema();

    my $auth_user = $self->authen_user_rs;
    
    #check if user is allowed to edit this or any client!
    if ( ! $self->may_user_edit_project($auth_user, $search_id) ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    } 
    
    my $t = $self->load_tmpl('projects/edit.tpl');

    my $project_rs =
      $self->{schema}->resultset('Projects')
      ->search( $search_constraint,
        { columns => [qw/id name description client/], },
      );

    my $project = $project_rs->first;
    if ( !defined $project ) {
        $self->param( 'report_error',
            'The project you are trying to edit does not exists!' );
        return $self->forward('report_error');
    }

    #allowed client choices are those within the authen users' domain.

#load form with values from db.
#my $clients_rs = $self->{schema}->resultset('Clients')->search( [{ domain => $search_id },], { columns => [qw/id name/], }, );

    $t->param(
        name        => $project->name,
        description => $project->description,

#client_list => $self->clients_select_list($self->clients_for_user_rs($user,$project->client->id)),
        client_list => $self->clients_select_hash_list(
            $self->clients_for_user_rs($auth_user),
            $project->client->id
        ),
    );
    $errs && $t->param($errs);
    $t->output;
}

sub edit_process : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');

    #TODO check if user is allowed to update project.
    my $dfv_results = $self->check_rm( 'edit_display', '_edit_dfv_rules' )
      || return $self->check_rm_error_page;

    my $search_id         = undef;
    my $search_constraint = undef;

    $self->_load_schema();

    if ( $id_p =~ /^(\d+)/ ) {
        $search_id = $1;
        $search_constraint = [ { id => $search_id }, ];
    }
    else {
        # nothing passed in to constrain search, oops!
        $self->param( 'report_error', 'Update requires an id' );
        return $self->forward('report_error');
    }

    my $auth_user = $self->authen_user_rs;

    #check if user is allowed to edit this or any client!
    if ( ! $self->may_user_edit_project($auth_user, $search_id) ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    } 

    my $rs =
      $self->{schema}->resultset('Projects')
      ->search( $search_constraint,
        { columns => [qw/id name description client/], },
      );
    my $result = $rs->first;
    if ( !defined $result ) {
        $self->param( 'report_error', 'No Results!' );
        return $self->forward('report_error');
    }

    
    my $update_h = {

        #id => $result->id,
        name        => $dfv_results->valid('name'),
        description => $dfv_results->valid('description'),
        client      => $dfv_results->valid('client'),
    };
    $result->update($update_h)
      || $self->db_obj_error( $result->db_obj_error, 'Update' );
    $self->session->param( flash_msg => 'Project updated!' );
    $self->redirect(
        $self->config_param('app_base_url') . '/projects/show/' . $id_p );
}

sub _create_dfv_rules {
    my $self  = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name description client)];
    $rules->{constraint_methods}->{client} =
      sub { my $val = pop; return ( $val > 0 ) };
    return $rules;
}

sub _edit_dfv_rules {
    my $self  = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name description client)];
    $rules->{constraint_methods}->{client} =
      sub { my $val = pop; return ( $val > 0 ) };
    return $rules;
}

sub delete : Runmode {
    my $self = shift;

    #TODO check if user is allowed to delete project.
}

sub list : Runmode {
    my $self = shift;

    #my $args = $self->param('dispatch_url_remainder');
    #TODO check if user is allowed to list project.
    # um,, cant we assume the user can list?
    my $t = $self->load_tmpl('projects/list.tpl');

    $self->_load_schema();


    my $auth_user = $self->authen_user_rs;

    my $projects = $self->{schema}->resultset('Projects')->search(
        { 'domain.id' => $auth_user->domain->id, },
        { join        => { client => 'domain', }, },
    );

    my @project_list;
    foreach my $project ( $projects->all ) {
        my $rh = {
            id           => $project->id,
            name         => $project->name,
            description  => $project->description,
            client       => $project->client->name,
            create_time  => $self->tr_time_sepoch($project->create_time),
            app_base_url => $self->config_param('app_base_url'),
        };
        push @project_list, $rh;
    }
    $t->param( project_list => \@project_list );
    return $t->output;
}

sub show : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');

    #TODO check if user is allowed to list project.
    my $search_id         = undef;
    my $search_constraint = undef;

    #if args starts with a number set the constraint
    if ( $id_p =~ /^(\d+)/ ) {
        $search_id = $1;
        $search_constraint = [ { id => $search_id }, ];
    }
    else {

        # nothing passed in to constrain search, oops!
        $self->param( 'report_error', 'Show requires an id' );
        return $self->forward('report_error');
    }

    my $t = $self->load_tmpl('projects/show.tpl');

    $self->_load_schema();
    my $projects = $self->{schema}->resultset('Projects')->search(
        $search_constraint,
        {
            columns => [
                qw/id name description client create_time update_time close_time/
            ],
        },
    );

    my $project = $projects->first;
    
    if ( !defined $project ) {
        $self->param( 'report_error', 'No Results!' );
        return $self->forward('report_error');
    }
    
    my $project_tasks = $self->{schema}->resultset('Tasks')->search(
		{ project => $project->id},
		{ columns => [qw/id name/]},); 
	my @tasks; 
	while (my $task = $project_tasks->next) {
		my $pt_rh = {
			id => $task->id,
			name => $task->name,
			app_base_url => $self->config_param('app_base_url'),
		};
		push @tasks, $pt_rh;
	}
    
    my $rh = {
        id          => $project->id,
        name        => $project->name,
        description => $project->description,
        client      => $project->client->name,
        created     => $self->tr_time_sepoch( $project->create_time ),
        updated     => $self->tr_time_sepoch( $project->update_time ),
        closed      => $self->tr_time_sepoch( $project->close_time ),
        tasks => \@tasks,
    };

    $t->param($rh);
    return $t->output;
}

# project_select_list() returns html containing project select list constrained by client
sub project_form_select_html : Runmode {
    my $self = shift;
    my $id_p = $self->query->param('client');

    # set this before loading the template that doesn't have general var tags
    $self->param('skip_set_default_t_params',1);
    my $t = $self->load_tmpl('times/create_project_select.tpl');

    $self->_load_schema;

    my $auth_user = $self->authen_user_rs;

    #validate client for auth_user
    #my $_is_valid = 0;
    #$_is_valid = $self->is_client_in_auth_user_domain($client_id,$auth_user) ? 1 : 0;
    # authorize user for this client?

    my $client_id = $id_p;  #change this!!
    #generate list of projects
    $t->param(
        project_list => $self->projects_select_hash_list(
                $self->projects_for_client_rs($auth_user,$client_id),
                undef),
        );
    $t->output;
}

#

1;
