package Mimir;
use Mojo::Base 'Mojolicious';

sub startup {
    my $self = shift;

    my $config = $self->plugin('Config');

    # Plugin
    my $app = $self->app;
    push @{ $app->plugins->namespaces }, 'Mimir::Plugin';
    $app->plugin(Model => $config->{model});

    $self->plugin('authentication' => {
        autoload_user   => 1,
        session_key     => 'mimirapp',
        load_user       => sub {
            my ($app, $uid) = @_;
            return $self->model->get_user_by_id($uid) if $uid;
            return undef;
        },
        validate_user   => sub {
            my ($app, $username, $pass, $extra) = @_;
            my $user = $self->model->get_user_by_name($username);
            return $user->{user_id} if ($username eq $user->{'name'} && $pass eq $user->{'pass'});
            return undef;
        },
    });


    # Routes
    my $r = $self->routes;

    $r->get('/')->to("stem#list");
    foreach my $table (qw(tag leaf node branch stem status)) {
        $r->get("/$table/:$table\_id")->to("$table#view");
    }

    $r->post("/stem")
      ->over(authenticated => 1)
      ->to("stem#add");

    $r->post("/stem/:stem_id/branch")
      ->over(authenticated => 1)
      ->to("branch#add");

    $r->post("/branch/:branch_id/node")
      ->over(authenticated => 1)
      ->to("node#add");

    $r->post("/node/:node_id/leaf")
      ->over(authenticated => 1)
      ->to("leaf#add");

    $r->post("/leaf/:leaf_id/tag")
      ->over(authenticated => 1)
      ->to("tag#add");

    $r->post("/leaf/:leaf_id/content")
      ->over(authenticated => 1)
      ->to("leaf#update");

    #$r->put("/api/leaf/:leaf_id/content")
      #->over(authenticated => 1)
      #->to("leaf#update");

    $r->put("/api/node/:node_id/order")
      ->over(authenticated => 1)
      ->to("node#update_order");

    $r->put("/api/node/:node_id/status")
      ->over(authenticated => 1)
      ->to("node#update_status");

    $r->get('/login')->to("account#login");
    $r->post('/login')->to("account#signin");
    $r->get('/logout')->to("account#signout");

    # Hooks
    $app->hook(before_dispatch => sub {
        my $c = shift;

        my $authenticated = $c->is_user_authenticated;
        $c->stash(is_authenticated => $authenticated);

        my $path = $c->req->url->path->to_abs_string;
        my ($class, $id) = $path =~ m{^/(\w+)/(\d+)};
        $c->stash(nav => $c->model->nav($c->current_user, $class, $id));
    });
}

1;
