package Mimir::Controller::Account;
use Mojo::Base 'Mojolicious::Controller';

sub signin {
    my $self = shift;
    $self->authenticate(
        $self->param('user'),
        $self->param('pass'),
    );
    return $self->redirect_to("/");
}

sub signout {
    my $self = shift;
    $self->logout;
    return $self->redirect_to("/");
}

1;
