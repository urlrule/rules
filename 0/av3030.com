#!/usr/bin/perl -w
#http://www.av3030.com/vodhtml/8548.html
#Wed Oct  9 14:04:46 2013
use strict;
no warnings 'redefine';

=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>'href="/play/[^"]+"[^>]*>([^<]+)<',
       'data_map'=>'$1',
	   undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>'gb2312',
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url/;
use Encode qw/from_to/;
sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = '';
    my @data;
    my @pass_data;
    from_to($html,'gbk','utf-8');
    my @html = split(/\n/,$html);
	my @qvod;
	my $cover='';
	my $ext='';
	foreach(@html) {
		if((!$title) && m/<li>影片名称：\s*([^<]+?)\s*</) {
			$title = $1;
		}
		elsif(m/href="\/play\/[^"]+"[^>]*>([^<]+)</) {
			my $qvod = $1;
			my $ext='';
			if($qvod =~ m/(\.[^\.]+?)\|?$/) {
				$ext = $1;
			}
			push @qvod,[$qvod,$ext];
		}
		elsif((!$cover) && m/<ul class="pic"><img[^>]*src="([^"]+)/) {
			$cover = $1;
			from_to($cover,'utf-8','gbk');
		}
	}
	my $idx='';
	my $c = @qvod;
	if($c > 1) {
		$idx=0;
	}
	foreach(@qvod) {
		$idx++ if($c>1);
		push @data,"qvod:$_->[0]\t$title$idx$_->[1]";
	}
	if($cover) {
		push @data,"$cover\t$title.jpg";
	}
	if(@data<3) {
		$title = undef;	
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        title=>$title,
    );
}

=cut

1;

__END__

#       vim:filetype=perl
