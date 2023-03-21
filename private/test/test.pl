#!/user/bin/perl -w -I../lib/
use TnTrDB::Schema;
use Data::Dumper;

use strict;

my $user_id = 3;

my $schema = TnTrDB::Schema->connect('dbi:SQLite:DB/test.db');
$schema->storage->debug(1);

#$self->{schema}->resultset('Users')->find( { username => $username }, { columns => [qw/domain/], }, );
my $auth_user = $schema->resultset('Users')->find( { id => $user_id}, { columns => [qw/id name domain/], },);

print 'Name: ', $auth_user->name, "\n";

print 'Domain: ', $auth_user->domain->id, "\n";

my $projects = $schema->resultset('Projects')->search(
    { 'domain.id' => $auth_user->domain->id, },
    { join        => { client => 'domain', }, },
);

my @project_list;
foreach my $project ( $projects->all ) {
   my $rh = {
       id           => $project->id,
       user         => $project->user->username,
       name         => $project->name,
       description  => $project->description,
       client       => $project->client->name,
       };
   push @project_list, $rh;
}

print Dumper \@project_list;
