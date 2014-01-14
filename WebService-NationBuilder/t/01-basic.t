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

subtest 'get_tags' => sub {
    for (@page_totals) {
        ok $nb->get_tags({per_page => $_}),
            sprintf $page_txt, $_;
    }
};

subtest 'match_person' => sub {
    for my $p (@{$nb->get_people}) {
        my $match_params = {};
        my @matches = qw(email first_name last_name phone mobile);
        for (@matches) {
            $match_params->{$_} = $p->{$_} if $p->{$_};
        }
        my $mp = $nb->match_person($match_params);
        cmp_bag [$mp], [superhashof($p)],
            "found matching person @{[$p->{email}]}"
            or diag explain $mp;
    }

    is $nb->match_person => undef,
        'unmatched person undef';

    is $nb->match_person({email => $max_id}) => undef,
        "unmatched person $max_id";
};

subtest 'get_person' => sub {
    for my $p (@{$nb->get_people}) {
        my $mp = $nb->get_person($p->{id});
        cmp_bag [$mp], [superhashof($p)],
            "found identified person @{[$p->{id}]}"
            or diag explain $mp;
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
