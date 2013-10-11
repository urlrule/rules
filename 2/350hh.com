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
       'pass_exp'=>'<(?:li|h3)><a href="([^"]+)"',
       'pass_map'=>'$1',
       'pass_name_map'=>undef,
#       'title_exp'=>'当前位置：.+<a [^>]+>([^<]+)</a',
#       'title_map'=>'$1',
#       'charset'=>'gbk'
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
