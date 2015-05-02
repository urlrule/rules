#!/usr/bin/perl -w
#http://tieba.baidu.com/f?kz=847145683
#Wed Aug  4 21:02:45 2010
use strict;

#================================================================
# apply_rule will be called with ($RuleBase,%Rule),the result returned have these meaning:
# $result{base}          : Base url to build the full url
# $result{work_dir}      : Working directory (will be created if not exists)
# $result{data}          : Data array extracted from url,will be passed to $result{action}(see followed)
# $result{action}        : Command which the $result{data} will be piped to,can be overrided
# $result{pipeto}        : Same as action,Command which the $result{data} will be piped to,can be overrided
# $result{hook}          : Hook action,function process_data will be called
# $result{no_subdir}     : Do not create sub directories
# $result{pass_data}     : Data array which will be passed to next level of urlrule
# $result{pass_name}     : Names of each $result{pass_data}
# $result{pass_arg}      : Additional arguments to be passed to next level of urlrule
#================================================================


use MyPlace::URLRule::Utils qw/get_url/;
#use MyPlace::HTML;

sub _process_tupian {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    while($html =~ /picID\s*:\s*'([^']+)',/g) {
        push @data,'http://imgsrc.baidu.com/forum/pic/item/' . "$1.jpg";
    }
    return (
        count=>scalar(@data),
        data=>[@data],
        pass_count=>scalar(@pass_data),
        pass_data=>[@pass_data],
        base=>$url,
        no_subdir=>1,
        work_dir=>$title,
    );
}


sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    while($html =~ /src="([^"]+\.jpg)"/g) {
		my $_ = $1;
		next if(m/bdstatic\.com/);
		next if(m/tieba\.baidu\.com/);
		next if(m/\/static/);
		next if(m/tiebaimg.com/);
		#next if(m/imgsrc\.baidu\.com\/forum\/pic\/item\//);
		s/\/forum\/w[^\/]+\/sign=[^\/]+\//\/forum\/pic\/item\//;
        push @data,$_;
    }
    return (
        count=>scalar(@data),
        data=>[@data],
        pass_count=>scalar(@pass_data),
        pass_data=>[@pass_data],
        base=>$url,
        no_subdir=>1,
        work_dir=>$title,
    );
}

use Encode qw/from_to/;

sub _process_photo_list {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
	my $html = shift;
	my @data;
	my @lines = split(/\{/,$html);
	my %info;
	foreach(@lines) {
		foreach my $k ((qw/total_num page_size total_page/)) {
			next if(defined $info{$k});
			$info{$k} = int($1) if(m/"$k":(\d+)/);
		}
		foreach my $k ((qw/title descr/)) {
			next if(defined $info{$k});
			if(m/"$k":"([^"]*)/) {
				$info{$k} = $1;
				from_to($info{$k},'gb2312','utf8');
			}
		}
		my ($id,$desc) = ("","");
		if(m/"pic_id":"([^"]+)/) {
			$id = $1;
		}
		if(m/"descr":"([^"]+)/) {
			$desc = $1;
			from_to($desc,'gb2312','utf8');
		}
		next unless($id);
		my $src = 'http://imgsrc.baidu.com/forum/pic/item/' . $id . '.jpg';
		if($desc) {
			$desc =~ s/&amp;/&/g;
			$src .= "\t$id\_$desc\.jpg";
		}
		push @data,$src;
	}
	return (
		info=>\%info,
		count=>scalar(@data),
		data=>\@data,
	);
}

sub new_picture_list {
	my $PAGE_SIZE = 200;
	my $kw = shift;
	my $id = shift;
	my $pn = shift(@_) || 1;
	my $ps = shift(@_) || 1;
	my $pe = shift(@_) || $PAGE_SIZE;
	my $r = scalar(time);
	return "http://tieba.baidu.com/photo/g/bw/picture/list?kw=$kw&alt=jview&rn=200&tid=$id&pn=$pn&ps=$ps&pe=$pe&info=1&_=$r";

}

sub _process_post {
	my $url = shift;
	my $rule = shift;
	my $html = shift;
	my $kw = shift;
	my $id = shift;
	my $page1 = new_picture_list($kw,$id);
    my $pagehtml = get_url($page1,'-v');
	my %r = _process_photo_list($page1,$rule,$pagehtml);
	my @pass_data;
	
	return %r if(!$r{info});
	my $lastpage = $r{info}->{'total_page'};
	return %r if(!$lastpage);
	return %r if($lastpage < 2);
	$r{pass_count} = 0;
	for my $pn(2 .. $lastpage) {
		$r{pass_count}++;
		push @pass_data,new_picture_list($kw,$id,$pn);
	}
	$r{pass_data} = [@pass_data];
	$r{level} = 0;
	$r{title} = $r{info}->{title} if(!$r{title});
	return %r;
}

sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
	my $html = get_url($url,'-v');
	#if($url =~ m/\/p\/(\d+)/) {
	#	my $id = $1;
	#	if($html =~ m/<meta[^>]+furl="[^"]+?kw=([^&">]+)/) {
	#		return &_process_post($url,\%rule,$html,$1,$id);
	#	}
	#}
	if($url =~ m/\/picture\/list/) {
		return &_process_photo_list($url,\%rule,$html);
	}
    elsif($url =~ m/tupian\/getAlbum\//) {
        return &_process_tupian($url,\%rule,$html);
    }
    else {
        return &_process($url,\%rule,$html);
    }
}



#       vim:filetype=perl
1;
