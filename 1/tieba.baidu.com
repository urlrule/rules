#!/usr/bin/perl -w
#http://tieba.baidu.com/f?kz=847145683
#http://tieba.baidu.com/%BB%F4%CB%BC%D1%E0/tupian/view/1
#http://tieba.baidu.com/%BB%F4%CB%BC%D1%E0/tupian/list/%E7%8E%AB%E7%91%B0%E6%B1%9F%E6%B9%96%E5%89%A7%E7%85%A7
#Wed Aug  4 21:05:19 2010
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
use Encode qw/from_to/;

sub _process_view {
    my ($url,$rule,$html) = @_;
    my $title;
    my @pass_data;
    my @pass_name;
    my $pic_per_page=12;
    my $api_url = $url;
    $api_url =~ s/\/tupian\/view.*/\/tupian\/getAlbum/;
    $html =~ s/[\n\r]+//g;
    while($html =~ m/albumName:"([^"]+)",\s*albumPicNum:"(\d+)",/g) {
        for(my $i=1;($i-1)*$pic_per_page<=$2;$i++) {
            push @pass_data,"$api_url/$1/$i";
            push @pass_name,$1;
        }
    }
    return (
        count=>0,
        data=>undef,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        pass_name=>\@pass_name,
        base=>$url,
        no_subdir=>0,
        work_dir=>$title,
    );
}
sub _process_tupian {
    my ($url,$rule,$html) = @_;
    my $title;
    my @pass_data;
    my $pic_count=0;
    my $pic_per_page=12;
    my @html = split(/\n/,$html);
    my $api_url = $url;
    $api_url =~ s/\/list\//\/getAlbum/;
    foreach(@html) {
        last if($title and $pic_count);
        if((!$title) and m/var\s*curAlbumName\s*=\s*'([^']+)';/) {
            $title = $1;
        }
        elsif((!$pic_count) and m/var\s*picTotalNum\s*=\s*'(\d+)';/) {
            $pic_count = $1;
        }
    }
    for(my $i=1;($i-1)*$pic_per_page<=$pic_count;$i++) {
        push @pass_data,"$api_url/$i";
    }
    return (
        count=>0,
        data=>undef,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
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
    my @html = split(/\n/,$html);
    my $pn=0;
    my $pre;
    my $suf;
    foreach(@html) {
        if((!$title) and /title:"([^"]+)"/) {
            $title = $1;
        }
        while(/href=([^<>\s]+pn=)(\d+)([^\s><]*)/g) {
            if($2 > $pn) {
                $pre = $1;
                $suf = $3;
                $pn = $2;
            }
        }
    }
    if($pre) {
        $suf = "" unless($suf);
        my $i=0;
        while($i<=$pn) {
            push @pass_data,$pre . $i . $suf;
            $i+=1;
        }
    }
    else {
        push @pass_data,$url;
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
	my $pl_url = new_picture_list($kw,$id);
	my $pl_json = get_url($pl_url,'-v');
	my %info;
	foreach (split(/\{/,$pl_json)) {
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
	}
	if($info{total_page}) {
		$info{count} = 0;
		$info{pass_data} = [];
		$info{pass_count} = 0;
		foreach my $pn(1 .. $info{total_page}) {
			$info{pass_count}++;
			push @{$info{pass_data}},new_picture_list($kw,$id,$pn);
		}
		$info{title} = $info{title} || $id;
		return %info;
	}
	else {
        return &_process($url,$rule,$html);
	}
}

sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my $html = get_url($url,'-v');
	#use Encode qw/from_to/;
	#from_to($html,'gbk','utf8');
	if($url =~ m/\/p\/(\d+)/) {
		my $id = $1;
		if($html =~ m/<meta[^>]+furl="[^"]+?kw=([^&">]+)/) {
			return &_process_post($url,\%rule,$html,$1,$id);
		}
	}
    elsif($url =~ m/tupian\/list\//) {
        return &_process_tupian($url,\%rule,$html);
    }
    elsif($url =~ m/tupian\/view\//) {
        return &_process_view($url,\%rule,$html);
    }
    else {
        return &_process($url,\%rule,$html);
    }
}



#       vim:filetype=perl
1;
