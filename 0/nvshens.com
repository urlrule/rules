#!/usr/bin/perl -w
#DOMAIN : www.nvshens.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2018-08-31 01:37
#UPDATED: 2018-08-31 01:37
#TARGET : https://www.nvshens.com/g/26691/
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_www_nvshens_com;
use MyPlace::URLRule::Utils qw/get_url create_title extract_title/;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

=method1
sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
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
	   'pages_limit'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}
=cut


sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    #my @html = split(/\n/,$html);
	my %info;
	if($html =~ m{<ul id="utag"><li><a[^>]+href='/(girl/\d+/)'[^>]*>(.+?)</a></li>}) {
		$info{profile} = $1;
		$info{uname} = $2;
	}
	if($rule->{level_desc} && ($rule->{level_desc} eq 'info')){
		return %info;
	}
	if($html =~ m/<h1 id="htilte">(.+?)<\/h1>/) {
		$info{title} = create_title($1);
	}
	if($html =~ m{<div id="ddesc" class="albumInfo">(.+?)</div>}) {
		$info{desc} = extract_title($1);
	}
	if($html =~ m{<div id="dinfo" class="albumInfo">[^<]+<span style='color: [^>]+>(\d+)}) {
		$info{pics} = $1;
	}
	if($html =~ m{<ul[^>]+id="hgallery"[^>]*>[^<>]*<img src=["']([^'"]*)/([^'"/]+)/([^'"/]+)(/|/s/)0\.jpg}) {
		$info{root} = "$1/$2/$3$4";
		$info{prefix} = "$2_$3_";
		push @data,$info{root} . "0.jpg\t$info{prefix}000.jpg";
		if($info{pics} && $info{pics}>0) {
			foreach(1 .. $info{pics}) {
				if($_ < 10) {
					$_ = "00$_";
				}
				elsif($_ < 100) {
					$_ = "0$_";
				}
				push @data,$info{root} . "$_.jpg" . "\t" . $info{prefix} . $_ . ".jpg";  
			}
		}
	}
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

return new MyPlace::URLRule::Rule::0_www_nvshens_com;
1;

__END__

#       vim:filetype=perl


