package Mimir::Model;
use Mojo::Base -base;
use Mimir::Schema;

has schema => sub {
    # TODO: config connect settings
    return Mimir::Schema->connect('dbi:SQLite:data/' . ($ENV{MOJO_MODE} || 'test') . '.db');
};

sub get_user_by_id {
    my $self = shift;
    my $res  = $self->schema->resultset('User')->single({user_id => shift});
    my %resp;
    foreach (qw(user_id name pass)) { $resp{$_} = $res ? $res->$_ : '' }
    return \%resp;
}

sub get_user_by_name {
    my $self = shift;
    my $res  = $self->schema->resultset('User')->single({name => shift});
    my %resp;
    foreach (qw(user_id name pass)) { $resp{$_} = $res ? $res->$_ : '' }
    return \%resp;
}

sub nav {
    my $self  = shift;
    my $user  = shift;
    my $field = shift;
    my $id    = shift;

    my $active_stem_rs;
    my $active_branch_rs;
    if($id) {
        my $res = $self->schema->resultset(ucfirst($field))->single({"$field\_id" => $id});
        if($field eq 'stem') {
            $active_stem_rs   = $res;
        }
        elsif($field eq 'branch') {
            $active_stem_rs   = $res->stem;
            $active_branch_rs = $res;
        }
        elsif($field eq 'node') {
            $active_stem_rs   = $res->branch->stem;
            $active_branch_rs = $res->branch;
        }
        elsif($field eq 'leaf') {
            $active_stem_rs   = $res->node->branch->stem;
            $active_branch_rs = $res->node->branch;
        }
    }

    my @stems;
    #my $stems_rs = $self->schema->resultset('Stem')->search({user_id => $user->{'user_id'}}); # TODO
    my $stems_rs = $self->schema->resultset('Stem')->search();
    while (my $stem_rs = $stems_rs->next) {
        push @stems, {
            stem_id => $stem_rs->stem_id,
            title   => $stem_rs->title,
            active  => ($active_stem_rs && $active_stem_rs->stem_id == $stem_rs->stem_id) ? 1 : 0,
        };
    }

    my @branches;
    if($active_stem_rs) {
        my $branches_rs = $active_stem_rs->branches;
        while (my $branch_rs = $branches_rs->next) {
            push @branches, {
                branch_id => $branch_rs->branch_id,
                title     => $branch_rs->title,
                active    => ($active_branch_rs && $active_branch_rs->branch_id == $branch_rs->branch_id) ? 1 : 0,
            };
        }
    }

    my @statuses;
    my $statuses_rs = $self->schema->resultset('Status')->search();
    while (my $status_rs = $statuses_rs->next) {
        push @statuses, {
            status_id => $status_rs->status_id,
            name      => $status_rs->name,
            color     => $status_rs->color,
        };
    }

    return {
        stems    => [ ], #\@stems, #TODO remove this entirely
        branches => \@branches,
        statuses => \@statuses,
        ($active_stem_rs ? (stem_id  => $active_stem_rs->stem_id) : ())
    };
}

sub stem_list {
    my $self = shift;

    my @stems;
    my $stems_rs = $self->schema->resultset('Stem')->search();
    while (my $stem_rs = $stems_rs->next) {
        push @stems, { stem_id => $stem_rs->stem_id, title => $stem_rs->title };
    }

    return(
        stems => \@stems,
    );
}

sub stem_view {
    my $self = shift;
    return();
}

sub stem_add {
    my $self = shift;
    my $user = shift;
    my %args = @_;

    my $stem_rs = $self->schema->resultset('Stem')->create({
        title   => $args{title},
        user_id => $user->{'user_id'}
    });

    return();
}

sub branch_add {
    my $self = shift;
    my %args = @_;

    my $stem_id = $args{stem_id};
    my $weight  = $self->schema
                       ->resultset('Branch')
                       ->search({stem_id => $stem_id})
                       ->get_column('weight')
                       ->max;

    my $branch_rs = $self->schema->resultset('Branch')->create({
        stem_id => $stem_id,
        title   => $args{title},
        weight  => ++$weight,
    });

    return(
        branch_id => $branch_rs->branch_id,
        title     => $branch_rs->title,
        nodes     => [ ],
    );
}

sub branch_view {
    my $self = shift;
    my $branch_rs = $self->schema->resultset('Branch')->single({branch_id => shift});

    my @nodes;
    my $nodes_rs = $branch_rs->nodes;
    while (my $node_rs = $nodes_rs->next) {
        push @nodes, { $self->node_view($node_rs->node_id) };
    }

    my $branch_id = $branch_rs->branch_id;
    return(
        branch_id    => $branch_id,
        title        => $branch_rs->title,
        nodes        => \@nodes,
    );
}

