#!/usr/bin/perl -w
#http://kimkardashian.celebuzz.com/photos/
#Thu Jan 19 02:25:49 2012
use strict;
no warnings 'redefine';

=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>undef,
       'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>'href=\'([^\']*\/(?:photos|gallery)\/page\/)(\d+)([^\']*)\'',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url parse_pages/;

sub get_last_page {
	my ($url,$b,$e) = @_;
	return $b if($b == $e);
	while($b < $e) {
		my $current = int(($b + $e) / 2) + 1;
		print STDERR "Detecting last page [$b - $e]: ";
		my $html = get_url("${url}page/$current/",'-v');
		my $lastpage = 0;
		while($html =~ m/<a href='[^']*\/?gallery\/page\/(\d+)\/?/g) {
			$lastpage = $1 if($1 > $lastpage);
		}
		if(!$lastpage) {
			$e = $current-1 ;
		}
		elsif($lastpage > $current) {
			$b = $lastpage;
		}
		else {
			$b = $current;
		}
	}
	return $e;
}


sub apply_rule {
    my ($url,$rule) = @_;
	if($url =~ m/\/gallery$/) {
		$url .= '/';
	}
	elsif($url !~ m/\/gallery\/$/) {
		$url .= '/gallery/';
		$url =~ s/\/\/+gallery\/$/\/gallery\//;
	}
	my $lastpage = get_last_page($url,2,500);
	my @pass_data;
	if($lastpage > 1) {
		@pass_data = map "${url}page/$_",(2 .. $lastpage);
	}
	push @pass_data,$url;

    return (
        pass_count=>$lastpage || 1,
        pass_data=>\@pass_data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl
