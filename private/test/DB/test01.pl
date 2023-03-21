#!/user/bin/perl -w -I../../lib/

use TnTrDB::Schema;
use Data::Dumper;
#use Digest::SHA1;
use strict;

my $user_id = 1;

my $schema = TnTrDB::Schema->connect('dbi:SQLite:test.db');
$schema->storage->debug(1);

#$self->{schema}->resultset('Users')->find( { username => $username }, { columns => [qw/domain/], }, );
my $rs = $schema->resultset('Users')->find( { id => $user_id}, { columns => [qw/id name domain/], },);

print 'Name: ', $rs->name, "\n";

print 'Domain: ', $rs->domain->id, "\n";
