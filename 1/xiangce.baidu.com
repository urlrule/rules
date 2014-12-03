#!/usr/bin/perl -w
#http://xiangce.baidu.com/album/data/listall/4211332674?_=1417630042216
#Thu Dec  4 02:49:57 2014
use strict;
no warnings 'redefine';


=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
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
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $uid;
	if($url =~ m/\/album\/data\/listall\/(\d+)/) {
		#http://xiangce.baidu.com/album/data/listall/4211332674?_=1417630042216
		$uid = $1;
	}
	elsif($url =~ m/\/u\/(\d+)/) {
		$uid = $1;
	}
	else {
		my $page = get_url($url,'-v');
		if($page =~ m/owner:\s*\{[^\{]*"user_sign":"(\d+)"/) {
			$uid = $1;
		}
	}
	return (
		error=>'Can not detect UID from URL:' . $url
	) unless($uid);

	$url = "http://xiangce.baidu.com/album/data/listall/$uid?_=" . time();
	my $html = get_url($url,'-v');
    my @pass_data;
	while($html =~ m/"album_sign"\s*:\s*"([^"]+)/g) {
		push @pass_data,'http://xiangce.baidu.com/picture/album/list/' .
			 $1;
	}
    return (
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$uid,
    );
}

=cut

1;

__END__

#       vim:filetype=perl
