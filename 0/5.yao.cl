#!/usr/bin/perl -w
#http://5.yao.cl/htm_data/22/1409/1222762.html
#Thu Sep 18 01:24:22 2014
use strict;
no warnings 'redefine';


sub apply_rule {
 return (
       '#use quick parse'=>1,
       'pass_exp'=>'(http:\/\/[^<>\'"]+&mp4=1)',
       'pass_map'=>'$1',
       'pass_name_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
       'title_exp'=>'<h4>\s*([^<]+?)\s*<',
       'title_map'=>'$1',
       'charset'=>'gb2312',
	   'level'=>0,
 );
}

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
