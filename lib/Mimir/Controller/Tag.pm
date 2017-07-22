package Mimir::Controller::Tag;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->tag_view($self->param('tag_id'))
    );
}

1;
