package TnTr::Tasks;

use strict;
use base 'TnTr';

sub setup {     # overrides     # called after cgiapp_init()
    my $self = shift;
    $self->authen->protected_runmodes(':all');
}

sub may_user_create_task {
	my $self = shift;
	my $auth_user = shift;
	my $client = shift;
	
	if ($self->is_user_superuser || 
		$self->is_user_projectadmin_for_client($auth_user,$client)){
			return 1;
		}
	return 0;
}

sub may_user_edit_task {
	my $self = shift;
	my $auth_user = shift;
	my $task_id = shift;
	
	my @args = @_;
	
    #yes if user is superuser, site-admin, or creator, or creator of project, or project-admin  

	if ($self->is_user_superuser || 
		$self->is_user_site_admin($auth_user) ||
		$self->is_user_record_creator($auth_user,'Tasks', $task_id) ||
		$self->is_user_projectadmin_for_task($auth_user,$task_id) ){
			return 1;
		}
	return 0;
}

sub may_user_delete_task {
	my $self = shift;
	my $auth_user = shift;
	my $task_id = shift;
	
	my @args = @_;
	
    #yes if user is superuser, site-admin, or creator, 

	if ($self->is_user_superuser || 
		$self->is_user_site_admin($auth_user) ||
		$self->is_user_record_creator($auth_user,'Tasks', $task_id)){
			return 1;
		}
	return 0;
}

sub default : StartRunmode {
    my $self = shift;
    my $q = $self->query;
    my $t = $self->load_tmpl('tasks/default.tpl');
    my $total_tasks =  $self->dbh->selectrow_array('select count(*) from tasks');
    $t->param(total_tasks => $total_tasks);
    return $t->output;
}

sub get_user_rights_for {
    my $self = shift;
    my $auth_user = shift;
    my $right = shift;
    my $app_id = shift;

    my @args = @_;
    my $app_name = 'Tasks';
    
    $self->get_user_app_rights_for( $auth_user, $right, $app_name, $app_id, @args );
}

sub create_display : Runmode {
    my $self = shift;
    my $errs = shift;

    #TODO check if user is allowed to create project.
    my $t = $self->load_tmpl('tasks/create.tpl');

    $self->_load_schema;

    my $auth_user = $self->authen_user_rs;

    #TODO check authorization
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

    #check incoming user
    my $auth_user = $self->authen_user_rs;
      
    #TODO check authorization
    # check action permissions  will I have a client id defined???
    if (! $self->is_user_authorized() ) {
        $self->param( 'report_error',
            'You do not have permissions for this Action!' );
        return $self->forward('report_error');
    }

    my $task = $self->{schema}->resultset('Tasks')->create(
        {
            name        => $dfv_results->valid('name'),
            creator_id		=> $auth_user->id,
            description => $dfv_results->valid('description'),
            project      => $dfv_results->valid('project'),
        }
    );

    #TODO check if it was _really_ created!!
    if ( !$task ) {
        $self->report_db_obj_error( $task->db_obj_error, 'Update' );
    }

    $self->session->param( flash_msg => 'Task created!' );
    $self->redirect( $self->config_param('app_base_url')
          . '/tasks/show/'
          . $task->id );
}

sub edit_display : Runmode {
    my $self = shift;
    my $errs = shift;
    my $id_p = $self->param('id');
#TODO check if user is allowed to edit 'update' task.
    my $search_id = undef;  
    my $search_constraint = undef;

    #if args starts with a number set the constraint
    if ($id_p =~ /^(\d+)/) {
        $search_id = $1;
        $search_constraint = [{ id => $search_id },];
    }
    else {
    # nothing passed in to constrain search, oops!
        $self->param('report_error', 'Edit requires an id');
        return $self->forward('report_error');
    }
    #TODO check authorization
    my $t = $self->load_tmpl('tasks/edit.tpl');

    $self->_load_schema();
    my $rs =
      $self->{schema}->resultset('Tasks')
      ->search( $search_constraint, { columns => [qw/id name description project/], }, );
  
    my $task = $rs->first;
    if (! defined $task){
        $self->param('report_error', 'The task you are trying to edit does not exists!');
        return $self->forward('report_error');
    }
    my $projects_rs = $self->{schema}->resultset('Projects')->search( undef, { columns => [qw/id name/], }, );
    if (! defined $projects_rs) {
        $self->param('report_error', 'Could not find any suitable Projects!');
        return $self->forward('report_error');
    }
    my @project_list;
    while ( my $project = $projects_rs->next) {
        my %project_option = (
            project_id=> $project->id,
            project_name => $project->name,
        );
        if ( $task->project->id == $project->id) {
            $project_option{'selected'} = 1;
        }
        push @project_list, \%project_option;
    }
    #load form with values from db.
    $t->param( name => $task->name,
        description => $task->description,
        project_list => \@project_list,
        );
    $errs && $t->param($errs);
    $t->output;
}

