#!/usr/bin/perl -w

#DOMAIN : wrshu.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2015-05-02 13:30
#UPDATED: 2015-05-02 13:30
#TARGET : http://wrshu.com/xiaoshuo/txt/book32732.html

use strict;
no warnings 'redefine';

=metnod1
sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>'<dd><a[^>]+href="([^"]+\/([^"]+)_wrshu\.com\.txt)"',
       'data_map'=>'"$1\t$2.txt"',

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
       'charset'=>'gb2312'
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url extract_text html2text create_title/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v','charset:gb2312');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my %info = extract_text(
		[qw/title cover catagory author summary download/],
		{
			title=>[
				qr/<h2 class="h730 ht">([^<]+)/,
			],
			cover=>[
				qr/<img[^>]+src="([^"]+\/UploadPic\/[^"]+\.jpg)"/,
			],
			catagory=>[
				qr/<b>小说分类：<\/b>([^<]+)/,
			],
			author=>[
				qr/<b>小说作者：([^<]+)/,
			],
			summary=>[
				qr/<div class="textcontent" id="textcontent">/,
			],
			download=>[
				qr/<dl>/,
				qr/<\/dl>/,
			],
		},
		@html,
	);
	my $basename = $info{title} . ($info{author} ? "_" . $info{author} : "");
	$basename = create_title($basename,1);
	if($info{download}) {
		$info{download} = join("",@{$info{download}});
		while($info{download} =~ m/<dd><a[^>]+href="([^"]+\/([^"]+)\.txt)"/g) {
			push @data,"$1\t$basename.txt";
		}
		delete $info{download};
	}
	if($info{cover}) {
		push @data,$info{cover} . "\t$basename.jpg";
	}
	if($info{catagory}) {
		$info{catagory} =~ s/\s*-\s*/\//g;
	}
    return (
		info=>\%info,
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
		title=>$info{catagory},
    );
}

=cut

1;

__END__

#       vim:filetype=perl


