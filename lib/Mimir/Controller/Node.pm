package Mimir::Controller::Node;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->node_view($self->param('node_id'))
    );
}

1;