sub edit_process : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');
#TODO check if user is allowed to edit 'update' task.
    my $dfv_results = $self->check_rm('edit_display','_edit_dfv_rules') || return $self->check_rm_error_page;

    my $search_id = undef;  
    my $search_constraint = undef;
    
    $self->_load_schema();
    if ($id_p =~ /^(\d+)/) {
        $search_id = $1;
        $search_constraint = [{ id => $search_id },];
    }
    else {
    # nothing passed in to constrain search, oops!
        $self->param('report_error', 'Update requires an id');
        return $self->forward('report_error');
    }
    #TODO check authorization
    my $rs =
      $self->{schema}->resultset('Tasks')
      ->search( $search_constraint, { columns => [qw/id name description project/], }, );
  
    my $result = $rs->first;
    if (! defined $result ){
        $self->param('report_error', 'No Results!');
        return $self->forward('report_error');
    }
    my $update_h = { 
        #id => $result->id, 
        name => $dfv_results->valid('name'),
        description => $dfv_results->valid('description'),
        project => $dfv_results->valid('project'),
    };
    #update object, if fails report error!
    $result->update($update_h) || $self->report_db_obj_error($result->db_obj_error,'Update');
    
    $self->session->param(flash_msg => 'Task updated!');
    $self->redirect($self->config_param('app_base_url').'/tasks/show/'.$id_p);
}

sub _create_dfv_rules {
    my $self  = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name description project)];
    $rules->{constraint_methods}->{project} =
      sub { my $val = pop; return ( $val > 0 ) };
    return $rules;
}

sub _edit_dfv_rules {
    my $self = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name description project)];
    $rules->{constraint_methods}->{project} =
      sub { my $val = pop; return ( $val > 0 ) };
    return $rules;
}


sub list : Runmode {
    my $self = shift;
    #my $args = $self->param('dispatch_url_remainder');
#TODO check if user is allowed to 'list' task.    

    my $t = $self->load_tmpl('tasks/list.tpl');
    $self->_load_schema();
#    my $rs =
#      $self->{schema}->resultset('Tasks')
#      ->search( $search_constraint, { columns => [qw/id name description/], }, );
    my $auth_user = $self->authen_user_rs;
  
	my $tasks =  $self->{schema}->resultset('Tasks')->search(
		{
			'domain.id' => $auth_user->domain->id,
		},
		{
			join => {
				'project' => {
					'client' => 'domain', 
					},
			},
		});
		
    my @task_list; 
    foreach my $task ($tasks->all) {
           my $rh = { 
               id => $task->id, 
               name => $task->name, 
               description => $task->description,
               create_time => $self->tr_time_sepoch($task->create_time),
               app_base_url => $self->config_param('app_base_url'),
           };
           push @task_list, $rh;
    }
    $t->param( task_list => \@task_list);
    return $t->output;
}

sub show : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');
#TODO check if user is allowed to view 'list' task.    
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
        $self->forward('report_error');
    }
    my $t = $self->load_tmpl('tasks/show.tpl');

    $self->_load_schema();
    my $tasks =
      $self->{schema}->resultset('Tasks')
      ->search( $search_constraint, { columns => [qw/id name description project create_time update_time close_time/], }, );
  
    my $task = $tasks->first;
    
    my $task = $tasks->first;
    
    if (! defined $task ){
        $self->param('report_error', 'No Results!');
        return $self->forward('report_error');
    }
    	my $task_times = $self->{schema}->resultset('Times')->search(
		{ task => $task->id},
		{ columns => [qw/id name/]},); 
	my @times; 
	while (my $time = $task_times->next) {
		my $tt_rh = {
			id => $time->id,
			name => $time->name,
			app_base_url => $self->config_param('app_base_url'),
		};
		push @times, $tt_rh;
	}
    
    my $rh = { 
        id => $task->id, 
        name => $task->name, 
        description => $task->description,
        project => $task->project->name,
        created => $self->tr_time_sepoch($task->create_time),
        updated => $self->tr_time_sepoch($task->update_time),
        closed => $self->tr_time_sepoch($task->close_time),
        times => \@times,
    };
    
    $t->param( $rh );
    return $t->output;
}

# task_select_list() returns html containing task select list constrained by project
sub task_form_select_html : Runmode {
    my $self = shift;
    my $id_p = $self->query->param('project');

    # set this before loading the template that doesn't have general var tags
    $self->param('skip_set_default_t_params',1);
    my $t = $self->load_tmpl('times/create_task_select.tpl');

    $self->_load_schema;

    my $auth_user = $self->authen_user_rs;

    #validate project for auth_user

    my $project_id = $id_p;  #change this!!
    #generate list of tasks
    $t->param(
        task_list => $self->tasks_select_hash_list(
                $self->tasks_for_project_rs($auth_user,$project_id),
                undef),
        );
    $t->output;
}

# 

1;
