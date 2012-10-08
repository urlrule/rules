#!/usr/bin/perl -w
#http://www.colorbird.com/meinv/ganlulu/201204/ganlulu7160.shtml
#Sat Apr 28 00:29:06 2012
use strict;
no warnings 'redefine';


sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>'href="javascript:Gpage\(\d+\);"\>\<img src="([^"]+\/)(\d+)_s\.jpg"',
       'data_map'=>'"$1$2_big.jpg\t$2_big.jpg"',
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
       'title_exp'=>'\<h1\>([^<>]+)\<\/h1\>',
       'title_map'=>'$1',
       'charset'=>'gb2312',
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
