#!/usr/bin/env perl

use Test::Most;
use WebService::NationBuilder;
use Data::Dumper;
use Carp qw(croak);

my @ARGS = qw(NB_ACCESS_TOKEN NB_SUBDOMAIN);
for (@ARGS) {croak "$_ not in ENV" unless defined $ENV{$_}};
my %params = map { (lc substr $_, 3) => $ENV{$_} } @ARGS;

subtest 'get sites' => sub {
    my $nb = WebService::NationBuilder->new(%params);
    diag Dumper $nb;
    is 1 => 1;
};

done_testing;
