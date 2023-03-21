package TnTr::DyHtml;

use strict;
use base 'TnTr';

# These run modes are not protected !!  check the session id!!
#

sub setup {     # overrides     # called after cgiapp_init()
    my $self = shift;
    $self->authen->protected_runmodes(':all');
}

sub default : StartRunmode {
    my $self = shift;
#    my $q = $self->query;
#    my $t = $self->load_tmpl('domains/default.tpl');
#    my $total_domains =  $self->dbh->selectrow_array('select count(*) from domains');
#    $t->param(total_domains => $total_domains);
#    return $t->output;
}

sub project_select_list : Runmode {
    my $self = shift;
    my $id_p = $self->query->param('client');

    $self->param('skip_set_default_t_params',1);
    my $t = $self->load_tmpl('times/create_project_select.tpl');

    $self->_load_schema;

    my $username = $self->authen->username; 
    warn "U from A:", $username;
    my $auth_user = $self->{schema}->resultset('Users')->find( { username => $username }, { columns => [qw/domain/], }, );

    #validate client for auth_user
#XXX should I be validating client_id here or in projects_for_client_rs ??
    my $client_id = $id_p;  #change this!!
    #generate list of projects
    $t->param(
        project_list => $self->projects_select_list(
                $self->projects_for_client_rs($auth_user,$client_id),
                undef),
        );
    $t->output;
#projects_for_client_rs
}

1;

