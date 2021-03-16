#!/usr/bin/perl -w
#DOMAIN : tom203.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2020-02-14 00:52
#UPDATED: 2020-02-14 00:52
#TARGET : https://tom203.com/e/action/ListInfo.php?page=3&classid=52&fenlei=4&line=30&tempid=9&ph=1&andor=and&orderby=&myorder=0&totalnum=1471 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_tom203_com;
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
       'pages_exp'=>'href="([^"]*(?:index_|page=))(\d+)([^"]*)',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>2,
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
return new MyPlace::URLRule::Rule::2_tom203_com;
1;

__END__

#       vim:filetype=perl


