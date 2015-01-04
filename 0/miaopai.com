#!/usr/bin/perl -w
#miaopai.com
#Mon Jan  5 00:22:37 2015
use strict;
no warnings 'redefine';

#http://120.198.232.217/wscdn.miaopai.com/stream/GMFLiWlV3gnYy4wGItQoiA__.mp4?wsiphost=local


=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
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
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url/;


sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my %info;
	(undef,undef,undef,$info{day},$info{month},$info{year}) = localtime(time);
	$info{year} += 1900;
	$info{year} = "";
	$info{month} += 1;
	$info{month} = "0" . $info{month} if($info{month} < 10);
	$info{day} = "0" . $info{day} if($info{day} < 10);
	$info{desc} = "";
	foreach(@html) {
		if(m/<meta property="og:([^"]+)"[^>]+content="([^"]+)"/) {
			$info{$1} = $2;
		}
		elsif(m/<h2><b>(\d+)-(\d+)/) {
			$info{month} = $1;#($1 < 10 ? "0$1" : $1);
			$info{day} = $2;#($2 < 10 ? "0$2" : $2);
		}
		elsif(m/<h2><b>(\d+)-(\d+)-(\d+)/) {
			$info{year} = $1;
			$info{month} = $2;#($1 < 10 ? "0$1" : $1);
			$info{day} = $3;#($2 < 10 ? "0$2" : $2);
		}
		elsif(m/<p>\s*([^<]+)/) {
			$info{desc} = $1;
			$info{desc} =~ s/\s+$//;
			$info{maxlen} = 60;
			$info{desc} = substr($info{desc},0,$info{maxlen}) if(length($info{desc}) > $info{maxlen});
		}
		elsif(m/<div class="talk">/) {
			last;
		}
	}
	if(!$info{image}) {
		return (error=>"Error parsing $url");
	}
	if($info{image} =~ m/^(.+)\/stream\/([^_\/]+)___[^\.\/]+\.([^\.]+)$/) {
		$info{host} = $1;
		$info{id} = $2;
		$info{imageext} = $3;
	}
	else {
		return (error=>"Error parsing $url");
	}
	$info{videoext} = "mp4";
	$info{desc} =~ s/^\s+//;
	my $basename = $info{year} . $info{month} . $info{day} . "_" . $info{id};
	$basename .= "_" . $info{desc} if($info{desc});
	push @data,$info{host} ."/stream/" . $info{id} . "__." . $info{videoext} . "\t" . $basename ."." . $info{videoext}; 
	push @data,$info{image} . "\t" . $basename . "." . $info{imageext}; 
    return (
		info=>\%info,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}


1;

__END__

#       vim:filetype=perl
