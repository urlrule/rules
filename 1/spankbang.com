#!/usr/bin/perl -w
#DOMAIN : spankbang.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-01-29 23:49
#UPDATED: 2019-01-29 23:49
#TARGET : https://spankbang.com/3ts/pornstar/mona+wales 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_spankbang_com;
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

use MyPlace::URLRule::Utils qw/get_url create_title url_getinfo url_getfull url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my @urlinfo = url_getinfo($url);
	foreach(@html) {
		if(m/href="([^"]+\/video\/[^"]+)"[^"]+class="thumb/) {
			my $url = url_getfull($1,$url,@urlinfo);
			my $filename = url_getname($url);
			push @data,"urlrule:$url\t$filename.mp4";
		}
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::1_spankbang_com;
1;

__END__

#       vim:filetype=perl


