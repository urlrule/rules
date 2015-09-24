#!/usr/bin/perl -w

#DOMAIN : torrentkittyzw.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-09-25 01:46
#UPDATED: 2015-09-25 01:46
#TARGET : http://www.torrentkittyzw.com/bt/7107.htm

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
    my $title = undef;
    my @data;
	my $hash;
	if($html =~ m/<h3 style=[^>]*>\s*(.+?)\s*<\/h3>/i) {
		$title = create_title($1,1);	
	}
	if($html =~ m/<a[^>]+href="(magnet:[^"]+)"/i) {
		if($title) {
			push @data,"$1&dn=$title\t$title";
		}
		else {
			push @data,$1;
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



