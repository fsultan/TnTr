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
    push @users, [ $username, Digest::SHA1::sha1_base64($users{$username}->{'password'}), $domain->first->id, $users{$username}->{'name'} ];
}

$schema->populate( 'Users', [ [qw/username password domain name/], @users, ] );


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
$schema->populate( 'Groups', [ [qw/name user domain /], @groups, ]);


#----------------------------
my @user_groups;

foreach my $username (keys %users){
	my $user = $schema->resultset('Users')->search( { username => $username }, { columns => [qw/id domain/], }, );
	my $user_id = $user->first->id;
    warn "user id is $user_id\n";
	my $domain_id = $user->first->domain->id;
    warn "domain id is $domain_id\n";
	my $group = $schema->resultset('Groups')->search( { domain => $domain_id }, { columns => [qw/id/], }, );
	my $group_id = $group->first->id;
    warn "group id is $group_id\n";
	push @user_groups, [$user_id, $group_id];
}
$schema->populate( 'User_Group', [ [qw/user gid/], @user_groups, ]);

