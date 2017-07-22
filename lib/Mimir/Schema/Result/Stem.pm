package Mimir::Schema::Result::Stem;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('stem');
__PACKAGE__->add_columns(
    stem_id => { data_type => 'integer', is_nullable => 0, },
    title   => { data_type => 'text',    is_nullable => 1, },
    weight  => { data_type => 'integer', is_nullable => 1, },
);

__PACKAGE__->set_primary_key('stem_id');

__PACKAGE__->has_many('branches', 'Mimir::Schema::Result::Branch', 'stem_id', { order_by => { -asc => [qw/weight node_id/]} });

1;
