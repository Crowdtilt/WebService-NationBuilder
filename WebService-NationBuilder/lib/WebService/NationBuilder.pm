package WebService::NationBuilder;

use Moo;
use HTTP::Request::Common qw(GET POST PUT);
use JSON qw(from_json to_json);
use LWP::UserAgent;

has access_token => ( is => 'ro' );
has subdomain => ( is => 'ro' );
has domain  => (
    is      => 'ro',
    default => 'nationbuilder.com',
);
has version => (
    is      => 'ro',
    default => 'v1',
);
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

around qw(get) => sub {
    my ($orig, $self, $path) = @_;
    die 'Path is missing' unless $path;
    my $url = $self->_request_url($path);
    return $self->$orig($url, @_);
};

sub get {
    my ($self, $path) = @_;
    return $self->_req(GET $path);
}

sub _req {
    my ($self, $req) = @_;
    $req->header(authorization => ('Bearer '. $self->access_token));
    $req->header(content_type => 'application/json');
    $req->header(accept => 'application/json');
    my $res = $self->ua->request($req);
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

1;
