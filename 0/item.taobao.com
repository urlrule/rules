#!/usr/bin/perl -w

#DOMAIN : item.taobao.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2015-07-03 00:23
#UPDATED: 2015-07-03 00:23
#TARGET : http://item.taobao.com/item.htm?spm=a1z10.3-c.w4002-10242013313.46.WUOtCr&id=520421028224

use strict;
no warnings 'redefine';


sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>'<img[^>]+data-src="[^"]*?\/\/([^"]+\/imgextra\/[^"]+)_\d+[xX]\d+\.jpg"',
       'data_map'=>'"http://$1"',

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


