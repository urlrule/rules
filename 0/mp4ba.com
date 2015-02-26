#!/usr/bin/perl -w
#http://www.mp4ba.com/show.php?hash=4beffe67a955d9d70f650d60d954cdd9217dadf2
#Thu Feb 26 21:34:12 2015
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

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v',);
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my $link;
	my $title;
	foreach(@html) {
		if(m/<a id="download" href="([^"]+)">/) {
			$link = $1;
		}
		elsif(m/<title>([^<]+) -[^-]+-[^-]+-[^-]+</) {
			$title = $1;
		}
		if($link and $title) {
			last;
		}
	}
	if($link and $title) {
			@data = ("$link\t$title.torrent");
	}
	elsif($link) {
		@data = ($link);
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>0,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl
