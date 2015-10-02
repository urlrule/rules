#!/usr/bin/perl -w

#DOMAIN : www.breadsearch.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-09-28 00:01
#UPDATED: 2015-09-28 00:01
#TARGET : http://www.breadsearch.com/search/blowjob

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
    my @html = split(/<div[^>]+class="search-item"/,$html);
	foreach(@html) {
		next unless(m/<span[^>]+class="list-label"[^>]*><a[^>]+href="(magnet:[^"]+)"/);
		my %info;
		$info{magnet} = $1;
		if(m/<span[^>]+class="list-title"[^>]*><a[^>]+>(.+?)<\/a><\/span>/) {
			$info{title} = create_title($1);
			$info{magnet} = $info{magnet} . "&dn=" . $info{title};
		}
		push @data,$info{magnet} . "\t" . $info{title};
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


