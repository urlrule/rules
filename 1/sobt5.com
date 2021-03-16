#!/usr/bin/perl -w

#DOMAIN : www.sobt5.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2015-08-22 00:33
#UPDATED: 2015-08-22 00:33
#TARGET : http://www.sobt5.com/q/小早川怜子 1

use strict;
no warnings 'redefine';


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
       'pages_exp'=>'<a[^>]+href="https?([^"]+&page=)(\d+)"',
       'pages_map'=>'$2',
       'pages_pre'=>'"https$1"',
       'pages_suf'=>'',
       'pages_start'=>undef,
	   'pages_limit'=>undef,

       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

=method2
use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
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


