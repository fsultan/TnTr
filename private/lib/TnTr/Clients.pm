package TnTr::Clients;

use strict;
use base 'TnTr';
use CGI::Application::Plugin::AutoRunmode;


sub setup {     # overrides     # called after cgiapp_init()
    my $self = shift;
    $self->authen->protected_runmodes(':all');
}

#sub user_rights_create_client_for_domain {
#	my $self = shift;
#	my $auth_user = shift;
#    my @args = @_;
#    #my $app_name = 'Clients';
#    
#    #just in case we don't get the auth user in .. 
#    if (! ref $auth_user){
#    	$auth_user = $self->authen_user_rs;
#    }
#
#    # no user is domain owner, no need to check that here
#    
#    if ($self->user_rights_create_child($auth_user,'Domains',$auth_user->domain->id)){
#    	warn "allowed: user_rights_domain_create_child";
#    	return 1;
#    }
#    return 0;
#}

sub may_user_create_client {
	my $self = shift;
	my $auth_user = shift;
	
	if ($self->is_user_superuser || 
		$self->is_user_client_admin($auth_user)){
			return 1;
		}
	return 0;
}

sub may_user_edit_client {
	my $self = shift;
	my $auth_user = shift;
	my $client_id = shift;
	
	my @args = @_;
	
    #yes if user is superuser, site-admin, or creator, or client-admin in group  

	if ($self->is_user_superuser || 
		$self->is_user_site_admin($auth_user) ||
		$self->is_user_record_creator($auth_user,'Clients', $client_id) ||
		$self->is_user_clientadmin_in_client_group($auth_user,$client_id) ){
			return 1;
		}
	return 0;
}

sub may_user_delete_client {
	my $self = shift;
	my $auth_user = shift;
	my $client_id = shift;
	
	my @args = @_;
	
    #yes if user is superuser, site-admin, or creator, 

	if ($self->is_user_superuser || 
		$self->is_user_site_admin($auth_user) ||
		$self->is_user_record_creator($auth_user,'Client', $client_id)){
			return 1;
		}
	return 0;
}

sub default : StartRunmode {
    my $self = shift;
    my $q = $self->query;
    my $t = $self->load_tmpl('clients/default.tpl');
    my $total_clients =  $self->dbh->selectrow_array('select count(*) from clients');
    $t->param(total_clients => $total_clients);
    return $t->output;
}

sub create_display : Runmode {
    my $self = shift;
    my $errs = shift;
    
    $self->_load_schema;

    my $auth_user = $self->authen_user_rs;

    #check if user is allowed to create a client for their domain
    if ( ! $self->may_user_create_client($auth_user) ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    }
    my $t = $self->load_tmpl('clients/create.tpl');

    #TODO check authorization

    $errs && $t->param($errs);
    $t->output;
}

sub create_process : Runmode {
    my $self = shift;

    #TODO check if user is allowed to create project.
    my $dfv_results = $self->check_rm( 'create_display', '_create_dfv_rules' )
      || return $self->check_rm_error_page;

    $self->_load_schema();

    #check incoming client_id
    my $auth_user = $self->authen_user_rs;

    #check if user is allowed to create a client for their domain
    if ( ! $self->may_user_create_client($auth_user) ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    }

    my $client = $self->{schema}->resultset('Clients')->create(
        {
            name        => $dfv_results->valid('name'),
            creator_id	=> $auth_user->id,
            domain		=> $auth_user->domain->id,
        }
    );

    #TODO check if it was _really_ created!!
    if ( !$client ) {
        $self->report_db_obj_error( $client->db_obj_error, 'Update' );
    }

    $self->session->param( flash_msg => 'Client created!' );
    $self->redirect( $self->config_param('app_base_url')
          . '/clients/show/'
          . $client->id );
}


sub edit_display : Runmode {
    my $self = shift;
    my $errs = shift;
    my $id_p = $self->param('id');

    
    my $client_id_p;
    if ($id_p =~ /^(\d+)/) {
        $client_id_p = $1;
    }
    else {
    # nothing passed in to constrain search, oops!
        $self->param('report_error', 'Edit requires an id');
        return $self->forward('report_error');
    }

    my $t = $self->load_tmpl('clients/edit.tpl');

    $self->_load_schema();
    
    my $auth_user = $self->authen_user_rs;
    
    #check if user is allowed to edit this or any client!
    if ( ! $self->may_user_edit_client($auth_user, $client_id_p) ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    }    

    my $search_constraint = [ -and => [{ id => $client_id_p}, { domain => $auth_user->domain->id}],];

    my $rs =
      $self->{schema}->resultset('Clients')
      ->search( $search_constraint, { columns => [qw/id name/], }, );
  
    my $result = $rs->first;
    if (! defined $result){
        $self->param('report_error', 'The client you are trying to edit does not exists!');
        return $self->forward('report_error');
    }
    #load form with values from db.
    $t->param( 
        name => $result->name,
        );
    $errs && $t->param($errs);
    $t->output;
}

