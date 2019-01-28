#!/usr/bin/perl -w
#DOMAIN : 9797g.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-01-27 00:27
#UPDATED: 2019-01-27 00:27
#TARGET : http://www.9797g.com/list/index6.html 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_9797g_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>'<li>\s*<a[^>]+href="(.*?)index(\d+)\.html[^>]+>\s*<img',
       'pass_map'=>'"/video/?$2-0-0.html"',
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

=method2
use MyPlace::URLRule::Utils qw/get_url create_title/;

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
return new MyPlace::URLRule::Rule::1_9797g_com;
1;

__END__

#       vim:filetype=perl


