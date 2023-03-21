use DBI;
use SQL::Translator;
use strict;

my $dbh = DBI->connect('dbi:SQLite:test.db') or die $DBI::errstr;

if ($dbh){
    print "Connected $dbh\n";
    print join(" ", $dbh->selectrow_array("select * from projects"));
    print "\n\n";
}

my $t = SQL::Translator->new(
    parser  => 'DBI',
    dbh     =>  $dbh,
    producer => 'MySQL',
);

if (! defined $t){ 
    print "T NOT DEFINED\n";
 }
 
print $t->translate;

