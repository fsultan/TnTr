package TnTrDB::Schema::Result::Times;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( "DynamicDefault", "Core" );
__PACKAGE__->table("times");
__PACKAGE__->add_columns(
    "id",
    {
        data_type     => "INTEGER",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },
    "name",
    {
        data_type     => "TEXT",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },
    "user",
    {
        data_type     => "INTEGER",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },
    "task",
    {
        data_type     => "INTEGER",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },
    "description",
    {
        data_type     => "TEXT",
        default_value => undef,
        is_nullable   => 0,
        size          => undef,
    },
    "start_datetime",
    {
        data_type     => "INTEGER",
        default_value => undef,
        is_nullable   => 1,
        size          => undef,
    },
    "end_datetime",
    {
        data_type     => "INTEGER",
        default_value => undef,
        is_nullable   => 1,
        size          => undef,
    },
    "create_time",
    {
        data_type                 => "INTEGER",
        default_value             => undef,
        is_nullable               => 1,
        size                      => undef,
        dynamic_default_on_create => 'now',
    },
    "update_time",
    {
        data_type                 => "INTEGER",
        default_value             => undef,
        is_nullable               => 1,
        size                      => undef,
        dynamic_default_on_create => 'now',
        dynamic_default_on_update => 'now',
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
    "user",
    "TnTrDB::Schema::Result::Users",
    { id => "user" },
);
__PACKAGE__->belongs_to(
    "task",
    "TnTrDB::Schema::Result::Tasks",
    { id => "task" },
);

#------------------------------------------

sub now {
    time;
}

1;
