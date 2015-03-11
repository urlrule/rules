#!/usr/bin/perl -w
#t.qq.com
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

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $uname;
	if($url =~ m/^http:\/\/t.qq.com\/([^\/#?&]+)/) {
		$uname = $1;
	}
	return (
		uname=>$uname,
		profile=>$uname,
		host=>'t.qq.com',
	);
}

=cut

1;

__END__

#       vim:filetype=perl
