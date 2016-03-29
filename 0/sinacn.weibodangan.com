#!/usr/bin/perl -w

#DOMAIN : sinacn.weibodangan.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2016-01-06 01:44
#UPDATED: 2016-01-06 01:44
#TARGET : http://sinacn.weibodangan.com/user/5027019119/?max_id=3920445902323399

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

use MyPlace::URLRule::Utils qw/get_url get_html strnum new_html_data expand_url/;


sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/<a class="screen_name"/,$html);
	my @posts;
	foreach(@html) {
		my $post;
		if(m/id="weibo(\d+)"/) {
			$post->{id} = $1;
		}
		if(m/title="([\d\-]+) (\d\d):(\d\d):\d\d[^>]+href="[^"]*\/user\/(\d+)\//) {
			$post->{date} = $1 . $2 . $3;
			$post->{uid} = $4;
			$post->{date} =~ s/[-:_ ]//g;
		}
		while(m/<img[^>]+bigcursor" src="(http:\/\/[^"\/]+)\/[^"\/]+\/([^"]+)"/g) {
			push @{$post->{imgs}},"$1/large/$2";
		}
		while(m/<a class="href" data-url="([^"]+)"/g) {
			push @{$post->{links}},$1;
		}
		push @posts,$post if($post);
	}
	foreach(@posts) {
		if($_ and $_->{imgs} and @{$_->{imgs}}) {
			my $title = $_->{date};
			#? $_->{date} . "_" : "";
			$title .= $_->{uid} ? "_" . $_->{uid} : "";
			$title .= $_->{id} ? "_" . $_->{id} : "";
			my $count = scalar(@{$_->{imgs}});
			my $ext = ".jpg";
			if($count == 1 ) {
				$ext = $_->{imgs}[0];
				$ext =~ s/.*\././;
				$ext = ".jpg" unless($ext);
				push @data,$_->{imgs}[0] . "\t$title" . $ext;
			}
			else {
				my $idx = 1;
				foreach my $img(@{$_->{imgs}}) {
					my $ext = $img;
					$ext =~ s/.*\././;
					$ext = ".jpg" unless($ext);
					push @data,$img . "\t$title" . "_" .  strnum($idx,3) . $ext;
					$idx++;
				}
			}
		}
	}
	if($html =~ m/<a[^>]+id="next_page"[^>]+href="([^"]+)"/) {
		push @pass_data,$1;
	}
    return (
		info=>\@posts,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
		same_level=>1,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


