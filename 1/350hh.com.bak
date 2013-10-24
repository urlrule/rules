#!/usr/bin/perl -w
#http://www.88dy.tv/list/index33.html
#Mon Oct  7 20:55:53 2013
use strict;
no warnings 'redefine';


sub apply_rule1 {
	my $url = shift;
	my $rule = shift;
 return (
       '#use quick parse'=>1,
	   'pass_data'=>[$url],
       'title_exp'=>'<li><em>类型：<\/em><a [^>]+><strong>([^<]+)<|<h2>([^<\s]+?)赞助商<',
       'title_map'=>'$1',
       'charset'=>'gbk'
 );
}

sub apply_rule {
    my ($url,$rule) = @_;
	if($url =~ m/\/article\//) {
		return (
			pass_data=>[$url],
			pass_count=>1,
			base=>$url,
		);
	}
	else {
		return apply_rule1($url,$rule);
	}
}

=cut

1;

__END__

#       vim:filetype=perl
