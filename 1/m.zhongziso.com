#!/usr/bin/perl -w
#DOMAIN : m.zhongziso.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2018-07-15 01:01
#UPDATED: 2018-07-15 01:01
#TARGET : https://m.zhongziso.com/list/%E4%BD%A0%E5%A5%BD/1 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_m_zhongziso_com;
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
       'pages_exp'=>'<a[^>]+href="([^"]*\/list[^\/"]*\/[^\/"]+\/)(\d+)"',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'',
       'pages_start'=>undef,
	   'pages_limit'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}

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
return new MyPlace::URLRule::Rule::1_m_zhongziso_com;
1;

__END__

#       vim:filetype=perl


