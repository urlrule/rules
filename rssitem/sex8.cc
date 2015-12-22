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

use MyPlace::URLRule::Utils qw/get_url html2text parse_html/;
sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	$html =~ s/(<div[^>]+>)/\n$1/g;
#	use MyPlace::Debug;debug_log($html);
    my @html = split(/\n/,$html);
	my %PARSER = (
		'description'=>[
			'<div id="read_tpc"','<td class="td_bottom_tool">',
			undef,										 # extractor
			1,										 # max captures
			undef,										 # text joiner	
			1,											 # stringify
		],
		'desc2'=>[
			'<div class="f14" id="read_tpc">','<div id="w_tpc" class="c">',
			udnef,
			1,
			undef,
			1,
		],
		'title'=>[
			qr/<title/,qr/<\/title>/i,
			\&html2text,
			1,
			undef,
			1,
		],
	);
	my %R = parse_html(\%PARSER,@html);
	if($R{title}) {
		$R{title} =~ s/\s*-\s*[^-]+-\s*[^-]+$//;
	}
	$R{description} = $R{description} || $R{desc2};
	delete $R{desc2};
    return (
        base=>$url,
		%R,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


