package Mimir::Controller::Branch;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->branch_view($self->param('branch_id'))
    );
}

1;
