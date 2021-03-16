#!/usr/bin/perl -w
#DOMAIN : v.huya.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2021-03-17 04:49
#UPDATED: 2021-03-17 04:49
#TARGET : ___TARGET___
#URLRULE: 2.0
package MyPlace::URLRule::Rule::___ID___;
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
       'pages_exp'=>'<a[^>]+href="([^"]+&p=)(\d+)([^"]*)',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
	   'pages_limit'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}

=method2
use MyPlace::WWW::Utils qw/get_url get_safename url_getname new_url_data/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
    #my @html = split(/\n/,$html);
    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        title=>undef,
    );
}

=cut
return new MyPlace::URLRule::Rule::___ID___;
1;

__END__

#       vim:filetype=perl



