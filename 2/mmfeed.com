#!/usr/bin/perl -w
#DOMAIN : mmfeed.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-02-18 05:33
#UPDATED: 2020-02-18 05:33
#TARGET : http://www.mmfeed.com/forumdisplay.php?fid=41&page=4&filter=0&orderby=dateline 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_mmfeed_com;
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
       'pages_exp'=>'<a[^>]+href="([^"]*forumdisplay[^"]*page=)(\d+)([^"]*)',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
	   'pages_limit'=>2000,
       'title_exp'=>'<title>[^\-]+-\s*([^\-]+)\s*-',
       'title_map'=>'$1',
       'charset'=>'gbk',
	   'update'=>1,
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
return new MyPlace::URLRule::Rule::2_mmfeed_com;
1;

__END__

#       vim:filetype=perl


