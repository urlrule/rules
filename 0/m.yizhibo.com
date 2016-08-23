#!/usr/bin/perl -w
#DOMAIN : m.yizhibo.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2016-05-21 01:41
#UPDATED: 2016-05-21 01:41
#TARGET : http://m.yizhibo.com/l/rIMHopz06mnam5sG.html
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_m_yizhibo_com;
use MyPlace::URLRule::Utils qw/get_url/;
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
sub safe_decode_json {
	my $json = eval { decode_json($_[0]); };
	if($@) {
		print STDERR "Error deocding JSON text:$@\n";
		$@ = undef;
		return {};
	}
	else {
		if($json->{reason}) {
			print STDERR "Error: " . $json->{reason},"\n";
		}
		return $json;
	}
}

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $scid = 0;
	if($url =~ m/\/([^\/]+)\.html/) {
		$scid = $1;
	}
	if(!$scid) {
		return (
			error=>"No ID guess from url",
		);
	}
	use JSON qw/decode_json/;
	my $jsontext = get_url('http://api.xiaoka.tv/live/web/get_play_live?scid=' . $scid,'-v');
#	print STDERR $jsontext,"\n";
	my $info = safe_decode_json($jsontext);
	$info = $info->{data};
	if(!$info->{linkurl}) {
		return {
			error=>"No play found, maybe invalid scid: $scid",
		}
	}
	my $date;
	if($info->{createtime}) {
		use POSIX qw(strftime);
		$date = strftime('%Y%m%d',localtime($info->{createtime}));
	}
	elsif($info->{cover}) {
		$date = $info->{cover};
		$date =~ s/^.*\/?(201\d\d\d\d\d)\/.*$/$1/;
	}
    my $title = $info->{linkurl};
	$title =~ s/http:\/\/[^\/]+\/[^\/]+\/(.+)\/[^\/]+\.m3u8/$1/;
	$title =~ s/\/+/_/g;
	$title = $date . "_" . $title if($date);
	$title = $title . "_" . $info->{title} if($info->{title});
    my @data;
	my $playurl = $info->{linkurl};
	$playurl =~ s/^http/hls/;
	push @data,$info->{cover} . "\t" . $title . ".png";
	push @data,$playurl . "\t" . $title . ".ts";
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::0_m_yizhibo_com;
1;

__END__

#       vim:filetype=perl


