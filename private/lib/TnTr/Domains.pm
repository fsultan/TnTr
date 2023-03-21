package TnTr::Domains;

use strict;
use base 'TnTr';

#TODO this method/runtimes are not protected!!!

sub setup {     # overrides     # called after cgiapp_init()
    my $self = shift;
    $self->authen->protected_runmodes(':all');
}

sub default : StartRunmode {
    my $self = shift;
    my $q = $self->query;
    my $t = $self->load_tmpl('domains/default.tpl');
    my $total_domains =  $self->dbh->selectrow_array('select count(*) from domains');
    $t->param(total_domains => $total_domains);
    return $t->output;
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

    my $t = $self->load_tmpl('domains/edit.tpl');

    $self->_load_schema();
    my $rs =
      $self->{schema}->resultset('Domains')
      ->search( $search_constraint, { columns => [qw/id name/], }, );
  
    my $result = $rs->first;
    if (! defined $result){
        $self->param('report_error', 'The domain you are trying to edit does not exists!');
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
    my $rs =
      $self->{schema}->resultset('Domains')
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
    };
    $result->update($update_h) || $self->db_obj_error($result->db_obj_error,'Update');

    $self->session->param(flash_msg => 'Domain updated!');
    $self->redirect($self->config_param('app_base_url').'/domains/show/'.$id_p);
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
    my $t = $self->load_tmpl('domains/list.tpl');
    $self->_load_schema();
    my $rs =
      $self->{schema}->resultset('Domains')
      ->search( $search_constraint, { columns => [qw/id name/], }, );
   
    my @domain_list; 
    foreach my $result ($rs->all) {
           my $rh = { 
               id => $result->id, 
               name => $result->name, 
               app_base_url => $self->config_param('app_base_url'),
           };
           push @domain_list, $rh;
    }
    $t->param( domain_list => \@domain_list);
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
    my $t = $self->load_tmpl('domains/show.tpl');

    $self->_load_schema();
    my $rs =
      $self->{schema}->resultset('Domains')
      ->search( $search_constraint, { columns => [qw/id name create_time update_time close_time/], }, );
  
    my $result = $rs->first;
    my $rh = { 
        id => $result->id, 
        name => $result->name, 
        created => $self->tr_time_human($result->create_time),
        updated => $self->tr_time_human($result->update_time),
        closed => $self->tr_time_human($result->close_time),
    };
    
    $t->param( $rh );
    return $t->output;
}

# 

1;
