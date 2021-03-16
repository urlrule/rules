#!/usr/bin/perl -w
#DOMAIN : noodlemagazine.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2021-02-23 04:58
#UPDATED: 2021-02-23 04:58
#TARGET : https://noodlemagazine.com/video/wetting her panties 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_noodlemagazine_com;
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

use MyPlace::WWW::Utils qw/get_url get_safename url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
    my @data;
    my @pass_data;
	$url =~ s/\?.*$//;
	push @pass_data,$url;
	for(2 .. 10) {
		push @pass_data,$url . "?p=$_";
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

return new MyPlace::URLRule::Rule::2_noodlemagazine_com;
1;

__END__

#       vim:filetype=perl