sub edit_process : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');

    my $dfv_results = $self->check_rm('edit_display','_edit_dfv_rules') || return $self->check_rm_error_page;

    my $client_id_p;

    if ($id_p =~ /^(\d+)/) {
        $client_id_p = $1;
    }
    else {
    # nothing passed in to constrain search, oops!
        $self->param('report_error', 'Edit requires an id');
        return $self->forward('report_error');
    }

    $self->_load_schema();
   
    my $auth_user = $self->authen_user_rs;
    
    #check if user is allowed to edit this or any client!
    if ( ! $self->may_user_edit_client($auth_user, $client_id_p) ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    }  

    my $search_constraint = [ -and => [{ id => $client_id_p}, { domain => $auth_user->domain->id}],];

    my $rs =
      $self->{schema}->resultset('Clients')
      ->search( $search_constraint, { columns => [qw/id name/], }, );
  
    my $result = $rs->first;
    if (! defined $result ){
        $self->param('report_error', 'No Results!');
        return $self->forward('report_error');
    }
    my $update_h = { 
        #id => $result->id, 
        name => $dfv_results->valid('name'),
        #description => $dfv_results->valid('description'),
        #domain => $dfv_results->valid('domain'),
    };

    # bad error occured! deal with it
    $result->update($update_h) || $self->report_db_obj_error($result->db_obj_error,'Update');
    
    $self->session->param(flash_msg => 'Client updated!');
    $self->redirect($self->config_param('app_base_url').'/clients/show/'.$id_p);
}

sub _create_dfv_rules {
    my $self = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name)];
    return $rules;
}

sub _edit_dfv_rules {
    my $self = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name)];
    return $rules;
}

sub list : Runmode {
    my $self = shift;
    my $args = $self->param('dispatch_url_remainder');
    
    my $search_id = undef;  
    my $search_constraint = undef;

    #if args starts with a number set the constraint
    if ($args =~ /^(\d+)/) {
        $search_id = $1;
        $search_constraint = [{ id => $search_id },];
    }
    
    my $t = $self->load_tmpl('clients/list.tpl');
    $self->_load_schema();
#    my $rs =
#      $self->{schema}->resultset('Clients')
#      ->search( $search_constraint, { columns => [qw/id name/], }, );
    my $auth_user = $self->authen_user_rs;
  
	my $clients = $self->{schema}->resultset('Clients')->search(
		{
			'domain.id' => $auth_user->domain->id,
		},
		{
			join =>  'domain' ,
			columns => [qw/id name/],
		},
	);
	   
    my @client_list; 
    foreach my $client ($clients->all) {
           my $rh = { 
               id => $client->id, 
               name => $client->name, 
               #domain => $client->domain->name,
               app_base_url => $self->config_param('app_base_url'),
           };
           push @client_list, $rh;
    }
    $t->param( client_list => \@client_list);
    return $t->output;
}

sub show : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');
    
    my $search_id = undef;  
    my $search_constraint = undef;

    #if args starts with a number set the constraint
    if ($id_p =~ /^(\d+)/) {
        $search_id = $1;
        $search_constraint = [{ id => $search_id },];
    }
    else {
    # nothing passed in to constrain search, oops!
        $self->param('report_error', 'Show requires an id');
        return $self->forward('report_error');
    }
    
    #TODO show only if user is in client group!
    
    my $t = $self->load_tmpl('clients/show.tpl');

    $self->_load_schema();
    my $clients =
      $self->{schema}->resultset('Clients')
      ->search( $search_constraint, { columns => [qw/id name create_time update_time close_time/], }, );
    my $client = $clients->first;
    
	my $client_projects = $self->{schema}->resultset('Projects')->search(
		{ client => $client->id},
		{ columns => [qw/id name/]},); 
	my @projects; 
	while (my $project = $client_projects->next) {
		my $cp_rh = {
			id => $project->id,
			name => $project->name,
			app_base_url => $self->config_param('app_base_url'),
		};
		push @projects, $cp_rh;
	}
    my $rh = { 
        id => $client->id, 
        name => $client->name, 
        #domain => $result->domain->name,
        created => $self->tr_time_human($client->create_time),
        updated => $self->tr_time_human($client->update_time),
        closed => $self->tr_time_human($client->close_time),
        projects => \@projects,
    };
    
    $t->param( $rh );
    return $t->output;
}
# 

1;
