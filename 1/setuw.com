#!/usr/bin/perl -w
#DOMAIN : setuw.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-06-18 02:26
#UPDATED: 2019-06-18 02:26
#TARGET : http://setuw.com/tag/xinggan/ 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_setuw_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>'<li><a[^>]+href="([^>"]+)"[^>]*><img',
       'pass_map'=>'$1',
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
use MyPlace::URLRule::Utils qw/get_url get_safename url_getname/;

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
return new MyPlace::URLRule::Rule::1_setuw_com;
1;

__END__

#       vim:filetype=perl


