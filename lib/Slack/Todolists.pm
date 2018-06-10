package Slack::Todolists;
use strict;
use warnings;
use utf8;

use parent 'Class::Accessor::Fast';

use JSON::XS;
use Encode;
use LWP::UserAgent;
use LWP::Protocol::https;
use DBIx::Sunny;

__PACKAGE__->mk_ro_accessors(qw(
    slack_token
    channel_id
    reminder_title
    channel_count
    name_mapping
    db_config
    ua
));

sub new {
    my ($class, $options) = @_;
    $options->{ua} = LWP::UserAgent->new();
    $options->{ua}->timeout(10);

    return $class->SUPER::new($options);
}

sub get_ts_id {
    my $self = shift;
    my $url = sprintf('https://slack.com/api/channels.history?token=%s&channel=%s&count=%s',
        $self->slack_token,
        $self->channel_id,
        $self->channel_count
    );

    my $req = HTTP::Request->new('GET', $url);
    $req->header('Content-Type' => 'application/x-www-form-urlencoded');

    my $response = $self->ua->request($req);

    my $ret_content = JSON::XS::decode_json( $response->content );

    my $ts_id = '';
    for my $message ( @{$ret_content->{messages}}){
        if( $self->is_reminder_title($message->{text}) ){
            $ts_id = $message->{ts};
            last;
        }
    }
    return $ts_id;
}

sub is_reminder_title{
    my ($self, $text) = @_;
    return (defined $text && $text =~ $self->reminder_title);
}

sub get_thread_message{
    my ($self, $ts_id) = @_;
    my $url = sprintf('https://slack.com/api/channels.replies?token=%s&channel=%s&thread_ts=%s',
        $self->slack_token,
        $self->channel_id,
        $ts_id
    );

    my $req = HTTP::Request->new('GET', $url);
    $req->header( 'Content-Type' => 'application/x-www-form-urlencoded' );

    my $response = $self->ua->request($req);
    my $ret_content = JSON::XS::decode_json( $response->content );

    my $todolists = {};
    for my $content ( @{$ret_content->{messages}}){
        next if $self->is_reminder_title($content->{text});
        $todolists->{ $content->{user} } = Encode::encode_utf8($content->{text});
    }

    return $todolists;
}

sub save_data{
    my ($self, $todolists) = @_;

    my $db = $self->connect_db();

    for my $user ( keys %{$todolists} ){
        $db->query('INSERT INTO todolists (date,name,tasks) VALUES( NOW(), ?, ? )', $user, $todolists->{$user} );
    }
}

sub is_user{
    my ($self, $path) = @_;
    $path =~ s!\A/!!;

    for my $key ( keys %{$self->name_mapping}){
        return $key if $path eq $self->name_mapping->{$key};
    }
    return;
}

sub get_all{
    my ($self) = @_;

    my$db = $self->connect_db();

    my $selected = $db->select_all('SELECT * FROM todolists ORDER BY date DESC');

    my @contents;
    for my $row (@{$selected}){
        $row->{name} = $self->name_mapping->{ $row->{name} };
        push @contents, $row;
    }
    return \@contents;
}

sub get_by_user{
    my ($self, $user) = @_;

    my$db = $self->connect_db();

    my $selected = $db->select_all('SELECT * FROM todolists WHERE name = ? ORDER BY date DESC', $user);

    my @content_by_user;
    for my $row (@{$selected}){
        push @content_by_user, {
            date => $row->{date},
            tasks => $row->{tasks}
        };
    }
    return \@content_by_user;
}

sub connect_db{
    my $self = shift;

    return DBIx::Sunny->connect(
        sprintf('DBI:mysql:database=%s;host=%s;port=%s',
            $self->db_config->{database},
            $self->db_config->{host},
            $self->db_config->{port}),
        $self->db_config->{user},
        $self->db_config->{pass}
    );
}

1;
