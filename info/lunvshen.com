#!/usr/bin/perl -w

#DOMAIN : lunvshen.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2016-01-09 01:54
#UPDATED: 2016-01-09 01:54
#TARGET : http://lunvshen.com/u?name=穆晹MOYI :info

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

sub get_info {
	my $url = shift;
	my $info = shift;
	if($url =~ m/\/u\?name=([^&]+)/) {
		$info->{uid} = $1;
	}
	if($url =~ m/^\w+:\/\/([^\/]+)/) {
		$info->{host} = $1;
	}
	if($info->{uid}) {
		$info->{uname} = $info->{uid};
		$info->{profile} = $info->{uid};
		return 1;
	}
	return undef;
}
sub apply_rule {
    my ($url,$rule) = @_;
	my %info;
	$info{host} = 'lunvshen.com';
	if(!get_info($url,\%info)) {
		my $html = get_url($url,'-v');
		if($html =~ m/<a href="(.*\/u\?name=[^"]+)">/) {
			get_info($1,\%info);
		}
	}
	$info{url} = 'http://' . $info{host} . '/u?name=' . $info{profile};
	return %info;
}

=cut

1;

__END__

#       vim:filetype=perl


