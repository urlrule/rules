#!/usr/bin/perl -w
#DOMAIN : btbiti.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2017-11-05 03:21
#UPDATED: 2017-11-05 03:21
#TARGET : http://btbiti.com/search/%E5%8F%B0%E6%B9%BE.html 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_btbiti_com;
use MyPlace::URLRule::Utils qw/get_url/;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>'<a href="([^"]+\/)(\d+)(-0-0\.html)"',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
	   'pages_limit'=>100,
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
return new MyPlace::URLRule::Rule::1_btbiti_com;
1;

__END__

#       vim:filetype=perl


