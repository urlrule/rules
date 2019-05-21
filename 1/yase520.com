#!/usr/bin/perl -w
#DOMAIN : yase520.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-02-03 14:57
#UPDATED: 2019-02-03 14:57
#TARGET : https://9.yase520.com/ 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_9_yase520_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

use MyPlace::URLRule::Utils qw/get_url extract_title url_getinfo url_getfull/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $rurl = $url;
	$rurl =~ s/\/\/[^\/]*yase520\.com/\/\/www.yase9.com/;
	$rurl =~ s/\/\/www\.yase9\.com/\/\/www2.yasedd.com/;
	my $html = get_url($rurl,'-v');
    my @data;
	my ($base,$path,$name) = url_getinfo($url);
	my %h;
	while($html =~ m/href="([^"]*)\/video-(\d+)[^>]+title="([^"]+)/g) {
		next if($h{$2});
		$h{$2} = 1;
		push @data,
			"urlrule:" . 
			url_getfull("$1/player/$2",$url,$base,$path) .
			"\t" . extract_title($3) . ".ts";
	}
	while($html =~ m/<h2><a[^>]+href="([^"]+video-)(\d+)"[^>]+>(.+?)<\/a><\/h2>/g) {
		next if($h{$2});
		$h{$2} = 1;
		push @data,
			"urlrule:" . 
			url_getfull("/player/$2",$url,$base,$path) .
			"\t" . extract_title($3) . ".ts";
	}
	
	
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::1_9_yase520_com;
1;

__END__

#       vim:filetype=perl


