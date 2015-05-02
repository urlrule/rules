#!/usr/bin/perl -w

#DOMAIN : www.wrshu.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-05-02 21:30
#UPDATED: 2015-05-02 21:30
#TARGET : http://www.wrshu.com/xiaoshuo/special/zhuanti_93_93_1.html 2

use strict;
no warnings 'redefine';

=method1
sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>undef,
       'data_map'=>undef,

#Specify data mining method for nextlevel
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,

#Specify pages mining method
       'pages_exp'=>'<b>总数：(\d+)<\/b><b>(\d+)<\/b>',
       'pages_map'=>'"int($1/$2)+1"',
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

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v','charset:gb2312');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	if($url =~ m/^(.+)(\d+)(\.[^\.]+)$/) {
		$info{prefix} = $1;
		$info{suffix} = $3;
	}
	if($html =~ m/<b>总数：(\d+)<\/b><b>(\d+)<\/b>/) {
		$info{pages} = int($1/$2)+1;
		for my $p(1 .. $info{pages}) {
			push @pass_data, $info{prefix} . $p . $info{suffix};
		}
	}

    return (
		info=>\%info,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


