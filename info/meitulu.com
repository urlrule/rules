#!/usr/bin/perl -w

#DOMAIN : www.meitulu.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2015-12-27 03:07
#UPDATED: 2015-12-27 03:07
#TARGET : http://www.meitulu.com/t/guxinyi/ :info

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

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my @html = split(/\n/,$html);
	my %info;
	foreach(@html) {
		if(m/<img[^>]+images\/tag\/[^>]+alt="([^"]+)"/) {
			$info{uname} = $1;
			last;
		}
	}
	if($url =~ m/\/t\/([^\/]+)/) {
		$info{uid} = $1;
		$info{profile} = 't/' . $info{uid};
		$info{url} = 'http://www.meitulu.com/' . $info{profile};
		$info{host} = 'meitulu.com';
	}
    return %info;
}

=cut

1;

__END__

#       vim:filetype=perl


