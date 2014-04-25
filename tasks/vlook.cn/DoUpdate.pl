#!/usr/bin/perl -w
use strict;
use Encode qw/find_encoding/;
use Cwd qw/getcwd/;
use File::Spec::Functions qw/catfile/;

my $WD = getcwd();
my $input = catfile($WD,'Following.txt');
my %following;
my @sortedFollowing;
open FI,'<:utf8',$input;
foreach(<FI>) {
	chomp;
	if(m/^\s*#\s*/) {
		next;
	}
	elsif(m/\s*([^\s]+)\s+([^\s+]+)/) {
		push @sortedFollowing,$1 unless($following{$1});
		$following{$1} = "$2";
	}
	elsif(m/\s*([^\s]+)/) {
		push @sortedFollowing,$1 unless($following{$1});
		$following{$1} = "$1";
	}
}
close FI;

my %target;
my @sortedTarget;
if(@ARGV) {
my $utf8 = find_encoding("utf-8");
map $_=$utf8->decode($_),@ARGV;
	foreach my $key (keys %following) {
		foreach my $r (@ARGV) {
			if($key =~ m/$r/) {
				push @sortedTarget,$key unless($target{$key});
				$target{$key} = $following{$key};
			}
			elsif($following{$key} =~ m/$r/) {
				push @sortedTarget,$key unless($target{$key});
				$target{$key} = $following{$key};
			}
		}
	}
}
else {
	%target = %following;
	@sortedTarget = @sortedFollowing;
}

use MyPlace::ReEnterable;
mkdir ".urlrule" unless -d ".urlrule";
my $R = MyPlace::ReEnterable->new('main',catfile(".urlrule","resume"));
if(%target) {
	foreach my $id (@sortedTarget) {
		my $dist = catfile($WD,$target{$id});
		$R->push(
			$dist,
			'load_rule',
			undef,
			"http://www.vlook.cn/ta/qs/$id",
			2,
			"SAVE",
			'',
		);
	}
	$R->saveToFile();
	exec('urlrule_action');
}
else {
	die("Nothing to do\n");
}



__END__

#       vim:filetype=perl
