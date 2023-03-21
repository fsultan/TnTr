package TnTrDB::Schema::Result::User_Group;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('user_group');

__PACKAGE__->add_columns(
  "user",
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
__PACKAGE__->set_primary_key(qw/user gid/);
__PACKAGE__->belongs_to('user' => 'TnTrDB::Schema::Result::Users');
__PACKAGE__->belongs_to('gid' => 'TnTrDB::Schema::Result::Groups');

