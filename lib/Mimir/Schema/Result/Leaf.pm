package Mimir::Schema::Result::Leaf;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('leaf');
__PACKAGE__->add_columns(
    leaf_id => { data_type => 'integer', is_nullable => 0, },
    content => { data_type => 'text',    is_nullable => 0, },
    weight  => { data_type => 'integer', is_nullable => 1, },
    node_id => { data_type => 'integer', is_nullable => 1, },
    status_id => { data_type => 'integer', is_nullable => 1, },
);

__PACKAGE__->set_primary_key('leaf_id');
__PACKAGE__->belongs_to(node   => 'Mimir::Schema::Result::Node',    'node_id',    { join_type => 'left' });
__PACKAGE__->belongs_to(status => 'Mimir::Schema::Result::Status',  'status_id',  { join_type => 'left' });

__PACKAGE__->has_many(tags => 'Mimir::Schema::Result::TagLeaf', 'leaf_id');

1;
