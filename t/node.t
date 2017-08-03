use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Mimir');
$t->get_ok('/node/2')
  ->status_is(200)
  ->content_like(qr{<h2>});

done_testing();
