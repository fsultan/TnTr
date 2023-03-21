#!/usr/bin/perl -w -I../../lib
#
use TnTrDB::Schema;
use Data::Dumper;
#use Digest::SHA1;
use strict;

my $search_id = 1;

my $schema = TnTrDB::Schema->connect('dbi:SQLite:test.db');
$schema->storage->debug(1);

#$schema->_load_schema();

my $search_constraint = [{ id => $search_id },];

my $rs =
  $schema->resultset('UserRights')
      ->search( $search_constraint, { columns => [qw/id user rm rights/], }, );
my $result = $rs->first;

 my $rh = {
               id => $result->id,
               user => $result->user->name,
               rm => $result->rm,
               rights => $result->rights,
           };

print "******\n\n";
print Dumper $rh;

my $rs2 = $schema->resultset('UserRights')->search(
    {
        'rights_rms.name' => 'create'
    },
    {
        join => { 'rights_rms' => 'rights_apps' },
        '+select' => ['rights_rms.name','rights_apps.name'],
        '+as' => ['RightsRmsName','RightsAppsName'],
    });
my $r = $rs2->first;
#print "this should be ",  $rs2->first->id, " rm: ", $rs2->first->get_column('RightsRmsName'), " app : ", $rs2->first->get_column('RightsAppsName'),"\n";
print "this should be ",  $r->id, " rm: ", $r->get_column('RightsRmsName'), " app : ", $r->get_column('RightsAppsName'), " for ", $r->user->username, "\n";
#print "hmm : ", $r->rm->name ,"\n";


my $rs3 = $schema->resultset('UserRights')->find(1);

print "a :", $rs3->rm;

print "\n";

