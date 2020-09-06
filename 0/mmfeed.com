#!/usr/bin/perl -w
#DOMAIN : mmfeed.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-02-18 04:51
#UPDATED: 2020-02-18 04:51
#TARGET : http://www.mmfeed.com/viewthread.php?tid=1233696&extra=page%3D4%26amp%3Bfilter%3D0%26amp%3Borderby%3Ddateline
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_mmfeed_com;
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

use MyPlace::WWW::Utils qw/html2text strnum get_url decode_title get_safename url_getname new_html_data new_file_data/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v','charset:gbk');
    my @data;
    my @pass_data;
	my @text;
    my @html = split(/\n/,$html);
	my $start = 0;
	my $end = undef;
	my @images;
	foreach(@html) {
		if(m/<center><input class="button" type="submit" name="loginsubmit"/) {
			return (
				error=>"Login required",
				killme=>1,
			);
		}
		if($start>=2) {
		}
		elsif(m/<span class="bold">/) {
			$start++;
			next if($start<2);
		}
		else {
			next;
		}
		if(m/^\s*<\/td><\/tr>/) {
			$end = 1;
		}
		if((!$opts->{title}) and m/<span class="bold">([^<]+)/) {
			$self->get_print(decode_title($1,"utf-8"),"title",$opts);
		}
		while(m/<img[^>]+src="([^"]+)[^>]+/g) {
			push @images,$1;
		}
		last if($end);
		push @text,$_;
	}
	$opts->{name} = $opts->{title};
	if($url =~ m/[&\?]tid=(\d+)/) {
		$opts->{name} = $opts->{title} ? $opts->{title} : $1;
		$opts->{title} = $opts->{title} ? "$1_$opts->{title}" : $1;
	}
	#push @data,new_html_data(join("\n",@text),$opts->{title},$url) if(@text);
	my $prefix;
	if(scalar(@images) > 2) {
		$prefix = $opts->{title} ? $opts->{title} . "/" : "";
	}
	else {
		$prefix = "";
	}
	if(@text) {
		my @new;
		push @new,$opts->{name} . "\\n" . "-"x40 . "\\n\\n";
		push @new,html2text(@text);
		push @new,"\\n" . "-"x40 . "\\n$url\\n";
		push @data,new_file_data($prefix . $opts->{title} . ".txt",@new);
	}
	my $count=0;
	foreach(@images) {
		$count++;
		my $ext = ".jpg";
		$ext = ".$1" if(m/\.([^\.]+)$/);
		push @data,$_ . "\t" . $prefix . strnum($count,3) . $ext;
	}
    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
    );
}

return new MyPlace::URLRule::Rule::0_mmfeed_com;
1;

__END__

#       vim:filetype=perl


