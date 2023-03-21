package TnTrDB::Schema::Result::Domains;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("DynamicDefault", "Core");
__PACKAGE__->table("domains");
__PACKAGE__->add_columns(
  "id",
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
__PACKAGE__->has_many(
  "users",
  "TnTrDB::Schema::Result::Users",
  { "foreign.domain" => "self.id" },
);
__PACKAGE__->has_many(
  "clients",
  "TnTrDB::Schema::Result::Clients",
  { "foreign.domain" => "self.id" },
);

#------------------------------------------

sub now {
    time
}


1;
