#!/usr/bin/perl -w
use strict;

use Encode qw/find_encoding/;
use MyPlace::URLRule::SaveById;
my $utf8 = find_encoding("utf-8");
	
	
my $OUTPUT='ID.txt';


my $handle = MyPlace::URLRule::SaveById->new();
$handle->feed($OUTPUT,'file');
my @lines;
while(<>) {
	push @lines,$utf8->decode($_);
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


