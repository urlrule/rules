#!/usr/bin/perl -w

#DOMAIN : www.sexinsex.net
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-11-23 19:44
#UPDATED: 2015-11-23 19:44
#TARGET : http://www.sexinsex.net/bbs/thread-4583185-1-1.html rssitem

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

use MyPlace::URLRule::Utils qw/get_url html2text parse_html uri_rel2abs/;
sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	$html =~ s/(<div[^>]+>)/\n$1/g;
    my @html = split(/\n/,$html);
	my %PARSER = (
		'threads'=>[
			'<div class="s8-c1">','<div class="row odd clearfix">',
		],
		'threads2'=>[
			'<tr align="center" class="tr3 t_one">','<\/tr>',
		],
		'title'=>[
			qr/<title/,qr/<\/title>/i,
			\&html2text,
			1,
			undef,
			1,
		],
	);
	#use MyPlace::Debug;debug_log(@html);
	my %R = parse_html(\%PARSER,@html);
	if($R{title}) {
		$R{title} =~ s/\s*-\s*[^-]+$//;
		$R{title} =~ s/\s*\|.*$//;
	}
	foreach(@{$R{threads}},@{$R{threads2}}) {
		my %a;
		if(m/<a href="\/?u\.php\?action=show&uid[^>]+>([^>]+)<\/a><br>(\d\d\d\d-\d+-\d+)</s) {
			$a{author} = html2text($1);
			$a{pubdate} = html2text($2);
		}
		elsif(m/<a href="\/?u\.php\?action=show&uid[^>]+>([^>]+)<\/a>[^<]+<div[^>]+>(\d\d\d\d-\d+-\d+)</s) {
			$a{author} = html2text($1);
			$a{pubdate} = html2text($2);
		}
		if(m/<a href="thread-htm-fid-(\d+)-type-(\d+)[^"]+"[^>]*>(.*?)<\/a>[^<]*<a href="([^"]*read-htm-tid-\d+[^"]*\.html)"[^>]*>(.+?)<\/a>/s) {
			$a{fid} = $1;
			$a{typeid} = $2;
			$a{guid} = $4;
			$a{title} = html2text($3) . html2text($5);
			$a{link} = uri_rel2abs($a{guid},$url);
		}
		elsif(m/<a href="(read-htm-tid-\d+[^"]*\.html)"[^>]*class="subject"[^>]*>(.+?)<\/a>/s) {
			$a{guid} = $1;
			$a{title} = html2text($2);
			$a{link} = uri_rel2abs($a{guid},$url);
		}
		elsif(m/<a href="(read-htm-tid-\d+[^"]*\.html)">(.+?)<\/a>/s) {
			$a{guid} = $1;
			$a{title} = html2text($2);
			$a{link} = uri_rel2abs($a{guid},$url);
		}
		if($a{guid} and ($a{title} ne '1')) {
			$a{guid} =~ s/(read-htm-tid-\d+).*$/$1.html/;
			$a{guid} = "S8_" . $a{guid};
			push @{$R{item}},\%a;
		}
	}
	delete $R{threads};
	delete $R{threads2};
    return (
        base=>$url,
		%R,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


