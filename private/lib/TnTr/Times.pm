package TnTr::Times;

use strict;
use base 'TnTr';
use DateTime::Format::RFC3339;
use Data::Dumper;

sub setup {     # overrides     # called after cgiapp_init()
    my $self = shift;
    $self->authen->protected_runmodes(':all');
}
sub default : StartRunmode {
    my $self = shift;
    my $q = $self->query;
    my $t = $self->load_tmpl('times/default.tpl');
    my $total_times =  $self->dbh->selectrow_array('select count(*) from times');
    $t->param(total_times => $total_times);
    return $t->output;
}

sub get_user_rights_for {
    my $self = shift;
    my $auth_user = shift;
    my $right = shift;
    my $app_id = shift;

    my @args = @_;
    my $app_name = 'Times';
    
    $self->get_user_app_rights_for( $auth_user, $right, $app_name, $app_id, @args );
}

sub create_display : Runmode {
    my $self = shift;
    my $errs = shift;

#TODO check if user is allowed to enter 'create' time.
    my $t = $self->load_tmpl('times/create.tpl');

    $self->_load_schema;
    my $auth_user = $self->authen_user_rs;

    # check action permissions
    if (! $self->time_update_allowable(undef,$auth_user, undef) ){
        $self->param('report_error', 'You do not have permissions for this Action!');
        return $self->forward('report_error');
    }
    
    $t->param( 
        client_list => $self->clients_select_hash_list(
                $self->clients_for_user_rs($auth_user),
                undef),
        );
    $errs && $t->param($errs);
    $t->output;
}

sub create_process : Runmode {
    my $self = shift;

    my $dfv_results = $self->check_rm('create_display','_create_dfv_rules') || return $self->check_rm_error_page;

    $self->_load_schema();

    my $auth_user = $self->authen_user_rs;

    # check action permissions
    if (! $self->time_update_allowable($dfv_results->valid('task'),$auth_user, undef) ){
        $self->param('report_error', 'You do not have permissions for this Action!');
        return $self->forward('report_error');
    }
    
    #setup start/end date/time RFC3339
    my $start_datetime = $dfv_results->valid('start_date').'T'.$dfv_results->valid('start_time').'Z';
    my $end_datetime = $dfv_results->valid('end_date').'T'.$dfv_results->valid('end_time').'Z';
    
    my $time = $self->{schema}->resultset('Times')->create({
                    name => $dfv_results->valid('name'),
                    description => $dfv_results->valid('description'),
                    user => $auth_user->id,
                    task => $dfv_results->valid('task'),
                    start_datetime => $start_datetime,
                    end_datetime => $end_datetime,
                    });

#TODO check if it was _really_ created!!
    if (!$time) {
         warn $time->db_obj_error;
         $self->param('report_error', 'Something broke!');
         return $self->forward('report_error');
    }
    $self->session->param(flash_msg => 'Time created!');    
    $self->redirect($self->config_param('app_base_url').'/times/show/'.$time->id);
}

sub edit_display : Runmode {
    my $self = shift;
    my $errs = shift;
    my $id_p = $self->param('id');
    
    $self->_load_schema();
	#$self->is_user_authorized();  #TODO is this the auth model???
	
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

    my $t = $self->load_tmpl('times/edit.tpl');

    my $rs =
      $self->{schema}->resultset('Times')
      ->search( $search_constraint, { columns => [qw/id name description task start_datetime end_datetime/], }, );
  
    my $time = $rs->first;
    if (! defined $time){
        $self->param('report_error', 'The time you are trying to edit does not exists!');
        return $self->forward('report_error');
    }
    
    my $auth_user = $self->authen_user_rs;

	my $task_id;  #TODO lookup in db and set this prehaps move all this later ??    

    # check action permissions
    if (! $self->time_update_allowable($time->task->id,$auth_user, $id_p) ){
        $self->param('report_error', 'You do not have permissions for this Action!');
        return $self->forward('report_error');
    }
    warn 'startdate: ', $time->start_datetime;
    #setup start/end date/time from ISO-8601 formated datetime
    my $start_datetime = DateTime::Format::RFC3339->parse_datetime( $time->start_datetime);
    my $end_datetime = DateTime::Format::RFC3339->parse_datetime( $time->end_datetime);

    #load form with values from db.
    $t->param( name => $time->name,
        description => $time->description,
#        user_id => $result->user->id,
#        user_name => $result->user->name,
        task_id => $time->task->id,
        task_name => $time->task->name,
        start_date => $start_datetime->ymd,
        start_time => $start_datetime->hms,
        end_date => $end_datetime->ymd,
        end_time => $end_datetime->hms,
        );
    $errs && $t->param($errs);
    $t->param( time_tree => $self->time_tree($id_p) );
    $t->output;
}

sub edit_process : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');

#TODO check if user is allowed to edit 'update' time.
    my $dfv_results = $self->check_rm('edit_display','_edit_dfv_rules') || return $self->check_rm_error_page;

    $self->_load_schema();
    
    my $auth_user = $self->authen_user_rs;
    
    # check action permissions
    if (! $self->time_update_allowable($dfv_results->valid('task'),$auth_user, $id_p) ){
        $self->param('report_error', 'You do not have permissions for this Action!');
        return $self->forward('report_error');
    }

    my $search_id = undef;  
    my $search_constraint = undef;
    
    if ($id_p =~ /^(\d+)/) {
        $search_id = $1;
        $search_constraint = [{ id => $search_id },];
    }
    else {
    # nothing passed in to constrain search, oops!
        $self->param('report_error', 'Update requires an id');
        return $self->forward('report_error');
    }
    my $rs =
      $self->{schema}->resultset('Times')
      ->search( $search_constraint, { columns => [qw/id name description task start_datetime end_datetime/], }, );
  
    my $result = $rs->first;
    if (! defined $result ){
        $self->param('report_error', 'No Results!');
        return $self->forward('report_error');
    }
