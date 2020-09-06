#!/usr/bin/perl -w
#DOMAIN : mmfeed.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-02-18 05:28
#UPDATED: 2020-02-18 05:28
#TARGET : http://www.mmfeed.com/viewthread.php?tid=1233696&extra=page%3D4%26amp%3Bfilter%3D0%26amp%3Borderby%3Ddateline 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_mmfeed_com;
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

use MyPlace::WWW::Utils qw/get_url url_getbase get_safename url_getname decode_title/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my $baseurl = url_getbase($url);
	foreach(@html) {
		if(m/<td class="f_folder"><a href="(.*viewthread\.php[^"]+)/) {
			push @data,"urlrule:$baseurl/$1";
		}
	}
    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        title=>undef,
    );
}

return new MyPlace::URLRule::Rule::1_mmfeed_com;
1;

__END__

#       vim:filetype=perl


