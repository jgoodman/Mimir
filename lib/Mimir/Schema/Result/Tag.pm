package Mimir::Schema::Result::Tag;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tag');
__PACKAGE__->add_columns(
    tag_id  => { data_type => 'integer', is_nullable => 0, },
    name    => { data_type => 'text',    is_nullable => 0, },
);

__PACKAGE__->set_primary_key('tag_id');

__PACKAGE__->has_many('tag_leaves', 'Mimir::Schema::Result::TagLeaf', 'tag_id');

1;
