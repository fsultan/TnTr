#!/user/bin/perl -w -I../../lib

use TnTrDB::Schema;
use Data::Dumper;
use Digest::SHA1;
use strict;

my $schema = TnTrDB::Schema->connect('dbi:SQLite:test.db');
$schema->storage->debug(1);

my @domains = ( ['domain0'], ['domain1'] );

$schema->populate( 'Domains', [ [qw/name/], @domains, ] );

#----------------------------

my %users = (
    'user01' => {
        domain => 'domain0',
        name    => 'user 01',
        password => 'google',
    },
    'user02' => {
        domain => 'domain0',
        name    => 'user 02',
        password => 'google',
    },
    'user03' => {
        domain => 'domain0',
        name    => 'user 03',
        password => 'google',
    },
    'user11' => {
        domain => 'domain1',
        name    => 'user 11',
        password => 'google',
    },
    'user12' => {
        domain => 'domain1',
        name    => 'user 12',
        password => 'google',
    },
    'user13' => {
        domain => 'domain1',
        name    => 'user 13',
        password => 'google',
    },
);

my @users;
foreach my $username ( keys %users ) {
    my $domain =
      $schema->resultset('Domains')
      ->search( { name => $users{$username}->{'domain'} } );
    push @users, [ 
    		$username, 
    		Digest::SHA1::sha1_base64($users{$username}->{'password'}), 
    		$domain->first->id, 
    		$users{$username}->{'name'}, ];
}

$schema->populate( 'Users', [ [qw/username password domain name/], @users, ] );

#----------------------------
my %domain_clients = (
    'client01' => {
    	domain => 'domain0',
    	user   => 'user01',
    },
    'client02' => {
    	domain => 'domain0',
    	user   => 'user01',
    },
    'client03' => {
    	domain => 'domain0',
    	user   => 'user01',
    },
    'client11' => {
    	domain => 'domain1',
    	user   => 'user11',
    },
    'client12' => {
    	domain => 'domain1',
    	user   => 'user11',
    },
    'client13' => {
    	domain => 'domain1',
    	user   => 'user11',
    },
);

my @clients;
foreach my $client ( keys %domain_clients ) {
    my $domain =
      $schema->resultset('Domains')
      ->search( { name => $domain_clients{$client}->{'domain'} } );
    my $user = $schema->resultset('Users')->search( { username => $domain_clients{$client}->{'user'} }, { columns => [qw/id/], }, );
    push @clients, [ $client, $user->first->id, $domain->first->id ];
}

$schema->populate( 'Clients', [ [qw/name creator_id domain/], @clients, ] );

#----------------------------
my %groups = (
    'group0' => {
        name => 'Group 0',
        domain => 'domain0',
        user  => 'user01',
    },
    'group1' => {
        name => 'Group 1',
        domain => 'domain1',
        user  => 'user11',
    },
);

my @groups;
foreach my $groupname (keys %groups ) {
    my $domain = $schema->resultset('Domains')
        ->search( { name => $groups{$groupname}->{'domain'} } );
    my $user = $schema->resultset('Users')->search( { username => $groups{$groupname}->{'user'} }, { columns => [qw/id/], }, );
    push @groups, [ $groups{$groupname}->{'name'},  $user->first->id, $domain->first->id ];
}
$schema->populate( 'Groups', [ [qw/name creator_id domain /], @groups, ]);


#----------------------------
my @user_groups;

foreach my $username (keys %users){
	my $user = $schema->resultset('Users')->search( { username => $username }, { columns => [qw/id domain/], }, );
	my $user_id = $user->first->id;
	my $domain_id = $user->first->domain->id;
	my $group = $schema->resultset('Groups')->search( { domain => $domain_id }, { columns => [qw/id/], }, );
	my $group_id = $group->first->id;
	push @user_groups, [$user_id, $group_id];
}
$schema->populate( 'User_Group', [ [qw/user gid/], @user_groups, ]);

#----------------------------
my %client_projects = (
    'project01' => {
    	client => 'client01',
    	user   => 'user01',
    },
    'project02' => {
    	client => 'client02',
    	user   => 'user01',
    },
    'project03' => {
    	client => 'client02',
    	user   => 'user01',
    },
    'project11' => {
    	client => 'client11',
    	user   => 'user11',
    },
    'project12' => {
    	client => 'client11',
    	user   => 'user11',
    },
    'project13' => {
    	client => 'client12',
    	user   => 'user11',
    },
);

my @projects;

foreach my $project ( keys %client_projects ) {
    my $client =
      $schema->resultset('Clients')
      ->search( { name => $client_projects{$project}->{'client'} } );
    my $description = $project . ' for ' . $client->first->name;
    my $user = $schema->resultset('Users')->search( { username => $client_projects{$project}->{'user'} }, { columns => [qw/id/], }, );
    push @projects, [ $project, $user->first->id, $client->first, $description ];
}

