#!/usr/bin/perl -w

#DOMAIN : btbibi.com
#AUTHOR : eotect <eotect@MyPlace>
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

use MyPlace::URLRule::Utils qw/get_url create_title extract_title/;
sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');#,'charset:utf-8');
    my $title = undef;
    my @data;
    my @pass_data;
	#print STDERR $html,"\n";
	my @lines = split(/<div class="title">/,$html);
	foreach(@lines) {
		my $title;
		my $hash;
		if(m/href=["']magnet:.*[\?&]dn=([^"'&]+)/i) {
			$title = create_title($1);
		}
		elsif(m/<\s*[Hh]3\s*>(.+?)<\s*\/[Hh]3/) {
			$title = $1;
			$title =~ s/<[^>]+>//g;
			$title =~ s/^\s+//;
			$title =~ s/\s+$//;
			$title =~ s/\[email&#160;protected\]@*//g;
			$title = create_title($title);
		}
		if(m/href=["']magnet:\?.*xt=urn:btih:([0-9a-fA-F]+)/i) {
			$hash = uc($1);
		}
		if($title and $hash) {
			push @data,"magnet:?xt=urn:btih:$hash&dn=$title\t$title";
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


