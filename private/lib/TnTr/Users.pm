package TnTr::Users;

use strict;
use base 'TnTr';
use Data::Dumper;

sub setup {     # overrides     # called after cgiapp_init()
    my $self = shift;
    $self->authen->protected_runmodes(':all');
}

sub default : StartRunmode {
    my $self = shift;
    my $q = $self->query;
    my $t = $self->load_tmpl('users/default.tpl');
    my $total_users =  $self->dbh->selectrow_array('select count(*) from users');
    $t->param(total_users => $total_users);
    return $t->output;
}

sub get_user_rights_for {
    my $self = shift;
    my $auth_user = shift;
    my $right = shift;
    my $app_id = shift;

    my @args = @_;
    my $app_name = 'Users';
    
    $self->get_user_app_rights_for( $auth_user, $right, $app_name, $app_id, @args );
}

sub create : Runmode {
    my $self = shift;
}

sub delete : Runmode {
    my $self = shift;

}

sub edit_display : Runmode {
    my $self = shift;
    my $errs = shift;
    my $id_p = $self->param('id');
#TODO check if user is allowed to edit this user. 
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

    my $t = $self->load_tmpl('users/edit.tpl');

    $self->_load_schema();

   my $auth_user = $self->authen_user_rs;
   
    if (! $self->user_update_allowable($id_p,$auth_user) ){
        $self->param('report_error', 'You do not have permissions for this Action!');
        return $self->forward('report_error');
    }
    #TODO check authorization

    my $rs =
      $self->{schema}->resultset('Users')
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
#TODO check if user is allowed to edit this user. 
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
      $self->{schema}->resultset('Users')
      ->search( $search_constraint, { columns => [qw/id name/], }, );
  
    my $result = $rs->first;
    if (! defined $result ){
        $self->param('report_error', 'No Results!');
        return $self->forward('report_error');
    }
    my $auth_user = $self->authen_user_rs;

    #check action permissions
    if (! $self->user_upate_allowable($id_p,$auth_user) ){
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
    
    $self->session->param(flash_msg => 'User updated!');
    $self->redirect($self->config_param('app_base_url').'/users/show/'.$id_p);
}

sub _edit_dfv_rules {
    my $self = shift;
    my $rules = $self->param('dfv_defaults');
    $rules->{required} = [qw(name)];
    return $rules;
}

sub list : Runmode {
    my $self = shift;
    #my $args = shift;
#TODO check if user is allowed to list users. 
    my $args = $self->param('dispatch_url_remainder');


    $self->_load_schema();
    #$self->is_user_authorized();  #TODO is this the auth model???
    
    my $auth_user = $self->authen_user_rs;
    
    my $users =
      $self->{schema}->resultset('Users')->search( 
      	{
      		'domain.id' => $auth_user->domain->id,
      	}, 
      	{ 
      		join => 'domain',
      		columns => [qw/id name/], 
      	}, );
   
    my @user_list; 
    foreach my $r ($users->all) {
           my $rh = { 
               id => $r->id, 
               name => $r->name, 
               #domain => $r->domain->name,
               app_base_url => $self->config_param('app_base_url'),
           };
           push @user_list, $rh;
    }
    my $t = $self->load_tmpl('users/list.tpl');
    $t->param( user_list => \@user_list);
    return $t->output;

}

sub show : Runmode {
    my $self = shift;
    my $id_p = $self->param('id');
#TODO check if user is allowed to view this user.    
    my $search_id = undef;  
    my $search_constraint = undef;

    #if args starts with a number set the constraint
    if ($id_p =~ /^(\d+)/) {
        $search_id = $1;
        $search_constraint = [{ id => $search_id },];
    }
    my $t = $self->load_tmpl('users/show.tpl');

    $self->_load_schema();
    my $users =
      $self->{schema}->resultset('Users')
      ->search( $search_constraint, { columns => [qw/id name create_time update_time close_time/], }, );
  
    my $user = $users->first;
    my $group_rs = $user->groups;
    my @user_groups;
    while (my $group = $group_rs->next){
    	push(@user_groups,{groupname => $group->name});
    } 
    my $rh = { 
        id => $user->id, 
        name => $user->name, 
        #domain => $result->domain->name,
        created => $self->tr_time_human($user->create_time),
        updated => $self->tr_time_human($user->update_time),
        closed => $self->tr_time_human($user->close_time),
        user_groups => \@user_groups,
    };
    
    $t->param( $rh );
    return $t->output;
}

# 

1;
