package TnTr::Main;

use strict;
use base 'TnTr';
use CGI::Application::Plugin::AutoRunmode;


sub welcome : StartRunmode {
    my $self = shift;
    my $q = $self->query;
    my $t = $self->load_tmpl('welcome.tpl');
    my $total_users =  $self->dbh->selectrow_array('select count(*) from users');
    my $total_projects =  $self->dbh->selectrow_array('select count(*) from projects');
    my $total_clients=  $self->dbh->selectrow_array('select count(*) from clients');
    $t->param(total_users => $total_users);
    $t->param(total_projects => $total_projects);
    $t->param(total_clients => $total_clients);
    return $t->output;
}

sub logout : Runmode {
    my $self = shift;
    $self->_logout;
}

sub login : Runmode {
    my $self = shift;
    $self->_login;
}
# 

1;
