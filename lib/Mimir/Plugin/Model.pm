package Mimir::Plugin::Model;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
    my ($self, $app, $conf) = @_;

    $app->log->info("Loading class $conf->{class}...");
    eval "require $conf->{class}";
    die $@ if $@;

    my $model = $conf->{class}->new();

    $app->helper(model => sub { $model });
}

1;
