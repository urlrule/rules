#!/usr/bin/perl -w

#DOMAIN : t.qq.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2015-04-07 21:47
#UPDATED: 2015-04-07 21:47
#TARGET : http://t.qq.com/xiaoerlang2012666 1

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
       'pages_exp'=>'<a[^>]+href="(\?[^"]*pi=)(\d+)([^"]+)"',
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
=cut

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $MODE = '';
	my $rurl = $url;
	if($url =~ m/^https?:\/\/([^\.\/]+)\.t\.qq\.com(.*)/) {
		$MODE = uc($1);
		$rurl = 'http://t.qq.com' . $2;
	}
	my $html = get_url($rurl,'-v');
    my @pass_data;
	my $r = time;
	push @pass_data,$url;
    while($html =~ m/<a[^>]+href="(\?[^"]*pi=)(\d+)([^"]+)"/g) {
			my $pageidx = $2;
			my $prefix = $1;
			my $suffix = $3;
			$prefix =~ s/^(https?:\/\/)/$1\L$MODE./ if($MODE);
			my $url = $prefix . $pageidx . $suffix;
			push @pass_data,$url;
	}
    return (
        count=>0,,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


