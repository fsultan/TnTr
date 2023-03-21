#!/user/bin/perl -w -I../../lib/

use TnTrDB::Schema;
use Data::Dumper;
##use Digest::SHA1;
use strict;
#
#my $user_id = 1;

my $schema = TnTrDB::Schema->connect('dbi:SQLite:test.db');

#my $schema = My::Schema->connect($dsn);
    $schema->create_ddl_dir(['MySQL', 'SQLite', 'PostgreSQL'],
    '0.1',
    './dbscriptdir/'
);
