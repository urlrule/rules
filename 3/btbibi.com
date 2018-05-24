#!/usr/bin/perl -w

#DOMAIN : btbibi.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-09-25 01:17
#UPDATED: 2015-09-25 01:17
#TARGET : http://btbibi.com/波多 3

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

#use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $https;
    my @pass_data;
	if($url =~ m/^https:/) {
		$https = 1;
	}
	if($url =~ m/^https?:\/\/([^\/]+)\/(.+)$/) {
		push @pass_data,($https ? 'https' : 'http' ) . "://$1/v1/list.php?q=$2";
	}
    my $title = undef;
    my @data;
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


1;

__END__

#       vim:filetype=perl


