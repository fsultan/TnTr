#!/user/bin/perl -w

use TnTrDB::Schema;
use Data::Dumper;
use strict;

my $schema = TnTrDB::Schema->connect('dbi:SQLite:test.db');

my @domains = ( ['domain0'], ['domain1'] );

$schema->populate( 'Domains', [ [qw/name/], @domains, ] );

#----------------------------
my %domain_clients = (
    'client01' => 'domain0',
    'client02' => 'domain0',
    'client11' => 'domain1',
    'client12' => 'domain1',
);

my @clients;
foreach my $client ( keys %domain_clients ) {
    my $domain =
      $schema->resultset('Domains')
      ->search( { name => $domain_clients{$client} } );
    print 'found ' . $domain->first->name . " for client $client\n";
    push @clients, [ $client, $domain->first->id ];
}

$schema->populate( 'Clients', [ [qw/name domain/], @clients, ] );

#----------------------------
my %domain_users = (
    'user01' => 'domain0',
    'user02' => 'domain0',
    'user11' => 'domain1',
    'user12' => 'domain1',
);

my @users;
foreach my $user ( keys %domain_users ) {
    my $domain =
      $schema->resultset('Domains')
      ->search( { name => $domain_users{$user} } );
    print 'found ' . $domain->first->name . " for user $user\n";
    push @users, [ $user, $domain->first ];
}

$schema->populate( 'Users', [ [qw/name domain/], @users, ] );

#----------------------------
my %client_projects = (
    'project01' => 'client01',
    'project02' => 'client02',
    'project11' => 'client01',
    'project12' => 'client02',
);

my @projects;

foreach my $project ( keys %client_projects ) {
    my $client =
      $schema->resultset('Clients')
      ->search( { name => $client_projects{$project} } );
    my $description = $project . ' for ' . $client->first->name;
    push @projects, [ $project, $client->first, $description ];
}

$schema->populate( 'Projects', [ [qw/name client description/], @projects ] );

#----------------------------
my %project_tasks = (
    'task01' => 'project01',
    'task02' => 'project02',
    'task11' => 'project01',
    'task12' => 'project02',
);

my @tasks;

foreach my $task ( keys %project_tasks ) {
    my $project =
      $schema->resultset('Projects')
      ->search( { name => $project_tasks{$task} } );
    my $description = $task. ' for ' . $project->first->name;
    push @tasks, [ $task, $project->first, $description];
}

$schema->populate( 'Tasks', [ [qw/name project description/], @tasks] );

#----------------------------
my %task_times = (
    'time01' => 'task01',
    'time02' => 'task02',
    'time11' => 'task01',
    'time12' => 'task02',
);
my %user_times = (
    'time01' => 'user01',
    'time02' => 'user02',
    'time11' => 'user01',
    'time12' => 'user02',
);

my @times;

foreach my $time ( keys %task_times ) {
    my $task =
      $schema->resultset('Tasks')
      ->search( { name => $task_times{$time} } );
    my $user = $schema->resultset('Users')->search( {name=> $user_times{$time} } );
    my $description = $time . ' for ' . $task->first->name;
    push @times, [ $time, $task->first, $user->first, $description ];
}

$schema->populate( 'Times', [ [qw/name task user description/], @times, ] );


