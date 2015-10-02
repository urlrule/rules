#!/usr/bin/perl -w

#DOMAIN : www.ganluzhe.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-10-03 01:21
#UPDATED: 2015-10-03 01:21
#TARGET : http://www.ganluzhe.com/search/%E9%99%90%E5%88%B6%E7%BA%A7_ctime_1.html

use strict;
no warnings 'redefine';


=method1
sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>undef,
       'data_map'=>undef,

#Specify data mining method for nextlevel
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,

#Specify pages mining method
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


use MyPlace::URLRule::Utils qw/get_url create_title/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my @data;
    my @html = split(/<div[^>]+class="panel-body"/,$html);
	foreach(@html) {
		next unless(m/<h5 class="item-title"><a[^>]+href="[^"]+ganluzhe.com\/([^"\/]+)\.html"[^>]+>(.+?)<\/a/);
		my %info;
		$info{magnet} = "magnet:?xt=urn:btih:" . uc($1);
		$info{title} = create_title($2,2);
		$info{magnet} = $info{magnet} . "&dn=" . $info{title} if($info{title});
		push @data,$info{magnet} . "\t" . $info{title};
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


