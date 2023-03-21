package TnTr::Groups;

use strict;
use base 'TnTr';
use List::Compare;

use Data::Dumper;

sub setup {     # overrides     # called after cgiapp_init()
    my $self = shift;
    $self->authen->protected_runmodes(':all');
}

sub default : StartRunmode {
    my $self = shift;
    my $q = $self->query;
    my $t = $self->load_tmpl('groups/default.tpl');
    my $total_groups =  $self->dbh->selectrow_array('select count(*) from groups');
    $t->param(total_groups => $total_groups);
    return $t->output;
}

sub get_user_rights_for {
    my $self = shift;
    my $auth_user = shift;
    my $right = shift;
    my $app_id = shift;

    my @args = @_;
    my $app_name = 'Groups';
    
    $self->get_user_app_rights_for( $auth_user, $right, $app_name, $app_id, @args );
}

sub create_display : Runmode {
    my $self = shift;
    my $errs = shift;

    #TODO check if user is allowed to create project.
    my $t = $self->load_tmpl('groups/edit.tpl');

    $self->_load_schema;

    my $auth_user = $self->authen_user_rs;

    #TODO check authorization

    $errs && $t->param($errs);
    $t->output;
}

sub create_process : Runmode {
	my $self = shift;
	
	#TODO check if user is allowed to create group.
    my $dfv_results = $self->check_rm( 'create_display', '_create_dfv_rules' )
      || return $self->check_rm_error_page;

    $self->_load_schema();

    #check incoming client_id
    my $auth_user = $self->authen_user_rs;

    #TODO check authorization
    # check action permissions  will I have a client id defined???
#    if ( !$self->project_update_allowable( undef, $auth_user, undef ) ) {
#        $self->param( 'report_error',
#            'You do not have permissions for this Action!' );
#        return $self->forward('report_error');
#    }

    my $group = $self->{schema}->resultset('Groups')->create(
        {
            name        => $dfv_results->valid('name'),
            creator_id		=> $auth_user->id,
            domain      => $auth_user->domain->id,
        }
    );

    #TODO check if it was _really_ created!!
    if ( !$group ) {
        $self->report_db_obj_error( $group->db_obj_error, 'Create' );
    }

    $self->session->param( flash_msg => 'Group created!' );
    $self->redirect( $self->config_param('app_base_url')
          . '/groups/show/'
          . $group->id );
}

sub delete : Runmode {
    my $self = shift;

}

sub edit_display : Runmode {
    my $self = shift;
    my $errs = shift;
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
        $self->param('report_error', 'Edit requires an id');
        return $self->forward('report_error');
    }

    my $t = $self->load_tmpl('groups/edit.tpl');

    $self->_load_schema();

    my $auth_user = $self->authen_user_rs;
    
    #TODO change this group_update_allowable thing
    if (! $self->group_update_allowable($id_p,$auth_user) ){
        $self->param('report_error', 'You do not have permissions for this Action!');
        return $self->forward('report_error');
    }
    #TODO check authorization

    my $rs =
      $self->{schema}->resultset('Groups')
      ->search( $search_constraint, { columns => [qw/id name/], }, );
  
    my $result = $rs->first;
    if (! defined $result){
        $self->param('report_error', 'The user you are trying to edit does not exists!');
        return $self->forward('report_error');
    }
    #load form with values from db.
    $t->param( 
        name => $result->name,
        #domain_id  => $result->domain->id,
        #domain_name => $result->domain->name,
        );
    $errs && $t->param($errs);
    $t->output;
}

sub edit_process : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');

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
      $self->{schema}->resultset('Groups')
      ->search( $search_constraint, { columns => [qw/id name/], }, );
  
    my $result = $rs->first;
    if (! defined $result ){
        $self->param('report_error', 'No Results!');
        return $self->forward('report_error');
    }
    
    my $auth_user = $self->authen_user_rs;

    #check action permissions
    if (! $self->group_update_allowable($id_p,$auth_user) ){
        $self->param('report_error', 'You do not have permissions for this Action!');
        return $self->forward('report_error');
    }
    my $update_h = { 
        #id => $result->id, 
        name => $dfv_results->valid('name'),
        #description => $dfv_results->valid('description'),
        #domain => $dfv_results->valid('domain'),
    };
    $result->update($update_h) || $self->db_obj_error($result->db_obj_error,'Update');
    
    $self->session->param(flash_msg => 'Group updated!');
    $self->redirect($self->config_param('app_base_url').'/groups/show/'.$id_p);
}

sub _edit_dfv_rules {
    my $self = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name)];
    return $rules;
}

sub _create_dfv_rules {
    my $self = shift;
#    my $rules = $self->param('dfv_defaults');
#    $rules->{required} = [qw(name)];
    return $self->_edit_dfv_rules;
}

sub list : Runmode {
    my $self = shift;
    my $args = shift;
    #my $
    my $args = $self->param('dispatch_url_remainder');
    
    my $search_id = undef;  
    my $search_constraint = undef;

    #if args starts with a number set the constraint
    if ($args =~ /^(\d+)/) {
        $search_id = $1;
        $search_constraint = [{ id => $search_id },];
    }
    my $t = $self->load_tmpl('groups/list.tpl');
    $self->_load_schema();
    my $rs =
      $self->{schema}->resultset('Groups')
      ->search( $search_constraint, { columns => [qw/id name/], }, );
   
    my @group_list; 
    foreach my $r ($rs->all) {
           my $rh = { 
               id => $r->id, 
               name => $r->name, 
               #domain => $r->domain->name,
               app_base_url => $self->config_param('app_base_url'),
           };
           push @group_list, $rh;
    }
    $t->param( group_list => \@group_list);
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
    my $t = $self->load_tmpl('groups/show.tpl');

    $self->_load_schema();
    my $rs =
      $self->{schema}->resultset('Groups')
      ->search( $search_constraint, { columns => [qw/id name create_time update_time close_time/], }, );
  
    my $result = $rs->first;
    my $rh = { 
        id => $result->id, 
        name => $result->name, 
        #domain => $result->domain->name,
        created => $self->tr_time_human($result->create_time),
        updated => $self->tr_time_human($result->update_time),
        closed => $self->tr_time_human($result->close_time),
    };
    
    $t->param( $rh );
    return $t->output;
}

sub update_memberships_display : Runmode {
	my $self = shift;
	# $self->param('owner_type');
	# $self->param('owner_id');
	
	# check params to be valid owner_name (user or client/project/task)
	# 	and owner_id (user_id or client_i/project_i/task_i)
	$self->_load_schema();
	
	my ($args_are_valid, $owner, $app_group, $valid_id_arg) = $self->_valid_group_owner_rs ($self);
	
	if (! $args_are_valid){
		#incoming args are not valid, show error!
		$self->param( 'report_error', 'Cannot load record: invalid request parameters or record does not exit.' );
        return $self->forward('report_error');
    }	
    # does not continue past if args are not valid!
    
    my $auth_user = $self->authen_user_rs;
    
    #TODO check if the actor has rights!!  
    my $t = $self->load_tmpl('groups/update_memberships.tpl');
    	 
    #get all groups in domain
    my $groups_in_domain_rs = 
    	$self->{schema}->resultset('Groups')->search(
    		{ domain => $auth_user->domain->id },
    		{ columns => [qw/id name/]},
    );
    
    if (! defined $groups_in_domain_rs) {
    	# groups not found
    	$self->param( 'report_error', 'Could not find any valid groups. Please create a valid group first!' );
        return $self->forward('report_error');
    }
    
    my %groups;
    
    #create a hash with all domain groups id as key, anon hash as value 
    while (my $group_in_domain = $groups_in_domain_rs->next){
    	$groups{$group_in_domain->id} = { 
    			id	=> $group_in_domain->id,
    			name => $group_in_domain->name};
    }

    my $group_rs = $owner->groups;

    #iterate through current memberships and add checked arg for form to groups hash
    while (my $group = $group_rs->next){
    	$groups{$group->id}->{checked} = 'checked';
    	#TODO what if there is a group that isn't in domain groups anymore ??
    }
    
    my @owner_groups = map { $groups{$_} } (keys %groups);
    
	my $rh = { 
        id => $owner->id, 
        name => $owner->name, 
#        #domain => $result->domain->name,
#        created => $self->tr_time_human($user->create_time),
#        updated => $self->tr_time_human($user->update_time),
#        closed => $self->tr_time_human($user->close_time),
        user_groups => \@owner_groups,
    };
    
	$t->param( $rh );
	
	return $t->output;
}

