use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Mimir');
$t->get_ok('/')
  ->status_is(200)
  ->content_like(qr{<h1>Stems</h1>});

$t->get_ok('/stem/1')
  ->status_is(200)
  ->content_like(qr{<h1>});

done_testing();
