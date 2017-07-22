package Mimir::Schema::Result::TagLeaf;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tag_leaf');
__PACKAGE__->add_columns(
    tag_id   => { data_type => 'integer', is_nullable => 0, },
    leaf_id  => { data_type => 'integer', is_nullable => 0, },
);

__PACKAGE__->add_unique_constraint([ qw/tag_id leaf_id/ ]);
__PACKAGE__->belongs_to(tag  => 'Mimir::Schema::Result::Tag',   'tag_id',   { join_type => 'left' });
__PACKAGE__->belongs_to(leaf => 'Mimir::Schema::Result::Leaf',  'leaf_id',  { join_type => 'left' });

1;
