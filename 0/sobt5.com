#!/usr/bin/perl -w

#DOMAIN : www.sobt5.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-08-22 00:19
#UPDATED: 2015-08-22 00:19
#TARGET : http://www.sobt5.com/q/小早川怜子

use strict;
no warnings 'redefine';

=method1
sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>'<a[^>]+href="[^>"]*\/([a-zA-Z0-9]+)\.html"[^>]+title="([^"]+)"[^>]+>',
       'data_map'=>'
			my ($thash,$ttitle) = ($1,$2);
			$ttitle =~ s/\s+...$//;
			#$ttitle =~ s/\s*[_：-]\s*//g;
			"magnet:?xt=urn:btih:$thash&dn=$ttitle\t$ttitle"
		',

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
	my $html = get_url($url,'-v');#,'charset:utf-8');
    my $title = undef;
    my @data;
    my @pass_data;
	my @html = split("<div class=\"item-title\">",$html);
	foreach(@html) {
		my $t;
		my $h;
		if(m/<\s*[Hh]3\s*>(.+?)<\s*\/[Hh]3\s*>/) {
			$t = $1;
			$t =~ s/<[^>]+>//g;
			$t =~ s/\[email&#160;protected\]@*//g;
			$t =~ s/^\s+//;
			$t =~ s/\s+$//;
			$t = create_title($t);
			if(m/href="[^"]*\/torrent\/([A-Za-z0-9]+)\.html"/) {
				$h = uc($1);
				push @data,"magnet:?xt=urn:btih:$h&dn=$t\t$t";
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


