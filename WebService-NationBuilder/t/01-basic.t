use Test::Most;

use WebService::NationBuilder;
use Data::Dumper;
use Carp qw(croak);
use Log::Any::Adapter;
use Log::Dispatch;

my @ARGS = qw(NB_ACCESS_TOKEN NB_SUBDOMAIN);
for (@ARGS) {croak "$_ not in ENV" unless defined $ENV{$_}};
my %params = map { (lc substr $_, 3) => $ENV{$_} } @ARGS;

my $log = Log::Dispatch->new(
    outputs => [
        [
            'Screen',
            min_level => 'debug',
            stderr    => 1,
            newline   => 1,
        ]
    ],
);

Log::Any::Adapter->set(
    'Dispatch',
    dispatcher => $log,
);

subtest 'get sites' => sub {
    my $nb = WebService::NationBuilder->new(%params);
    diag Dumper $nb;
    #diag Dumper $nb->base_url;
    diag Dumper $nb->get_sites;
    is 1 => 1;
};

done_testing;