sub update_memberships_process : Runmode {
	my $self = shift;
	
	# check params to be valid owner_name (user or client/project/task)
	# 	and owner_id (user_id or client_i/project_i/task_i)

	$self->_load_schema();
	
	my ($args_are_valid, $owner, $app_group, $valid_id_arg) = $self->_valid_group_owner_rs();
	
	if (! $args_are_valid){
		#incoming args are not valid, show error!
		$self->param( 'report_error', 'Cannot load record: invalid request parameters or record does not exit.' );
        return $self->forward('report_error');
    }	
    # does not continue past if args are not valid!
    
    my $auth_user = $self->authen_user_rs;
    #TODO check if the actor has rights!!  
    #TODO Will remove/add without confirmations, add confirmation of some sort!!
    
    #get all groups in domain
    my $groups_in_domain_rs = 
    	$self->{schema}->resultset('Groups')->search(
    		{ domain => $auth_user->domain->id },
    		{ columns => [qw/id name/]},
    );
    
    if (! defined $groups_in_domain_rs) {
    	# groups not found
    	$self->param( 'report_error', 'Could not find any valid groups. Please create a valid group first!' );
        return $self->forward('report_error');
    }
    
    #my %groups;
    my @enabled_group_ids;
    
    #iterating all groups might as well validate the form params
    while (my $group_in_domain = $groups_in_domain_rs->next){
    	if ($self->query->param('group'.$group_in_domain->id)){
    		push(@enabled_group_ids,$group_in_domain->id);	
    	}
    }

    my $stored_group_rs = $owner->groups;
    my @stored_group_ids;
    
    #iterate through current memberships 
    while (my $group = $stored_group_rs->next){
    	push(@stored_group_ids, $group->id);
    	#TODO what if there is a group that isn't in domain groups anymore ??
    }
    
    #TODO check if the actor has rights!!  
    
    # get diff of @stored_group_ids and @enabled_group_ids
    # in stored, not in enabled = delete
    # in enabled, not in stored = add
    
    my $lc = List::Compare->new(\@enabled_group_ids, \@stored_group_ids);
    
    my @groups_to_join  = $lc->get_unique; 		#only in left list 
    my @groups_to_leave = $lc->get_complement; 	#only in second list
    
    warn "GJ ", join("--",@groups_to_join);
    warn "GL ", join("--",@groups_to_leave);
    
    #set the related groups model app_name|'user'_group!
    
    my $related_groups_model = $self->_related_group_model($app_group);
    my $relation_key = $self->_relation_key($self->param('owner_type'));
    warn "rgm: $related_groups_model , rk: $relation_key for app_group $app_group";
    foreach my $group_id (@groups_to_join){
    	$self->{schema}->resultset($related_groups_model)->create({ $relation_key => $valid_id_arg, gid => $group_id });
    }
    my $leave_group_rv = 
    	$self->{schema}->resultset($related_groups_model)->search(
    		{ $relation_key => $app_group, 
    			gid => [@groups_to_leave]
    		},
    	)->delete;
    #TODO test return value!
	
    $self->session->param( flash_msg => 'Groups Updated!' );
    $self->redirect( $self->config_param('app_base_url')
          . '/'.lc($app_group).'/show/' . $valid_id_arg );
}

sub _relation_key {
	my $self = shift;
	my $value = lc(shift);
	my %relations = (
		'users' => 'user',
		'projects' => 'project',
		'clients' => 'client',
		'tasks' => 'task',
		);
	return $relations{$value};
}
sub _related_group_model {
	my $self = shift;
	my $value = lc(shift);
	my %related_group_models = (
		'users' => 'User_Group',
		'projects' => 'Project_Group',
		'clients' => 'Client_Group',
		'tasks' => 'Task_Group',
		);
		return $related_group_models{$value};
}

sub _valid_group_owner_rs {
	my $self = shift;

	my $args_are_valid = 0;
	$self->param('owner_id') =~ /^([1-9][0-9]*)$/;
	my $valid_id_arg = $1;
	
	my $valid_app_name = $self->valid_app_name($self->param('owner_type'));
	my $owner = undef;
	my $name = undef;
	warn "Valid app name $valid_app_name with $valid_id_arg";
	if ($valid_app_name eq 'Users'){
		$owner = $self->{schema}->resultset('Users')->find($valid_id_arg);
		if (defined $owner){
			$args_are_valid = 1;
			$name = 'Users';
		}
	}
	elsif ( $valid_app_name ){
		warn "Checking valid_app_name";
		$owner = $self->{schema}->resultset($valid_app_name)->find($valid_id_arg);
		if (defined $owner){
			$args_are_valid = 1;
			warn "Found App";
			$name = $valid_app_name;
		}
	}
    return ($args_are_valid, $owner, $name, $valid_id_arg);
}

# 

1;

