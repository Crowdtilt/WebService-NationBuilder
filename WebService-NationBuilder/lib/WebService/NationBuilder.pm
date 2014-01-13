package WebService::NationBuilder;
use Moo;
with 'WebService::NationBuilder::HTTP';

use Carp qw(croak);

has access_token => ( is => 'ro'                                 );
has subdomain    => ( is => 'ro'                                 );
has domain       => ( is => 'ro', default => 'nationbuilder.com' );
has version      => ( is => 'ro', default => 'v1'                );

has sites_uri    => ( is => 'ro', default => 'sites'             );
has people_uri   => ( is => 'ro', default => 'people'            );

sub get_sites {
    my ($self, $params) = @_;
    return $self->get_all($self->sites_uri, $params);
}

sub get_person {
    my ($self, $id) = @_;
    return $self->get($self->people_uri . "/$id")->{person};
}

sub get_people {
    my ($self, $params) = @_;
    return $self->get_all($self->people_uri, $params);
}


1;
