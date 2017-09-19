#!/usr/bin/perl -w

#DOMAIN : photo.hupu.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-01-28 20:39
#UPDATED: 2015-01-28 20:39

use strict;
no warnings 'redefine';


sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>'<img[^>]+oksrc="([^"]+)',
       'data_map'=> sub {$_[2] =~ s/_\d+x\d+\.([^\.]+)$/.$1/r;},

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

       'title_exp'=>'<h2>([^<]+)',
       'title_map'=>'$1',
       'charset'=>'gb2312'
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



