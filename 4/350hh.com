#!/usr/bin/perl -w
#http://www.88dy.tv/list/index33.html
#Mon Oct  7 20:55:53 2013
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
       'pages_exp'=>'<a href="([^"]*\/list\/\d+_)(\d+)(\.html)',,
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
#       'title_map'=>'$1',
#       'charset'=>'gbk'
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $site;
	if($url =~ m/^(http:\/\/.+?)\//){
		$site = $1;
	}
	else {
		$site = $url;
	}
	my $url2 = "$site/js/layout.js";
	my $html = get_url($url2,'-v');
    my @pass_data;
    my @html = split(/\n/,$html);
	while($html =~ m/<li><a href="(\/(?:html|list)\/[^"]+)/g) {
		push @pass_data,$1;
	}
    return (
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl
