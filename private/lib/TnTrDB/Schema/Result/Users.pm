package TnTrDB::Schema::Result::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("DynamicDefault", "Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "username",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "password",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "domain",
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
  "domain",
  "TnTrDB::Schema::Result::Domains",
  { id => "domain" },
);
__PACKAGE__->has_many(
  "times",
  "TnTrDB::Schema::Result::Times",
  { "foreign.user" => "self.id" },
);
#__PACKAGE__->has_many(
#  "clients",
#  "TnTrDB::Schema::Result::Clients",
#  { "foreign.user" => "self.id" },
#);
__PACKAGE__->has_many(
  "projects",
  "TnTrDB::Schema::Result::Projects",
  { "foreign.user" => "self.id" },
);
__PACKAGE__->has_many(
  "tasks",
  "TnTrDB::Schema::Result::Tasks",
  { "foreign.user" => "self.id" },
);
__PACKAGE__->has_many(
  'user_group' => 'TnTrDB::Schema::Result::User_Group', 'user'
);
__PACKAGE__->many_to_many(
  'groups' => 'user_group', 'gid'
);
__PACKAGE__->has_many(
  'user_role' => 'TnTrDB::Schema::Result::User_Role', 'user'
);
__PACKAGE__->many_to_many(
  'roles' => 'user_role', 'role'
);
#------------------------------------------

sub now {
    time
}


1;
