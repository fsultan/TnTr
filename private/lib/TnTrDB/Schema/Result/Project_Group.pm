package TnTrDB::Schema::Result::Project_Group;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('project_group');

__PACKAGE__->add_columns(
  "project",
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
__PACKAGE__->set_primary_key(qw/project gid/);
__PACKAGE__->belongs_to('project' => 'TnTrDB::Schema::Result::Projects');
__PACKAGE__->belongs_to('gid' => 'TnTrDB::Schema::Result::Groups');

