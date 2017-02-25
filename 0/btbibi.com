#!/usr/bin/perl -w

#DOMAIN : btbibi.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-09-25 01:02
#UPDATED: 2015-09-25 01:02
#TARGET : http://btbibi.com/h/763dgvd9d181.html

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

use MyPlace::URLRule::Utils qw/get_url create_torrent_title/;
sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');#,'charset:utf-8');
    my $title = undef;
    my @data;
    my @pass_data;
	if($html =~ m/<\s*[Hh]3\s*>([^<]+)/) {
		$title = create_torrent_title($1,1);
	}
	if($html =~ m/xcount\s*\(\s*"([^"]+)\"/) {
		my $xbytes = $1;
		my $count = length($xbytes);
		my $r = '';
		for(my $i=0;$i<$count;$i++) {
			my $c = substr($xbytes,$i,1);
			my $o = ord($c);
			$o = $o^7 if($o<128);
			$r .= chr($o);
		}
		$html = $r if($r);
	}
	if($html =~ m/<a[^>]+href="(magnet:[^"]+)/) {
		push @data, $1 . ($title ? "\t$title" : "");
	}

	
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


