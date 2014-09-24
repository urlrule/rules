#!/usr/bin/perl -w
use strict;
use warnings;

use utf8;
use JSON;
use MyPlace::URLRule::Utils qw/get_url/;

use Encode qw/find_encoding/;
my $utf8 = find_encoding('utf8');


my $id = shift(@ARGV) || '2820910492';
my $page_start = shift(@ARGV) || 1;
my $page_end = shift(@ARGV);# || 200;

sub fetch_page {
	my $id = shift;
	my $page = shift;
	my $url = "http://m.weibo.cn/page/json?module=user&action=FOLLOWERS&itemid=FOLLOWERS&title=%E5%85%B3%E6%B3%A8&containerid=100505${id}_-_FOLLOWERS&page=${page}";
	my $data = get_url($url);
	use Data::Dumper;
	#print STDERR Data::Dumper->Dump([$data],['data']),"\n";
	my $json =  decode_json($data);
	#print STDERR Data::Dumper->Dump([$json],['json']),"\n";
	my @r;
	foreach(@{$json->{users}}) {
		push @r,[$_->{'profile_url'},$utf8->encode($_->{'screen_name'})];
	}
	return $json,@r;
}

sub process_page {
	my $page = shift;
	my $last_page = shift;
	print STDERR "Fetching follows page [$page/$last_page] ...\n";
	my ($json,@r) = fetch_page($id,$page);
	if(@r) {
		print "$_->[0]\t$_->[1]\n" foreach(@r);
	}
	return $json;
}

sub exitnow {
	my $exitcode = shift;
	my $msg = shift;
	if(!$exitcode) {
		$exitcode = 0;
		print STDERR $msg,"\n" if($msg);
	}
	else {
		print STDERR "Error: $msg\n" if($msg);
	}
	exit $exitcode;
}

if(!$page_end) {
	my $json = process_page($page_start,"???");
	$page_end = $json->{"maxPage"};
	$page_start = $page_start +1;
}
if(!$page_end) {
	exitnow(1);
}
if($page_start > $page_end) {
	exitnow(0,"Completed.");
}

process_page($_,$page_end) foreach($page_start .. $page_end);
exitnow(0,"Completed");