$schema->populate( 'Projects', [ [qw/name creator_id client description/], @projects ] );

#----------------------------
my %project_tasks = (
    'task01' => {
    	project => 'project01',
    	user   => 'user01',
    },
    'task02' => {
    	project => 'project02',
    	user   => 'user01',
    },
    'task03' => {
    	project => 'project01',
    	user   => 'user01',
    },
    'task11' => {
    	project => 'project11',
    	user   => 'user11',
    },
    'task12' => {
    	project => 'project11',
    	user   => 'user11',
    },
    'task13' => {
    	project => 'project12',
    	user   => 'user11',
    },
);

my @tasks;

foreach my $task ( keys %project_tasks ) {
    my $project =
      $schema->resultset('Projects')
      ->search( { name => $project_tasks{$task}->{'project'} } );
    my $description = $task. ' for ' . $project->first->name;
    my $user = $schema->resultset('Users')->search( { username => $project_tasks{$task}->{'user'} }, { columns => [qw/id/], }, );
    push @tasks, [ $task, $user->first->id, $project->first, $description];
}

$schema->populate( 'Tasks', [ [qw/name creator_id project description/], @tasks] );

#----------------------------
my %task_times = (
    'time01' => { 
        task => 'task01',
        user => 'user01',
        start_datetime => '2009-10-01T12:00:00Z',
        end_datetime => '2009-10-01T14:00:00Z',
    },
    'time02' => { 
        task => 'task02',
        user => 'user02',
        start_datetime => '2009-10-03T14:00:00Z',
        end_datetime => '2009-10-03T16:00:00Z',
    },
    'time03' => { 
        task => 'task01',
        user => 'user01',
        start_datetime => '2009-10-03T17:00:00Z',
        end_datetime => '2009-10-03T19:00:00Z',
    },
    'time04' => { 
        task => 'task02',
        user => 'user02',
        start_datetime => '2009-10-08T17:00:00Z',
        end_datetime => '2009-10-08T18:30:00Z',
    },
    'time05' => { 
        task => 'task01',
        user => 'user01',
        start_datetime => '2009-10-02T17:00:00Z',
        end_datetime => '2009-10-02T19:00:00Z',
    },
    'time06' => { 
        task => 'task02',
        user => 'user02',
        start_datetime => '2009-10-03T17:00:00Z',
        end_datetime => '2009-10-03T18:30:00Z',
    },
    'time12' => { 
        task => 'task12',
        user => 'user13',
        start_datetime => '2009-10-09T10:00:00Z',
        end_datetime => '2009-10-09T11:00:00Z',
    },
    'time13' => { 
        task => 'task12',
        user => 'user13',
        start_datetime => '2009-10-12T17:00:00Z',
        end_datetime => '2009-10-12T18:00:00Z',
    },
);

my @times;

foreach my $time ( keys %task_times ) {
    my $task =
      $schema->resultset('Tasks')
      ->search( { name => $task_times{$time}->{'task'} } );
    my $user = $schema->resultset('Users')->search( {username=> $task_times{$time}->{'user'} } );
    my $description = $time . ' for ' . $task->first->name;
    push @times, [ $time, $task->first->id, $user->first->id, $description, $task_times{$time}->{'start_datetime'}, $task_times{$time}->{'end_datetime'} ];
}

$schema->populate( 'Times', [ [qw/name task user description start_datetime end_datetime/], @times, ] );

my %roles = (
	'role01' => {
		name => 'superuser',
		level => '1',
	#	user => 'user01',
	},
);

my @roles;
foreach my $role ( keys %roles ) {
    #my $user = $schema->resultset('Users')->search( { username => $roles{$role}->{'user'}  }, { columns => [qw/id/], }, );
    push @roles, [ $roles{$role}->{'name'}, $roles{$role}->{'level'} ];
}

$schema->populate( 'Roles', [ [qw/name level/], @roles, ] );

#----------------------------
my %user_roles = (
    'role01' => {
    	role => 'superuser',
    	user   => 'user01',
    },
    'role02' => {
    	role => 'clientadmin',
    	user   => 'user02',
    },
    'role03' => {
    	role => 'siteadmin',
    	user   => 'user02',
    },
);

my @user_roles;
foreach my $create_role (keys %user_roles ) {
	my $user = $schema->resultset('Users')->search( { username => $user_roles{$create_role}->{'user'}  }, { columns => [qw/id/], }, );
    my $role = $schema->resultset('Roles')->search( { name => $user_roles{$create_role}->{'role'} }, { columns => [qw/id/], }, );
	push @user_roles, [ $user->first->id, $role->first->id ];
}
$schema->populate( 'User_Role', [ [qw/user role/], @user_roles, ] );