sub node_add {
    my $self = shift;
    my %args = @_;

    my $branch_id = $args{branch_id};
    my $weight    = $self->schema
                         ->resultset('Node')
                         ->search({branch_id => $branch_id})
                         ->get_column('weight')
                         ->max;

    my $node_rs = $self->schema->resultset('Node')->create({
        branch_id => $branch_id,
        title     => $args{title},
        weight    => ++$weight,
    });

    return(
        node_id => $node_rs->node_id,
        title   => $node_rs->title,
        leaves  => [ ],
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
        node_status => $node_rs->status ? $node_rs->status->name : '',
        leaves  => \@leaves,
    );
}

sub node_update_status {
    my $self = shift;
    my %args = @_;

    my $node_id    = $args{node_id}   // die 'no node_id';
    my $status_id  = $args{status_id};
    $status_id = undef if defined $status_id && $status_id eq '';

    my $node_rs = $self->schema->resultset('Node')->single({node_id => $node_id});
    $node_rs->update({status_id => $status_id});

    return 1;
}

sub node_update_order {
    my $self = shift;
    my %args = @_;

    my $node_id    = $args{node_id}   // die 'no node_id';
    my $old_index  = $args{old_index} // die 'no old_index';
    my $new_index  = $args{new_index} // die 'no new_index';

    my $leaf_rs = _get_leaf_by_weight($self, $old_index, $node_id) || die 'Unable to locate leaf';

    my $guard = $self->schema->txn_scope_guard;

    my $i = $new_index;
    if($new_index > $old_index) {
        # ascending
        while($i > $old_index) {
            my $sib_leaf_rs = _get_leaf_by_weight($self, $i--, $node_id) || next;
            $sib_leaf_rs->update({weight => $i});
        }
    }
    else {
        # descending
        while($i < $old_index) {
            my $sib_leaf_rs = _get_leaf_by_weight($self, $i++, $node_id) || next;
            $sib_leaf_rs->update({weight => $i});
        }

    }

    $leaf_rs->update({weight => $new_index});

    $guard->commit;

    return 1;
}

sub _get_leaf_by_weight {
    my ($self, $weight, $node_id) = @_;
    $self->schema->resultset('Leaf')->single({
        node_id => $node_id,
        weight  => $weight,
    });
}

sub leaf_add {
    my $self = shift;
    my %args = @_;

    my $node_id = $args{node_id};
    my $weight  = $self->schema
                       ->resultset('Leaf')
                       ->search({node_id => $node_id})
                       ->get_column('weight')
                       ->max;

    my $leaf_rs = $self->schema->resultset('Leaf')->create({
        node_id => $node_id,
        content => $args{content},
        weight  => ++$weight,
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

sub leaf_update {
    my $self = shift;
    my %args = @_;

    my $leaf_rs = $self->schema
                       ->resultset('Leaf')
                       ->single({leaf_id => $args{'leaf_id'}})
                       ->update({content => $args{'content'}});

    return(
        node_id => $leaf_rs->node_id,
        leaf_id => $leaf_rs->leaf_id,
        content => $leaf_rs->content,
    );
}

sub status_view {
    my $self = shift;
    my $id_or_name  = shift;

    my $field  = ($id_or_name =~ m/^\d+$/) ? 'status_id' : 'name';
    my $status_rs = $self->schema->resultset('Status')->single({$field => $id_or_name});

    my %branches;

    my $nodes = $status_rs->nodes;
    while (my $node_rs = $nodes->next) {
        my $branch_id = $node_rs->branch->branch_id;
        $branches{$branch_id} ||= {
            branch_id => $branch_id,
            title     => $node_rs->branch->title,
            nodes     => [ ],
        };
        push @{$branches{$branch_id}->{'nodes'}}, {
            node_id => $node_rs->node_id,
            title   => $node_rs->title,
        };
    }

    my @branches;
    foreach my $branch_id (sort keys %branches) {
        push @branches, $branches{$branch_id};
    }

    return(
        status_id => $status_rs->status_id,
        name      => $status_rs->name,
        branches  => \@branches,
    );
}

sub status_add {
    my $self = shift;
    my %args = @_;

    my $status_rs = $self->schema->resultset('Status')->create({
        name  => $args{'name'},
        color => $args{'color'},
    });

    return(
        status_id => $status_rs->status_id,
        name      => $status_rs->name,
        color     => $status_rs->color,
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
