#!/usr/bin/perl -w
#DOMAIN : xhamster.sex
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2021-03-07 00:50
#UPDATED: 2021-03-07 00:50
#TARGET : ___TARGET___
#URLRULE: 2.0
package MyPlace::URLRule::Rule::___ID___;
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

use MyPlace::WWW::Utils qw/url_getbase get_url get_safename url_getname new_url_data/;
#https://www.xhamster.sex/tags/mom/?mode=async&function=get_block&block_id=list_videos_common_videos_list&sort_by=post_date&from=1&_=1615049301229

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
	my $base = $url;
	$base =~ s/^([^\?]+)\?.+/$1/;
	$base = $base . '?mode=async&function=get_block&block_id=list_videos_common_videos_list&sort_by=post_date'; #&from=1&_=1615049301229
	my $last = 0;
	while($html =~ m/data-parameters="[^"]+from:(\d+)/g) {
		$last = $1 if($1 > $last);
	}
	for(1 .. $last) {
		push @pass_data,$base . "&from=" . $_ . "&_=" . scalar(time);
	}
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

return new MyPlace::URLRule::Rule::___ID___;
1;

__END__

#       vim:filetype=perl



