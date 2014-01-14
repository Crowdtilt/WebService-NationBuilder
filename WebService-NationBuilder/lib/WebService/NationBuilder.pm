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
has tags_uri     => ( is => 'ro', default => 'tags'              );

sub get_sites {
    my ($self, $params) = @_;
    return $self->get_all($self->sites_uri, $params);
}

sub get_person {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    my $person = $self->get($self->people_uri . "/$id");
    return $person->{person} if $person;
}

sub match_person {
    my ($self, $params) = @_;
    # TODO: add params whitelist here
    return $self->get($self->people_uri . '/match', $params)->{person};
}

sub get_people {
    my ($self, $params) = @_;
    return $self->get_all($self->people_uri, $params);
}

sub get_tags {
    my ($self, $params) = @_;
    return $self->get_all($self->tags_uri, $params);
}


1;
