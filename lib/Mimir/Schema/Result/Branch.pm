package Mimir::Schema::Result::Branch;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('branch');
__PACKAGE__->add_columns(
    branch_id => { data_type => 'integer', is_nullable => 0, },
    title     => { data_type => 'text',    is_nullable => 1, },
    weight    => { data_type => 'integer', is_nullable => 1, },
    stem_id   => { data_type => 'integer', is_nullable => 1, },
);

__PACKAGE__->set_primary_key('branch_id');
__PACKAGE__->belongs_to(stem  => 'Mimir::Schema::Result::Stem',  'stem_id',  { join_type => 'left' });

__PACKAGE__->has_many(nodes => 'Mimir::Schema::Result::Node', 'branch_id', { order_by => { -asc => [qw/weight node_id/]} });

1;
