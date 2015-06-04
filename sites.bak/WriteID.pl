#!/usr/bin/perl -w
use strict;

use Encode qw/find_encoding/;
use MyPlace::SimpleQuery;
my $utf8 = find_encoding("utf-8");
	
	
my $OUTPUT = shift;


my $handle = MyPlace::SimpleQuery->new();
$handle->feed($OUTPUT,'file');
my @lines;
while(<STDIN>) {
	push @lines,$_;#$utf8->decode($_);
}
my ($count,$msg) = $handle->add(@lines);

if($count) {
	my $t = localtime;
	print STDERR "# $count ID added, ",$t,".\n";
	$handle->saveTo($OUTPUT,"$count ID added, $t");
}
else {
	print STDERR "Nothing to do\n";
}

1;


