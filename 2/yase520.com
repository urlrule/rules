#!/usr/bin/perl -w
#DOMAIN : 9.yase520.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-02-03 15:00
#UPDATED: 2019-02-03 15:00
#TARGET : https://9.yase520.com/ 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_9_yase520_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

use MyPlace::URLRule::Utils qw/get_url get_safename url_getname/;
sub apply_rule {
	my $self = shift;
	#	my $url = $_[0];
	#	my $title = url_getname($url);
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>'href="([^"]+\/page\/)(\d+)([^"]*)"',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
	   'pages_limit'=>undef,
	   'title'=>undef,
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
return new MyPlace::URLRule::Rule::2_9_yase520_com;
1;

__END__

#       vim:filetype=perl


