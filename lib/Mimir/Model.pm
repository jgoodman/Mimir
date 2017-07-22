package Mimir::Model;
use Mojo::Base -base;
use Mimir::Schema;

has schema => sub {
    # TODO: config connect settings
    return Mimir::Schema->connect('dbi:SQLite:' . ($ENV{MOJO_MODE} || 'test') . '.db');
};

sub branch_view {
    my $self = shift;
    my $branch_rs = $self->schema->resultset('Branch')->single({branch_id => shift});

    my @nodes;
    my $nodes_rs = $branch_rs->nodes;
    while (my $node_rs = $nodes_rs->next) {
        push @nodes, { $self->node_view($node_rs->node_id) };
    }

    return(
        branch_id => $branch_rs->branch_id,
        title     => $branch_rs->title,
        nodes     => \@nodes,
    );
}

sub node_view {
    my $self = shift;
    my $node_rs = $self->schema->resultset('Node')->single({node_id => shift});

    my @leaves;
    my $leaves_rs = $node_rs->leaves;
    while (my $leaf_rs = $leaves_rs->next) {
        push @leaves, {
            leaf_id => $leaf_rs->leaf_id,
            content => $leaf_rs->content
        };
    }

    return(
        node_id => $node_rs->node_id,
        title   => $node_rs->title,
        leaves  => \@leaves,
    );
}

sub leaf_add {
    my $self = shift;
    my %args = @_;

    my $leaf_rs = $self->schema->resultset('Leaf')->create({
        node_id => $args{node_id},
        content => $args{content},
    });

    return(
        leaf_id => $leaf_rs->leaf_id,
        content => $leaf_rs->content,
        tags    => [ ],
    );
}

sub leaf_view {
    my $self = shift;

    my $leaf_rs = $self->schema->resultset('Leaf')->single({leaf_id => shift});

    my @tag_names;
    my $tags = $leaf_rs->tags;
    while (my $tag = $tags->next) {
        push @tag_names, $tag->tag->name;
    }

    return(
        leaf_id => $leaf_rs->leaf_id,
        content => $leaf_rs->content,
        tags    => \@tag_names,
    );
}

sub tag_view {
    my $self = shift;
    my $id_or_name  = shift;

    my $field  = ($id_or_name =~ m/^\d+$/) ? 'tag_id' : 'name';
    my $tag_rs = $self->schema->resultset('Tag')->single({$field => $id_or_name});

    my @leaves;
    my $tag_leaves = $tag_rs->tag_leaves;
    while (my $tag_leaf_rs = $tag_leaves->next) {
        push @leaves, {$self->leaf_view($tag_leaf_rs->leaf->leaf_id)};
    }

    return(
        tag_id  => $tag_rs->tag_id,
        name    => $tag_rs->name,
        leaves  => \@leaves,
    );
}

sub tag_add {
    my $self = shift;
    my %args = @_;

    my $tag_rs = $self->schema->resultset('Tag')->find_or_create({
        name => $args{'name'},
    });

    my $tag_leaf_rs = $self->schema->resultset('TagLeaf')->find_or_create({
        tag_id  => $tag_rs->tag_id,
        leaf_id => $args{leaf_id},
    });

    return(
        leaf_id => $tag_leaf_rs->leaf_id,
        tag_id  => $tag_leaf_rs->tag_id,
    );
}


1;
