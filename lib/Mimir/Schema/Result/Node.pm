package Mimir::Schema::Result::Node;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('node');
__PACKAGE__->add_columns(
    node_id   => { data_type => 'integer', is_nullable => 0, },
    title     => { data_type => 'text',    is_nullable => 1, },
    weight    => { data_type => 'integer', is_nullable => 1, },
    branch_id => { data_type => 'integer', is_nullable => 1, },
);

__PACKAGE__->set_primary_key('node_id');
__PACKAGE__->belongs_to(branch  => 'Mimir::Schema::Result::Branch',  'branch_id',  { join_type => 'left' });

__PACKAGE__->has_many(leaves => 'Mimir::Schema::Result::Leaf', 'node_id', { order_by => { -asc => [qw/weight leaf_id/]} });

1;
