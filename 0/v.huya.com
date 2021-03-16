#!/usr/bin/perl -w
#DOMAIN : v.huya.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2021-03-17 04:12
#UPDATED: 2021-03-17 04:12
#TARGET : ___TARGET___
#URLRULE: 2.0
package MyPlace::URLRule::Rule::___ID___;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

=method1
sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
	   'pages_limit'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}
=cut

use MyPlace::WWW::Utils qw/get_url get_safename url_getname new_url_data/;
use MyPlace::JSON qw/decode_json/;
sub api_url {
	return 
		'https://v-api-player-ssl.huya.com/' . 
		'?r=vhuyaplay%2Fvideo&format=mp4%2Cm3u8' .
		'&vid=' . join("&",@_) . 
		'&_=' . time();
}
sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $vid;
	if($url =~ m/\/play\/(\d+)/) {
		$vid = $1;
	}
	return (error=>"Invalid video page") unless($vid);
	my $res = get_url(api_url($vid),'-v');
	my $info = decode_json($res);
	return (error=>"Error paring JSON result") unless($info);
	return (error=>$info->{message}) if($info->{code} != 1);
	return (error=>"No result found") unless($info->{result} and $info->{result}->{items});
	my @video;
	foreach(@{$info->{result}->{items}}) {
		next if($_->{format} eq 'm3u8');
		if($_->{definition} eq 'yuanhua') {
			@video = ($_->{transcode}->{urls}->[0]);			
			last;
		}
		if($_->{definition} eq '1300') {
			@video = ($_->{transcode}->{urls}->[0]);			
		}
		else {
			@video = ($_->{transcode}->{urls}->[0]);			
		}
	}
	my $html = get_url($url,"-v");
	my $author;
	my $date;
	my $title;
	if($html =~ m/<h3>([^<]+)/) {
		$author = get_safename($1);
	}
	if($html =~ m/<span class='detail-date'>([^<]+)/) {
		$date = $1;
		$date =~ s/[-: ]+//g;
	}
	if($html =~ m/class="video-title">([^<]+)/) {
		$title = get_safename($1);
	}
	else {
		$title = "play";
	}
	$title = $date . "_" . $title if($date);
	$title = $author . "_" . $title if($author);

    my @data;
    my @pass_data;
	if($info->{result}->{cover}) {
		push @data,$info->{result}->{cover} . "\t" . $title . ".jpg";
	}
	foreach(@video) {
		push @data,$_ . "\t" . $title . ".mp4";
	}
    #my @html = split(/\n/,$html);
    return (
		#info=>$info,
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        title=>undef,
    );
}

return new MyPlace::URLRule::Rule::___ID___;
1;

__END__

#       vim:filetype=perl



