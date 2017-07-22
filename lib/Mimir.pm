package Mimir;
use Mojo::Base 'Mojolicious';

sub startup {
    my $self = shift;

    my $config = $self->plugin('Config');

    my $app = $self->app;
    push @{ $app->plugins->namespaces }, 'Mimir::Plugin';
    $app->plugin(Model => $config->{model});

    my $r = $self->routes;
    $r->get('/')->to(cb => sub {
         my $c = shift;
         $c->reply->static('index.html')
    });

    foreach my $table (qw(tag leaf node branch stem)) {
        $r->get("/$table/:$table\_id")->to("$table#view");
    }
    $r->post("/branch/:branch_id/node")->to("node#add");
    $r->post("/node/:node_id/leaf")->to("leaf#add");
    $r->post("/leaf/:leaf_id/tag")->to("tag#add");

    $r->put("/api/node/:node_id/order")->to("node#update_order");
}

1;
