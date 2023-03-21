package TnTrDB::Schema::Result::Client_Group;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('client_group');

__PACKAGE__->add_columns(
  "client",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "gid",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key(qw/client gid/);
__PACKAGE__->belongs_to('client' => 'TnTrDB::Schema::Result::Clients');
__PACKAGE__->belongs_to('gid' => 'TnTrDB::Schema::Result::Groups');

