#!/usr/bin/perl -w
#DOMAIN : fi11.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2020-02-24 00:12
#UPDATED: 2020-02-24 00:12
#TARGET : https://www.hxcpp4.com/player.aspx?math=1&id=14076
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_fi11_com;
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

use MyPlace::WWW::Utils qw/get_url decode_title get_safename url_getname/;
use JSON;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $id = $url;
	if($id =~ m/[?&]id=(\d+)/) {
		$id = $1;
	}
	elsif($id =~ m/(\d+)/) {
		$id = $1;
	}
	
    my @data;
    my @pass_data;
    #my @html = split(/\n/,$html);
	my $data = get_url('https://www.cthxc.com/Video/GetInfo','-v',
		"--header",'Content-Type: application/json;charset=utf-8',
		'-d','{"VideoID":"' . $id . '","UserID":1,"ClientType":1}'
	);
	my $json = JSON->new();
	my $info = $json->decode($data);
	if(!$info->{data}) {
		return (error=>"Failed getting video information",info=>$info);
	}
	$info = $info->{data};
	return $info;
	my $title = decode_title($info->{Name},'utf8');
	$title = $title ? $id . "_" . $title : $id;
	$title =~ s/【含羞草.*】|含羞草推荐：//g;
	my $video = $info->{Url} || $info->{PreUrl};
	if($video) {
		push @data,"m3u8:" . ($info->{Url} || $info->{PreUrl}) . "#inc\t" . $title . ".ts";
	}
	if($info->{CoverImgUrl}) {
		push @data,$info->{CoverImgUrl} . "\t" . $title . ".jpg";
	}
    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
    );
}

return new MyPlace::URLRule::Rule::0_fi11_com;
1;

__END__

#       vim:filetype=perl


