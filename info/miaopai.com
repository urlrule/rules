#!/usr/bin/perl -w
use strict;
use warnings;

sub apply_rule {
	my $url = shift;

	my $uid;
	my $profile;
	my $uname;

	my $path = $url;
	$path =~ s/^https?:\/\/[^\/]+\///;
	$path =~ s/[\?\&\#].+$//;
	$_ = $path;
	if(m/^u\/([^\/\&\?\#]+)/){
		$uid = $1;
		$profile = "$uid";
	}

	return (
		uid=>$uid,
		uname=>$uname,
		profile=>$profile,
		host=>'miaopai.com',
		url=>'http://www.miaopai.com/u/' . $profile,
	);
}

# vim:filetype=perl

