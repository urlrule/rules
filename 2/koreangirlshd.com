#!/usr/bin/perl -w
#DOMAIN : koreangirlshd.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2016-08-03 02:21
#UPDATED: 2016-08-03 02:21
#TARGET : http://koreangirlshd.com/model/kim-bo-ra/ 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_koreangirlshd_com;
use MyPlace::URLRule::Utils qw/get_url/;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

=method1
sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
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


sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data = ($url);
	while($html =~ m/<a[^>]+href="([^"]+\/page\/\d+\/)"[^>]+>Next Page/) {
		push @pass_data,$1;
		$html = undef;
		$html = get_url($1,'-v');
	}
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


return new MyPlace::URLRule::Rule::2_koreangirlshd_com;
1;

__END__

#       vim:filetype=perl


