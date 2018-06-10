use strict;
use warnings;
use Test::More;
use Slack::Todolists;

subtest 'is_reminder_title' => sub{
    my $slack_todolists = Slack::Todolists->new({
        reminder_title => qr/\ATest/
    });

    ok $slack_todolists->is_reminder_title('Test');
    ok ! $slack_todolists->is_reminder_title('test');
    ok ! $slack_todolists->is_reminder_title('aTest');
};

subtest 'is_user' => sub{
    my $slack_todolists = Slack::Todolists->new({
        name_mapping => {
             slack_id_1 => 'foo',
             slack_id_2 => 'bar',
        }
    });

    is $slack_todolists->is_user('/foo'), 'slack_id_1';
    is $slack_todolists->is_user('/bar'), 'slack_id_2';
    ok ! $slack_todolists->is_user('fooo');
    ok ! $slack_todolists->is_user('/baz');
    ok ! $slack_todolists->is_user('//bar');
};
done_testing();
