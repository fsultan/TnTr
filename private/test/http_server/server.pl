#!/usr/bin/perl -I../../lib

use CGI::Application::Dispatch::Server;

my $server = CGI::Application::Dispatch::Server->new(
            port => '8888',
            class => 'TnTr::Dispatch',
            root_dir => $ENV{TNTR_APP_BASE},
);
$server->run;
