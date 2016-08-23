#!/usr/bin/perl -w

#DOMAIN : sinacn.weibodangan.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2016-01-06 03:52
#UPDATED: 2016-01-06 03:52
#TARGET : ___TARGET___

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
	if($url =~ m/\/user\/(\d+)/) {
		return (
			uid=>$1,
			profile=>"/user/$1/",
			host=>'sinacn.weibodangan.com',
			url=>"http://sinacn.weibodangan.com/user/$1/",
			pass_data=>["http://sinacn.weibodangan.com/user/$1/"],
			title=>$1,
		);
	}
	return (
		error=>"Failed parsing url",
	);
}

=cut

1;

__END__

#       vim:filetype=perl



