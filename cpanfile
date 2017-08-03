requires 'Mojolicious';
requires 'IO::Socket::SSL';
requires 'Mojolicious::Plugin::Authentication';
requires 'DBI';
requires 'DBD::SQLite';
requires 'DBIx::Class';
requires 'DBIx::Class::DeploymentHandler';
requires 'Tie::IxHash';
requires 'Text::Markdown';
on 'develop' => sub {
    requires 'TAP::Formatter::JUnit';
};
