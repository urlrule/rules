#!/usr/bin/perl -w
#DOMAIN : tom203.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-02-14 00:23
#UPDATED: 2020-02-14 00:23
#TARGET : https://tom203.com/guochanzipai/2018-10-17/12525.html
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_tom203_com;
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

use MyPlace::WWW::Utils qw/get_url get_safename create_title_utf8 url_getname strnum/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my $filename;
	foreach(@html) {
		if(m/<title>([^<]+)/) {
			$filename = create_title_utf8($1);
			$filename =~ s/^\s*正在播放：\s*//;
		}
		if(m/url=([^"&]+)/) {
			my $url = $1;
			if($url =~ m/^https:\/\/(play\.tomhd0\.com\/.*)$/) {
				$url = 'http://' . $1;
			}
			push @data,"$url\t$filename.ts";
			last;
		}
	}
	my $pics;
	if($html =~ m/pcjsons\s*=\s*\s*'\s*\[([^\]]+)/s) {
		$pics = $1;
	}
	elsif($html =~ m/<div[^>]+class="container xiezhen[^>]+>(.+?)<\/div>/s) {
		$pics = $1;
	}
	if($pics) {
		my $n = 0;
		while($pics =~ m/"([^"]+)"/g) {
			$n++;
			my $img = $1;
			my $ext = $img;
			$ext =~ s/.*\.//;
			$ext = $ext ?  ".$ext"  : ".jpg";
			push @data,$img . "\t" . strnum($n,4) . $ext;
		}
		$title = $filename;
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::0_tom203_com;
1;

__END__

#       vim:filetype=perl


