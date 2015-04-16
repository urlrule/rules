#!/usr/bin/perl -w

#DOMAIN : t.qq.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-04-07 21:05
#UPDATED: 2015-04-07 21:05
#TARGET : http://t.qq.com/xiaoerlang2012666?mode=0&id=441152065295855&pi=2&time=1421499669

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

use MyPlace::URLRule::Utils qw/get_url expand_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $MODE = 'NORMAL';
	if($url =~ m/^https?:\/\/([^\.\/]+)\.t\.qq\.com(.*)/) {
		$MODE = uc($1);
		$url = 'http://t.qq.com' . $2;
	}
	my $html = get_url($url,'-v');
    #my @html = split(/\n/,$html);
	my @data;
	if($MODE eq 'LINKS') {
		my %links;
		while($html =~ m/<a[^>]+href="(http:\/\/url\.cn\/[^"]+)"/g) {
			$links{&expand_url($1)} = 1;
		}
		@data = keys %links;
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>0,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


