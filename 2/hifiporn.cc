#!/usr/bin/perl -w
#DOMAIN : hifiporn.cc
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2020-12-25 15:16
#UPDATED: 2020-12-25 15:16
#TARGET : https://hifiporn.cc/xxx/mom 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_hifiporn_cc;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>'class="tab page"><a[^>]+href="([^"]*\/)(\d+)(\/[^"]+)',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
	   'pages_limit'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}

=method2
use MyPlace::WWW::Utils qw/get_url get_safename url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
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

=cut
return new MyPlace::URLRule::Rule::2_hifiporn_cc;
1;

__END__

#       vim:filetype=perl


