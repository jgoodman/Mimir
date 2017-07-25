package Mimir::Schema::Result::User;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('user');
__PACKAGE__->add_columns(
    user_id  => { data_type => 'integer', is_nullable => 0, },
    name     => { data_type => 'text',    is_nullable => 0, },
    pass     => { data_type => 'text',    is_nullable => 0, },
);

__PACKAGE__->set_primary_key('user_id');

__PACKAGE__->has_many('stems', 'Mimir::Schema::Result::Stem', 'user_id');

1;
