#!/usr/bin/perl -w
#DOMAIN : tom203.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-02-14 00:42
#UPDATED: 2020-02-14 00:42
#TARGET : https://tom203.com/e/action/ListInfo.php?page=3&classid=52&fenlei=4&line=30&tempid=9&ph=1&andor=and&orderby=&myorder=0&totalnum=1471 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_tom203_com;
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

use MyPlace::WWW::Utils qw/get_url url_getfull create_title_utf8 get_safename url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/<li/,$html);
	foreach(@html) {
		my ($u,$img,$t);
		if(m/href="([^"]+\.html)"/) {
			$u = $1;
		}
		if(m/title="([^"]+)"/) {
			$t = create_title_utf8($1);
		}
		if(m/data-original="([^"]+)/) {
			$img = $1;
		}
		if((!$img) and m/<img[^>]*src="([^"]+)/) {
			$img = $1;
		}
		if($u && $img && $t) {
			push @data,"urlrule:" . url_getfull($u,$url) . "\t" . $t . ".ts";
			push @data,url_getfull($img,$url) . "\t" . $t . ".jpg";
		}
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

return new MyPlace::URLRule::Rule::1_tom203_com;
1;

__END__

#       vim:filetype=perl


