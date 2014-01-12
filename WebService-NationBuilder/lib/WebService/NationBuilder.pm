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

sub request_url {
    my ($self, $path) = @_;
    return $path =~ /^http/ ? $path : $self->base_url . '/' . $path;
}

1;
