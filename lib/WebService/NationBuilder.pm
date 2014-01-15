package WebService::NationBuilder;

use strict;
use warnings;
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
    return $self->http_get_all($self->sites_uri, $params);
}

sub create_person {
    my ($self, $params) = @_;
    my $person = $self->http_post($self->people_uri, {
        person => $params });
    return $person ? $person->{person} : 0;
}

sub push_person {
    my ($self, $params) = @_;
    my $person = $self->http_put($self->people_uri . '/push', {
        person => $params });
    return $person ? $person->{person} : 0;
}

sub update_person {
    my ($self, $id, $params) = @_;
    croak 'The id param is missing' unless defined $id;
    my $person = $self->http_put($self->people_uri . "/$id", {
        person => $params });
    return $person ? $person->{person} : 0;
}

sub get_person {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    my $person = $self->http_get($self->people_uri . "/$id");
    return $person ? $person->{person} : 0;
}

sub delete_person {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    return $self->http_delete($self->people_uri . "/$id");
}

sub get_person_tags {
    my ($self, $id) = @_;
    croak 'The id param is missing' unless defined $id;
    my $taggings = $self->http_get($self->people_uri . "/$id/taggings");
    return $taggings ? $taggings->{taggings} : 0;
}

sub match_person {
    my ($self, $params) = @_;
    return $self->http_get($self->people_uri . '/match', $params)->{person};
}

sub get_people {
    my ($self, $params) = @_;
    return $self->http_get_all($self->people_uri, $params);
}

sub get_tags {
    my ($self, $params) = @_;
    return $self->http_get_all($self->tags_uri, $params);
}

sub set_tag {
    my ($self, $id, $tag) = @_;
    croak 'The id param is missing' unless defined $id;
    croak 'The tag param is missing' unless defined $tag;
    my $tagging = $self->http_put($self->people_uri . "/$id/taggings", {
        tagging => { tag => $tag },
    });
    return $tagging ? $tagging->{tagging} : 0;
}

sub delete_tag {
    my ($self, $id, $tag) = @_;
    croak 'The id param is missing' unless defined $id;
    croak 'The tag param is missing' unless defined $tag;
    return $self->http_delete($self->people_uri . "/$id/taggings/$tag");
}

# ABSTRACT: NationBuilder API bindings

1;
