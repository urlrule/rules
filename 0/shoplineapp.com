#!/usr/bin/perl -w
#DOMAIN : yfilos.shoplineapp.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2020-01-15 01:13
#UPDATED: 2020-01-15 01:13
#TARGET : https://yfilos.shoplineapp.com/products/%E6%8A%93%E7%9A%BA%E6%84%9F%E7%B6%81%E7%B9%A9%E4%B8%8A%E8%A1%A3
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_yfilos_shoplineapp_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>'"([^"]+\/([^\/"]+)\/2000x\.jpeg)',
	   'data_map'=>'"$1\t$2.jpeg"',
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
	   'pages_limit'=>undef,
       'title_exp'=>'<title>([^<]+)',
       'title_map'=>'$1',
       'charset'=>undef
	);
}

=method2
use MyPlace::WWW::Utils qw/get_url get_safename url_getname/;

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
return new MyPlace::URLRule::Rule::0_yfilos_shoplineapp_com;
1;

__END__

#       vim:filetype=perl


