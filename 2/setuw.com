#!/usr/bin/perl -w
#DOMAIN : setuw.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-06-18 02:36
#UPDATED: 2019-06-18 02:36
#TARGET : http://setuw.com/tag/xinggan/ 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_setuw_com;
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

use MyPlace::URLRule::Utils qw/url_getfull get_url get_safename/;

sub p_page {
	my $url = shift;
	my @r;
	my $html = get_url($url,'-v');
	push @r,$url;
	if($html =~ m/<div class="turnpage"><a href="([^"]+)"/) {
		my $nurl = url_getfull($1,$url);
		push @r,p_page($nurl) unless($url eq $nurl);
	}
	return @r;
}

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
    my $title = undef;
    my @data;
    my @pass_data = ($url);
	my $html = get_url($url,'-v');
	if($html =~ m/<h1[^>]*>([^<]+)/) {
		$title = get_safename($1);
	}
	if($html =~ m/<div class="turnpage"><a href="([^"]+)"/) {
		my $nurl = url_getfull($1,$url);
		push @pass_data,p_page($nurl) unless($url eq $nurl);
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::2_setuw_com;
1;

__END__

#       vim:filetype=perl


