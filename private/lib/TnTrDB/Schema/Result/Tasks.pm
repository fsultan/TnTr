package TnTrDB::Schema::Result::Tasks;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("DynamicDefault", "Core");
__PACKAGE__->table("tasks");
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
  "project",
  {
    data_type => "INTERGER",
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
  "project",
  "TnTrDB::Schema::Result::Projects",
  { id => "project" },
);
__PACKAGE__->belongs_to(
  "user",
  "TnTrDB::Schema::Result::Users",
  { id => "creator_id" },
);
__PACKAGE__->has_many(
  "times",
  "TnTrDB::Schema::Result::Times",
  { "foreign.task" => "self.id" },
);

#------------------------------------------

sub now {
    time
}


1;
