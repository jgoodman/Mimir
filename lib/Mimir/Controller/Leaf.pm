package Mimir::Controller::Leaf;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->leaf_view($self->param('leaf_id'))
    );
}

1;
