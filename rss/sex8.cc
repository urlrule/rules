#!/usr/bin/perl -w

#DOMAIN : www.sexinsex.net
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-11-23 19:44
#UPDATED: 2015-11-23 19:44
#TARGET : http://www.sexinsex.net/bbs/thread-4583185-1-1.html rssitem

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
	my @page = ($url);
	if($url =~ m/-page-\d+/) {
	}
	elsif($url =~ m/^(.+?)\/thread-htm-fid-(\d+)/) {
		push @page, $1 . '/thread-htm-fid-' . $2 . '-page-2.html';
	}
	return (page=>\@page);
}

=cut

1;

__END__

#       vim:filetype=perl


