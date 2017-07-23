package Mimir::Controller::Stem;
use Mojo::Base 'Mojolicious::Controller';

sub list {
    my $self = shift;
    return $self->render(
        $self->model->stem_list()
    );
}

sub view {
    my $self = shift;
    return $self->render(
        $self->model->stem_view($self->param('stem_id'))
    );
}

sub add {
    my $self = shift;

    $self->model->stem_add(
        title => $self->param('title'),
    );

    $self->redirect_to("/");
}

1;