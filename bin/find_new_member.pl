#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Slack::Todolists;

my $config = do "$FindBin::Bin/../config/config.pl";

my $slack_todolists = Slack::Todolists->new($config);

my $ts_id = $slack_todolists->get_ts_id();

die unless $ts_id;

my $todolists = $slack_todolists->get_thread_message($ts_id);

for my $slack_id (keys %{$todolists}){
    if( ! exists $config->{name_mapping}->{$slack_id}){
        printf "slack_id: %s\n\t %s\n\n", $slack_id, $todolists->{$slack_id};
    }
}

exit;
