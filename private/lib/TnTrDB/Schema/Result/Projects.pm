package TnTrDB::Schema::Result::Projects;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("DynamicDefault", "Core");
__PACKAGE__->table("projects");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "creator_id",
  {
  	data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "name",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "client",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "description",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "create_time",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
    dynamic_default_on_create => 'now',
  },
  "update_time",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
    dynamic_default_on_create => 'now',
    dynamic_default_on_update => 'now',
  },
  "close_time",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "client",
  "TnTrDB::Schema::Result::Clients",
  { id => "client" },
);
__PACKAGE__->belongs_to(
  "user",
  "TnTrDB::Schema::Result::Users",
  { id => "creator_id" },
);
__PACKAGE__->has_many(
  "tasks",
  "TnTrDB::Schema::Result::Tasks",
  { "foreign.project" => "self.id" },
);
__PACKAGE__->has_many(
  'project_group' => 'TnTrDB::Schema::Result::Project_Group', 'project'
);
__PACKAGE__->many_to_many(
  'groups' => 'project_group', 'gid'
);

#------------------------------------------

sub now {
    time
}


1;
