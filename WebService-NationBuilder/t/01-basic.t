use Test::Most;

use WebService::NationBuilder;
use Data::Dumper;
use Carp qw(croak);
use Log::Any::Adapter;
use Log::Dispatch;

my @ARGS = qw(NB_ACCESS_TOKEN NB_SUBDOMAIN);
for (@ARGS) {croak "$_ not in ENV" unless defined $ENV{$_}};
my %params = map { (lc substr $_, 3) => $ENV{$_} } @ARGS;

sub _enable_logging {
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
}

my $nb = WebService::NationBuilder->new(%params);
#_enable_logging;

subtest 'get sites' => sub {
    is $nb->get_sites->[0]{slug}, $params{subdomain},
        'Nationbuilder slug matches subdomain';

    ok $nb->get_sites({per_page => 1}),
        'Paginating with 1 page';

    ok $nb->get_sites({per_page => 100}),
        'Paginating with 100 pages';
};




done_testing;
