use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Mimir');

$t->get_ok('/branch/1')
  ->status_is(200)
  ->content_like(qr{<h1>});

done_testing();
