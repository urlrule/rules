#!/usr/bin/perl -w
#DOMAIN : txxx.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-01-28 20:45
#UPDATED: 2019-01-28 20:45
#TARGET : https://www.txxx.com/search/?s=blonde 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_txxx_com;
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
       'pages_exp'=>'href="([^"]*?\/)(\d+)(\/[^"]*)"[^>]+title="Page\s+',
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
return new MyPlace::URLRule::Rule::2_txxx_com;
1;

__END__

#       vim:filetype=perl


