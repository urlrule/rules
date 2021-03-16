#!/usr/bin/perl -w
#DOMAIN : koreangirlshd.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2016-08-03 02:13
#UPDATED: 2016-08-03 02:13
#TARGET : http://koreangirlshd.com/kim-bo-ra-seoul-adex-2015/
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_koreangirlshd_com;
use MyPlace::URLRule::Utils qw/get_url/;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>'img[^>]+src="(http:\/\/koreangirlshd.com\/wp-content\/picture\/[^"]+)" alt="',
	   'data_map'=>'$1',
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
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

sub apply_rule {
	my $self = shift;
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
return new MyPlace::URLRule::Rule::0_koreangirlshd_com;
1;

__END__

#       vim:filetype=perl


