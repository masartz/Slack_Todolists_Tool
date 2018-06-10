use strict;
use warnings;
use utf8;
use JSON::XS;
use FindBin;
use lib "$FindBin::Bin/lib";
use Slack::Todolists;

my $app = sub {
    my $env = shift;

    my $config = do "$FindBin::Bin/config/config.pl";
    my $slack_todolists = Slack::Todolists->new($config);

    if ( $env->{PATH_INFO} eq '/all' ) {
        my $data = $slack_todolists->get_all();
        return response_success($data);
    }
    elsif( my $user = $slack_todolists->is_user($env->{PATH_INFO}) ){
        my $data = $slack_todolists->get_by_user($user);
        return response_success($data);
    }

    return [404,
        ['Content-Type'=>'application/json; charset=UTF-8'],
        [JSON::XS::encode_json({})]
    ];
};

sub response_success{
    my $data = shift;

    return [200,
        ['Content-Type'=>'application/json; charset=UTF-8'],
        [JSON::XS::encode_json({data => $data})]
    ];
}

