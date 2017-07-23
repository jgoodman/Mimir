package Mimir::Controller::Branch;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    return $self->render(
        $self->model->branch_view($self->param('branch_id'))
    );
}

sub add {
    my $self = shift;

    my %hash = $self->model->branch_add(
        stem_id => $self->param('stem_id'),
        title   => $self->param('title'),
    );

    $self->redirect_to('/branch/'.$hash{'branch_id'});
}

1;
