#!/usr/bin/perl -w
#http://www.88dy.tv/list/index33.html
#Mon Oct  7 20:55:53 2013
use strict;
no warnings 'redefine';


sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>undef,
       'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>'<a href="([^"]*\/(?:list|part)\/\d+_)(\d+)(\.html)',,
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
	   'title_exp'=>'<meta name="description" content="([^"]+)第1页"',
       'title_map'=>'$1',
       'charset'=>'gbk'
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
