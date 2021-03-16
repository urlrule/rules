#!/usr/bin/perl -w
#DOMAIN : 9.yase520.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-02-03 15:00
#UPDATED: 2019-02-03 15:00
#TARGET : https://9.yase520.com/ 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_9_yase520_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

use MyPlace::URLRule::Utils qw/get_url get_safename url_getname/;
=method1
sub apply_rule {
	my $self = shift;
	#	my $url = $_[0];
	#	my $title = url_getname($url);
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>'href="([^"]+\/page\/)(\d+)([^"]*)"',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
	   'pages_limit'=>undef,
	   'title'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}
=cut
use MyPlace::URLRule::Utils qw/get_url get_safename url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $rurl = $url;
	#	$rurl =~ s/\/\/[^\/]*yase520\.com/\/\/www.yase9.com/;
	#$rurl =~ s/\/\/www\.yase9\.com/\/\/www2.yasedd.com/;
	$rurl =~ s/:\/\/[^\/]+/:\/\/9.yasedd1.com/;
	my $html = get_url($rurl,'-v');
	my ($pre,$last,$suf) = ("",0,"");
	while($html =~ m/href="([^"]+\/page\/)(\d+)([^"]*)"/g) {
		if($2 > $last) {
			$pre = $1;
			$last = $2;
			$suf = $3;
		}
	};
	if($last < 1) {
	while($html =~ m/href="([^"]+\/[^"\/]+\?page=)(\d+)([^"]*)"/g) {
		if($2 > $last) {
			$pre = $1;
			$last = $2;
			$suf = $3;
		}
	}
	}
    my @pass_data;
	push @pass_data,$url;
	foreach(1 .. $last) {
		push @pass_data,"$pre$_$suf";
	}
    return (
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::2_9_yase520_com;
1;

__END__

#       vim:filetype=perl


