package TnTrDB::Schema::Result::Roles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("DynamicDefault", "Core");
__PACKAGE__->table("roles");
__PACKAGE__->add_columns(
  "id",
  { data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "name", {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "level", {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
  'user_role' => 'TnTrDB::Schema::Result::User_Role', 'role'
);
__PACKAGE__->many_to_many(
  'users' => 'user_role', 'user'
);


#------------------------------------------

sub now {
    time
}


1;
