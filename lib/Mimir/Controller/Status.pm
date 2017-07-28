package Mimir::Controller::Status;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->status_view($self->param('status_id'))
    );
}

sub add {
    my $self = shift;

    my $status = $self->model->status_add(
        name  => $self->param('name'),
        color => $self->param('color'),
    );

    my $status_id = $status->{'status_id'};

    $self->redirect_to("/status/$status_id");
}

1;
