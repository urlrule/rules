#!/usr/bin/perl -w

#DOMAIN : lunvshen.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2016-01-09 02:20
#UPDATED: 2016-01-09 02:20
#TARGET : http://lunvshen.com/u?name=穆晹MOYI 3

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
    my $title = undef;
    my @pass_data;
	if($url =~ m/\/nvshen\?id=(\d+)/) {
		$title = $1;
	}
	push @pass_data,$url;
    #my @html = split(/\n/,$html);
    return (
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


