package WebService::NationBuilder;

use Moo;
use HTTP::Request::Common qw(GET POST PUT);
use JSON qw(from_json to_json);
use LWP::UserAgent;

has access_token    => ( is => 'ro' );
has subdomain       => ( is => 'ro' );


#sub new {
#};
#use Moo;
#use namespace::clean;

#use Carp qw(croak);

1;
