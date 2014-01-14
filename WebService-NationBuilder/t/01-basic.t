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
my $page_txt = 'Paginating with %s page(s)';
my @page_totals = (1, 10, 100, 1000);
my $max_id = 10000;
#_enable_logging;

subtest 'get_person' => sub {
    for (@{$nb->get_people}) {
        cmp_bag [$nb->get_person($_->{id})], [superhashof($_)],
            "found matching person @{[$_->{id}]}"
            or diag explain $_;
    }

    dies_ok { $nb->get_person }
        'id param missing';

    is $nb->get_person($max_id) => undef,
        "undefined person $max_id";
};

subtest 'get_people' => sub {
    for (@page_totals) {
        ok $nb->get_people({per_page => $_}),
            sprintf $page_txt, $_;
    }
};

subtest 'get_sites' => sub {
    is $nb->get_sites->[0]{slug}, $params{subdomain},
        'nationbuilder slug matches subdomain';

    for (@page_totals) {
        ok $nb->get_sites({per_page => $_}),
            sprintf $page_txt, $_;
    }
};



done_testing;
