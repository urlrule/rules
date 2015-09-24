#!/usr/bin/perl -w

#DOMAIN : torrentkittyzw.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-09-25 01:49
#UPDATED: 2015-09-25 01:49
#TARGET : http://www.torrentkittyzw.com/s/人妻

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

use MyPlace::URLRule::Utils qw/get_url create_title/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
    my @html = split(/<li>/,$html);
	foreach(@html) {
		my %d;
		if(m/<a[^>]+href="\/bt\/\d+\.htm"[^>]+>(.+?)\s*<\/a>/) {
			$d{title} = $1;
			$d{title} =~ s/\s*<[^>]+>\s*//g;
			$d{title} = create_title($d{title});
		}
		if(m/>Hash[^\w\d]+?\s*([\w\d]+)/) {
			$d{hash} = uc($1);
		}
		if(m/<span>(\d+)-(\d+)-(\d+)[^<]+?Size:(\d+[^<]+)<\//) {
			$d{size} = $4;
		}
		if($d{hash}) {
			my $magnet = "magnet:?xt=urn:btih:$d{hash}";
			my $title;
			if($d{title}) {
				$title = $d{title} . ($d{size} ? "_" . $d{size} : "");
				$magnet = $magnet . "&dn=$title";
				push @data,$magnet . "\t" . $title;
			}
			else {
				push @data,$magnet;
			}
		}
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



