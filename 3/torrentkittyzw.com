#!/usr/bin/perl -w

#DOMAIN : torrentkittyzw.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-09-25 02:18
#UPDATED: 2015-09-25 02:18
#TARGET : http://www.torrentkittyzw.com/%E5%A6%BB

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


sub apply_rule {
    my ($url,$rule) = @_;
	my @pass_data;
	if($url =~ m/^http:\/\/[^\/]+\/(.+)$/) {
		push @pass_data,'http://www.torrentkittyzw.com/s/' . $1;
	}
    return (
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl



