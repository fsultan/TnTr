#!/user/bin/perl -w -I../../lib

use TnTrDB::Schema;
use Data::Dumper;
use Digest::SHA1;
use strict;

my $schema = TnTrDB::Schema->connect('dbi:SQLite:test.db');

my @domains = ( ['domain0'], ['domain1'] );

$schema->populate( 'Domains', [ [qw/name/], @domains, ] );

#----------------------------
my %domain_clients = (
    'client01' => 'domain0',
    'client02' => 'domain0',
    'client03' => 'domain0',
    'client11' => 'domain1',
    'client12' => 'domain1',
    'client13' => 'domain1',
);

my @clients;
foreach my $client ( keys %domain_clients ) {
    my $domain =
      $schema->resultset('Domains')
      ->search( { name => $domain_clients{$client} } );
    push @clients, [ $client, $domain->first->id ];
}

$schema->populate( 'Clients', [ [qw/name domain/], @clients, ] );

#----------------------------
my %groups = (
    'group0' => {
        name => 'Group 0',
        domain => 'domain0',
    },
    'group1' => {
        name => 'Group 1',
        domain => 'domain1',
    },
);

my @groups;
foreach my $groupname (keys %groups ) {
    my $domain = $schema->resultset('Domains')
        ->search( { name => $groups{$groupname}->{'domain'} } );
    push @groups, [ $groups{$groupname}->{'name'},  $domain->first->id ];

$schema->populate( 'Groups', [ [qw/name domain /], @groups, ]);

