package Mimir;
use Mojo::Base 'Mojolicious';

sub startup {
    my $self = shift;

    my $config = $self->plugin('Config');

    # Plugin
    my $app = $self->app;
    push @{ $app->plugins->namespaces }, 'Mimir::Plugin';
    $app->plugin(Model => $config->{model});


    # Routes
    my $r = $self->routes;
    $r->get('/')->to("stem#list");
    foreach my $table (qw(tag leaf node branch stem)) {
        $r->get("/$table/:$table\_id")->to("$table#view");
    }
    $r->post("/stem")->to("stem#add");
    $r->post("/stem/:stem_id/branch")->to("branch#add");
    $r->post("/branch/:branch_id/node")->to("node#add");
    $r->post("/node/:node_id/leaf")->to("leaf#add");
    $r->post("/leaf/:leaf_id/tag")->to("tag#add");

    $r->post("/leaf/:leaf_id/content")->to("leaf#update");
    $r->put("/leaf/:leaf_id/content")->to("leaf#update");
    $r->put("/api/node/:node_id/order")->to("node#update_order");


    # Hooks
    $app->hook(before_dispatch => sub {
        my $c = shift;
        my $path = $c->req->url->path->to_abs_string;
        my ($class, $id) = $path =~ m{^/(\w+)/(\d+)};
        $c->stash(nav => $c->model->nav($class, $id));
    });
}

1;
