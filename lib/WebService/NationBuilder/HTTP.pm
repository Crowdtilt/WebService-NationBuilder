package WebService::NationBuilder::HTTP;
use Moo::Role;

use HTTP::Request::Common qw(GET POST PUT DELETE);
use JSON qw(from_json to_json);
use LWP::UserAgent;
use List::Util qw(any pairgrep);
use Log::Any qw($log);

has timeout => (
    is      => 'ro',
    default => 10,
);
has retries => (
    is      => 'ro',
    default => 0,
);
has base_uri => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return sprintf 'https://%s.%s/api/%s',
            $self->subdomain, $self->domain, $self->version;
    },
);

my @qs_params = qw(page per_page total_pages email
                   first_name last_name phone mobile);

around qw(get put post get_all) => sub {
    my ($orig, $self, $path, $params) = @_;
    die 'Path is missing' unless $path;
    return $self->$orig($path, $params, @_);
};

sub get_all {
    my ($self, $path, $params) = @_;
    my $uri = $self->_request_uri($path, $params);
    my @results;
    $params ||= {};
    $params->{page} = 1;
    my $total_pages = 1;
    while ($params->{page} <= $total_pages) {
        my $content = $self->_req(GET $uri);
        $total_pages = $content->{total_pages};
        $params->{page}++;
        $uri = $self->_request_uri($path, $params);
        push @results, @{$content->{results}};
    }
    return \@results;
}

sub get {
    my ($self, $path, $params) = @_;
    my $uri = $self->_request_uri($path, $params);
    return $self->_req(GET $uri);
}

sub post {
    my ($self, $path, $body) = @_;
    my $uri = $self->_request_uri($path);
    return $self->_req(POST $uri, content => to_json $body);
}

sub put {
    my ($self, $path, $body) = @_;
    my $uri = $self->_request_uri($path);
    return $self->_req(PUT $uri, content => to_json $body);
}

sub delete {
    my ($self, $path) = @_;
    my $uri = $self->_request_uri($path);
    return $self->_req(DELETE $uri);
}

sub _req {
    my ($self, $req) = @_;
    $req->header(authorization => ('Bearer '. $self->access_token));
    $req->header(content_type => 'application/json');
    $req->header(accept => 'application/json');
    $self->_log_request($req);
    my $res = $self->ua->request($req);
    $self->_log_response($res);
    my $retries = $self->retries;
    while ($res->code =~ /^5/ and $retries--) {
        sleep 1;
        $res = $self->ua->request($req);
    }
    return undef if $res->code =~ /404|410/;
    return 1 if $res->code =~ /204/;
    return $res->content ? from_json($res->content) : 1;
}

has ua => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $ua = LWP::UserAgent->new();
        $ua->timeout($self->timeout);
        return $ua;
    },
);



sub _request_uri {
    my ($self, $path, $params) = @_;
    my $uri = URI->new($path =~ /^http/
        ? $path
        : $self->base_uri . '/' . $path);
    $uri->query_form(
        pairgrep { any { $a eq $_ } @qs_params } %{$params}
    ) if $params && ref $params eq 'HASH';
    return $uri;
}

sub _log_request {
    my ($self, $req) = @_;
    $log->trace($req->method . ' => ' . $req->uri);
    my $content = $req->content;
    return unless length $content;
    eval { $content = to_json from_json $content };
    $log->trace($content);
}

sub _log_response {
    my ($self, $res) = @_;
    $log->trace($res->status_line);
    my $content = $res->content;
    eval { $content = to_json from_json $content };
    $log->trace($content);
}

1;
