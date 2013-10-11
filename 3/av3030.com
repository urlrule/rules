#!/usr/bin/perl -w
#http://av3030.com
#Wed Oct  9 14:33:30 2013
use strict;
no warnings 'redefine';

=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>undef,
       'data_map'=>undef,
       #'pass_exp'=>'<a[^>]*href="([^"]*\/vodlist\/\d+_1\.html)"',
       #'pass_map'=>'$1',
       'pass_name_map'=>undef,
       'pages_exp'=>'<a[^>]*href="([^"]*\/vodlist\/)(\d+)(_1\.html)"',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>50,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

#use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
    my @pass_data = map("/vodlist/${_}_1.html",(51..61));
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
