#!/usr/bin/perl -w
#weibo.com
#Sat Feb 28 08:32:39 2015
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

sub apply_rule {
    my ($url,$rule) = @_;
	my %info;
	if($url =~ m/weibo\.com\/u\/([^\/#?&]+)/) {
		$info{uid} = $1;
	}
	elsif($url =~ m/weibo\.com\/([^\/#?&]+)\/?$/) {
		$info{uid} = $1;
	}
	$info{profile} = $info{uid} ?  "u/" . $info{uid} : $info{uname},
	return (
		uid=>$info{uid},
		profile=>$info{profile},
		host=>'weibo.com',
		url=>'http://weibo.com/' . $info{profile},
	);
}

=cut

1;

__END__

#       vim:filetype=perl
