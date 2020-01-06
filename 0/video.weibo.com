#!/usr/bin/perl -w

#DOMAIN : video.weibo.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-03-14 18:32
#UPDATED: 2015-03-14 18:32
#TARGET : http://video.weibo.com/show?fid=1034:5750c5ca8e4140d226571eeb59e38421

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

use MyPlace::URLRule::Utils qw/get_url strnum/;
use MyPlace::Weibo qw/m_get_object/;
use URI::Escape;

sub apply_rule {
    my ($url,$rule) = @_;
	return m_get_object($url);
}

=cut

1;

__END__

#       vim:filetype=perl



