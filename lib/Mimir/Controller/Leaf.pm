package Mimir::Controller::Leaf;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->leaf_view($self->param('leaf_id'))
    );
}

sub add {
    my $self = shift;

    my $node_id = $self->param('node_id');
    $self->model->leaf_add(
        node_id => $node_id,
        content => $self->param('content'),
    );

    $self->redirect_to("/node/$node_id");
}

1;
