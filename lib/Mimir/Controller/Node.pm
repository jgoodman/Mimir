package Mimir::Controller::Node;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->node_view($self->param('node_id'))
    );
}

sub add {
    my $self = shift;

    my $branch_id = $self->param('branch_id');
    $self->model->node_add(
        branch_id => $branch_id,
        title     => $self->param('title'),
    );

    $self->redirect_to("/branch/$branch_id");
}

1;
