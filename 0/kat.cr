#!/usr/bin/perl -w

#DOMAIN : kat.cr
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2015-12-23 02:21
#UPDATED: 2015-12-23 02:21
#TARGET : https://kat.cr/usearch/borland/

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

use MyPlace::URLRule::Utils qw/get_url create_title js_unescape/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v','--compressed');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/data-sc-params/,$html);
	foreach(@html) {
		my ($name,$tor,$mag);
		if(m/'name': '([^']+)'/s) {
			$name = create_title($1);
		}	
		if(m/title="Torrent magnet link"[^>]+href="(magnet:[^"]+)"/s) {
			$mag = js_unescape($1);
		}
		if(m/title="Download torrent file"[^>]+href="([^"]+)"/s) {
			$tor = $1;
			if($tor =~ m/^\/\//) {
				$tor = 'http:' . $tor;
			}
		}
		if($tor) {
			if($mag and $mag =~ m/urn:btih:([^&]+)/) {
				$name = $name ? $name . "_" . $1 : $1;
			}
			push @data,$tor . ($name ? "\t" . $name . ".torrent" : "");
		}
		elsif($mag) {
			push @data,$mag . ($name ? "\t" . $name : "");
		}
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


