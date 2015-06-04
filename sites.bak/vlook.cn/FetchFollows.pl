#!/usr/bin/perl -w
use strict;
use MyPlace::Curl;
sub PageURL {
	return 'http://www.vlook.cn/ta/follow?uid=' . $_[0] . '&no=' . $_[1] . '&size=40';
}

my $uid = shift;
my $maxpage = shift(@ARGV) || 20;
my $curl = MyPlace::Curl->new();
my $output = "Following$uid.html";

open FO,">",$output or die("$!\n");

foreach(1 .. $maxpage) {
	my $page = PageURL($uid,$_);
	print STDERR "Fetch " . $page;
	print FO $curl->get($page);
}

close FO;