#TODO sanity check form input values
    #setup start/end date/time iso 8601
    my $start_datetime = $dfv_results->valid('start_date').'T'.$dfv_results->valid('start_time').'Z';
    my $end_datetime = $dfv_results->valid('end_date').'T'.$dfv_results->valid('end_time').'Z';

    my $update_h = { 
        #id => $result->id, 
        name => $dfv_results->valid('name'),
        description => $dfv_results->valid('description'),
        #user => $dfv_results->valid('user'),
        task => $dfv_results->valid('task'),
        start_datetime => $start_datetime,
        end_datetime => $end_datetime,
    };
    $result->update($update_h) || $self->db_obj_error($result->db_obj_error,'Update');
    
    $self->session->param(flash_msg => 'Time updated!');
    $self->redirect($self->config_param('app_base_url').'/times/show/'.$id_p);
}

sub _create_dfv_rules {
    my $self = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name description client project task start_date start_time end_date end_time)];
    $rules->{constraint_methods}->{client} = [qr/[1-9][0-9]*/];
    $rules->{constraint_methods}->{project} = [qr/[1-9][0-9]*/];
    $rules->{constraint_methods}->{task} = [qr/[1-9][0-9]*/];
#TODO replace with subs that check date and time validity .. 
    $rules->{constraint_methods}->{start_date} = [qr/\d\d\d\d-\d\d-\d\d/];
    $rules->{constraint_methods}->{start_time} = [qr/\d\d:\d\d:\d\d/];
    $rules->{constraint_methods}->{end_date} = [qr/\d\d\d\d-\d\d-\d\d/];
    $rules->{constraint_methods}->{end_time} = [qr/\d\d:\d\d:\d\d/];
    return $rules;
}

sub _edit_dfv_rules {
    my $self = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name description task start_date start_time end_date end_time)];
    $rules->{constraint_methods}->{task} = [qr/[1-9][0-9]*/];
#TODO replace with subs that check date and time validity .. 
    $rules->{constraint_methods}->{start_date} = [qr/\d\d\d\d-\d\d-\d\d/];
    $rules->{constraint_methods}->{start_time} = [qr/\d\d:\d\d:\d\d/];
    $rules->{constraint_methods}->{end_date} = [qr/\d\d\d\d-\d\d-\d\d/];
    $rules->{constraint_methods}->{end_time} = [qr/\d\d:\d\d:\d\d/];
    return $rules;
}

sub list : Runmode {
    my $self = shift;
    #my $args = $self->param('dispatch_url_remainder');
#TODO check if user is allowed to 'list' time.
    
    $self->_load_schema();
    
    my $auth_user = $self->authen_user_rs;
    
#    my $rs =
#      $self->{schema}->resultset('Times')
#      ->search( $search_constraint, { columns => [qw/id name description user task start_datetime end_datetime/], }, );

# from dbix:class debug
# SELECT me.id, me.name, me.user, me.task, me.description, me.start_datetime, 
# me.end_datetime, me.create_time, me.update_time 
# FROM times me  JOIN tasks task ON task.id = me.task  
# JOIN projects project ON project.id = task.project  
# JOIN clients client ON client.id = project.client  
# JOIN domains domain ON domain.id = client.domain WHERE ( domain.id = ? )

	my $times =  $self->{schema}->resultset('Times')->search(
		{
			'domain.id' => $auth_user->domain->id,
		},
		{
			join => {
				'task' => {
					'project' => {
						'client' => 'domain', 
						},
				},
			},
		});
   
    my @time_list; 
    foreach my $time ($times->all) {
           my $rh = { 
               id => $time->id, 
               name => $time->name, 
               description => $time->description,
               user => $time->user->name,
               task => $time->task->name,
               start_time => $time->start_datetime,
               end_time => $time->end_datetime,
               app_base_url => $self->config_param('app_base_url'),
           };
           push @time_list, $rh;
    }
    my $t = $self->load_tmpl('times/list.tpl');
    $t->param( time_list => \@time_list);
    return $t->output;
}

sub show : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');
   
#TODO check if user is allowed to view this 'list' time.
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

    my $t = $self->load_tmpl('times/show.tpl');

    $self->_load_schema();
    my $times =
      $self->{schema}->resultset('Times')
      ->search( $search_constraint, { columns => [qw/id name description user task start_datetime end_datetime create_time update_time/], }, );

	my $time = $times->first;
	if (! defined $time ){
        $self->param('report_error', 'No Results!');
        return $self->forward('report_error');
    }
    my $rh = { 
        id => $time->id, 
        name => $time->name, 
        description => $time->description,
        user => $time->user->name,
        task => $time->task->name,
        start_datetime => $time->start_datetime,
        end_datetime => $time->end_datetime,
        created     => $self->tr_time_sepoch( $time->create_time ),
        updated     => $self->tr_time_sepoch( $time->update_time ),
       # closed      => $self->tr_time_sepoch( $result->close_time ),
    };
    $t->param( $rh );
    $t->param( time_tree => $self->time_tree($time->id) );
    return $t->output;
}

sub time_tree {
    my $self = shift;
    my $time_id = shift;

    $self->_load_schema;

    my $time_rs = $self->{schema}->resultset('Times')->find({id=>$time_id},{ columns=>[qw/task/],},);
    my $tree = '[' .
        ' Client : '. $time_rs->task->project->client->name .
        ', Project : '. $time_rs->task->project->name .
        ', Task : ' . $time_rs->task->name .  ']';
}
# 

1;
