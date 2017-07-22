package Mimir::Controller::Tag;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->tag_view($self->param('tag_id'))
    );
}

sub add {
    my $self = shift;

    my $leaf_id = $self->param('leaf_id');
    $self->model->tag_add(
        leaf_id => $leaf_id,
        name    => $self->param('name'),
    );

    $self->redirect_to("/leaf/$leaf_id");
}

1;
