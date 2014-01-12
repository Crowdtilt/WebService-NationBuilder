package WebService::NationBuilder;
use Moo;
with 'WebService::NationBuilder::HTTP';

use Carp qw(croak);

has access_token => ( is => 'ro'                                 );
has subdomain    => ( is => 'ro'                                 );
has domain       => ( is => 'ro', default => 'nationbuilder.com' );
has version      => ( is => 'ro', default => 'v1'                );
has logger       => ( is => 'ro'                                 );

has sites_uri    => ( is => 'ro', default => '/v1/customers'     );

sub log {
    my ($self, $msg) = @_;
    return unless $self->logger;
    $self->logger->DEBUG("BP: $msg");
}

sub get_sites {
    my ($self) = @_;
    return $self->get($self->sites_uri);
}

1;
