#!/usr/bin/perl -w
#http://www.miaopai.com/gu/u?page=9&suid=hdpddW5hNO~jN661&fen_type=channel
#Mon Jan  5 01:05:07 2015
use strict;
no warnings 'redefine';


sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>undef,
       'data_map'=>undef,
       'pass_exp'=>'src=\\\\"http:\\\\/\\\\/([^"]+)\\\\/stream\\\\\/([^"_]+__)',
       'pass_map'=>'"http://www.miaopai.com/show/$2.htm"',
       'pass_name_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
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
