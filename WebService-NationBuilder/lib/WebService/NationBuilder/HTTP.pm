package WebService::NationBuilder::HTTP;
use Moo::Role;

use HTTP::Request::Common qw(GET POST PUT);
use JSON qw(from_json to_json);
use LWP::UserAgent;
use Log::Any qw($log);

has timeout => (
    is      => 'ro',
    default => 10,
);
has retries => (
    is      => 'ro',
    default => 0,
);
has base_url => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return sprintf 'https://%s.%s/api/%s',
            $self->subdomain, $self->domain, $self->version;
    },
);

around qw(get put post) => sub {
    my ($orig, $self, $path) = @_;
    die 'Path is missing' unless $path;
    my $url = $self->_request_url($path);
    return $self->$orig($url, @_);
};

sub get {
    my ($self, $path) = @_;
    return $self->_req(GET $path);
}

sub post {
    my ($self, $path, $params) = @_;
    return $self->_req(POST $path, content => to_json $params);
}

sub put {
    my ($self, $path, $params) = @_;
    return $self->_req(PUT $path, content => to_json $params);
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

sub _request_url {
    my ($self, $path) = @_;
    return $path =~ /^http/ ? $path : $self->base_url . '/' . $path;
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
