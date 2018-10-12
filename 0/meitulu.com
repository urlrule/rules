#!/usr/bin/perl -w
#DOMAIN : meitulu.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2018-08-30 13:34
#UPDATED: 2018-08-30 13:34
#TARGET : https://meitulu.com/item/14537.html
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_meitulu_com;
use MyPlace::URLRule::Utils qw/get_url extract_title create_title/;
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
    my @pass_data;
    my @html = split(/\n/,$html);
	while($html =~ m/<img[^>]+src="([^"]+\/images\/img\/([^\/"]+)\/([^\/"]+))"[^>]+class="content_img"/g) {
		push @data,"$1\t$2_$3";
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

return new MyPlace::URLRule::Rule::0_meitulu_com;
1;

__END__

#       vim:filetype=perl


