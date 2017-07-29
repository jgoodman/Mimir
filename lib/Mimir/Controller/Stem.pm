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
        $self->current_user,
        title => $self->param('title'),
    );

    $self->redirect_to("/");
}

sub update_status {
    my $self = shift;

    my $success = $self->model->stem_update_status(
        stem_id   => $self->param('stem_id'),
        status_id => $self->param('status_id'),
    );

    $self->render(json => { success => $success });
}

1;
