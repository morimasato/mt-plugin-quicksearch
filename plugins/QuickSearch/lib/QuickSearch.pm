package QuickSearch;

use strict;
use warnings;
use Data::Dumper;

use MT::Util qw( trim offset_time_list );
use Time::Local qw( timelocal );

use LWP::UserAgent;
use HTTP::Request::Common;
use JSON;
use Encode;

our $QUICKSEARCH_URI = 'https://www.quick-solution.com/';

sub __full_text_search_plugin
{
    my ( $plugin, $method, $content_key, $api_secret_key, $document_id, $query ) = @_;
    my $uri;
    my $req;
    if ( $method eq 'PUT' ) {
        $uri = sprintf "%scontent/%s/index/", $QUICKSEARCH_URI, $content_key;
        $req = HTTP::Request::Common::POST( $uri, \%$query );
        $req->method('PUT');
        $req->header( 'X-FTS-API-Key' => $api_secret_key );
    }else{
        $uri = sprintf "%scontent/%s/", $QUICKSEARCH_URI, $content_key;
        $req = HTTP::Request::Common::GET( $uri );
        $req->header( 'X-FTS-API-Key' => $api_secret_key );
    }

    my $ua  = LWP::UserAgent->new;
    eval { $ua->ssl_opts( verify_hostname => 0 ) };
    my $res = $ua->request( $req );

    require JSON;
    my $json;
    eval { $json = JSON::from_json($res->decoded_content); };
    if ( $res->is_success && $json && $json->{code} eq '0000' ) {
        return $json;
    }else{
        if ( $json && $json->{message} ) {
            $plugin->error( $plugin->translate( $json->{message} ) );
        }else{
            $plugin->error( $res->status_line );
        }
        return 0;
    }
}

sub __make_index
{
    my ( $plugin, @entries ) = @_;
    my $content_key = $plugin->get_config_value('content_key');
    my $api_secret_key = $plugin->get_config_value('api_secret_key');
    my @indexes;
    for ( @entries ) {
        push @indexes, {
            'method' => $_->{method},
            'url' => $_->{url},
            'delay' => 1
        };
    }
    return unless @indexes;

    my $query = {};
    require JSON;
    $query->{json} = JSON::to_json( \@indexes );
    return __full_text_search_plugin(
        $plugin,
        'PUT',
        $content_key,
        $api_secret_key,
        '',
        $query
    );
}

sub _post_save
{
    my ( $cb, $app, $obj, $original ) = @_;
    my $plugin  = MT->component('QuickSearch');
    return 1 unless $plugin->get_config_value('content_key') && $plugin->get_config_value('api_secret_key');

    if ( $obj->{column_values}->{'status'} eq MT::Entry::RELEASE() ) {
        my $entry = $obj->{column_values};
        $entry->{'method'} = 'create';
        $entry->{'url'} = $obj->permalink;
        push my @entries, $entry;
        __make_index( $plugin, @entries );
    }else{
        if ( $original->{column_values}->{'status'} ) {
            if ( $original->{column_values}->{'status'} eq MT::Entry::RELEASE() ) {
                my $entry = $obj->{column_values};
                $entry->{'method'} = 'delete';
                $entry->{'url'} = $obj->permalink;
                push my @entries, $entry;
                __make_index( $plugin, @entries );
            }
        }
    }
    1;
}

sub _post_delete
{
    my ( $cb, $app, $obj ) = @_;
    my $plugin  = MT->component('QuickSearch');
    return 1 unless $plugin->get_config_value('content_key') && $plugin->get_config_value('api_secret_key');

    if ( $obj->{column_values}->{'status'} eq MT::Entry::RELEASE() ) {
        my $entry = $obj->{column_values};
        $entry->{'method'} = 'delete';
        $entry->{'url'} = $obj->permalink;
        push my @entries, $entry;
        __make_index( $plugin, @entries );
    }
    1;
}

sub _save_config_filter {
    my ( $cb, $plugin, $data, $scope ) = @_;
    my $app = MT->instance;

    if ( $scope =~ /system/ ) {
        unless ( $data->{'content_key'} ) {
            return $plugin->error( $app->translate( 'Please enter some value for required \'[_1]\' field.', $app->translate('Content Key' )));
        }
        unless ( $data->{'api_secret_key'} ) {
            return $plugin->error( $app->translate( 'Please enter some value for required \'[_1]\' field.', $app->translate('Api Secret Key' )));
        }
        __full_text_search_plugin(
            $plugin,
            'GET',
            $data->{'content_key'},
            $data->{'api_secret_key'},
            '',
            {}
        );
    }
    1;
}

1;
