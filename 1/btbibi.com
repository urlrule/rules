#!/usr/bin/perl -w

#DOMAIN : btbibi.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2015-09-25 01:11
#UPDATED: 2015-09-25 01:11
#TARGET : http://btbibi.com/s/1/%E6%B3%A2%E6%B3%A2.html 1

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
       'pass_exp'=>'<a[^>]+href="([^"]*\/h\/[^"]+\.html)"[^>]+>\s*<[Hh]4>',
       'pass_map'=>'$1',
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
	return (
		base=>$url,
		pass_data=>[$url],
		pass_count=>1,
	);
	$url =~ s/\+([^\/]*)$/ $1/g;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	while($html =~ m/<a[^>]+href="([^"]*\/h\/[^"]+\.html)"[^>]+>\s*<[Hh]4>/g) {
		push @pass_data,"$1";
	}
    #my @html = split(/\n/,$html);
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


