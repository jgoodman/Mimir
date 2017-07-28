package Mimir::Schema::Result::Status;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('status');
__PACKAGE__->add_columns(
    status_id   => { data_type => 'integer', is_nullable => 0, },
    name        => { data_type => 'text',    is_nullable => 0, },
    color       => { data_type => 'text',    is_nullable => 1, },
);

__PACKAGE__->set_primary_key('status_id');

__PACKAGE__->has_many(leaves   => 'Mimir::Schema::Result::Leaf',   'status_id');
__PACKAGE__->has_many(nodes    => 'Mimir::Schema::Result::Node',   'status_id');
__PACKAGE__->has_many(branches => 'Mimir::Schema::Result::Branch', 'status_id');
__PACKAGE__->has_many(stems    => 'Mimir::Schema::Result::Stem',   'status_id');

1;
