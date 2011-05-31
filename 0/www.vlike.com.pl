#!/usr/bin/perl -w
#http://www.moko.cc/post/5163.html
#Thu Jun 25 15:13:09 2009
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
use MyPlace::HTML;
use Encode qw/from_to/;


sub apply_rule {
		sub get_name {
			my $url = shift;
			$url =~ s/.+\///g;
			return $url;
		}
    my $rule_base= shift(@_);
    my %rule = %{shift(@_)};
    my %r;
	my %data;
    $r{base}=$rule_base;
    open FI,"-|","netcat \"$rule_base\"";
    while(<FI>) {   
        if(!$r{work_dir}) {
            $r{work_dir} = get_title($_);
            if($r{work_dir}) {
                from_to($r{work_dir},'GBK','UTF8');
                $r{work_dir} =~ s/(\d+[Pp])?\s*_[^_]+_未了美女网\s*$//;
                $r{work_dir} =~ s/_//g;
            }
        }
        my @imgs = get_props("img","src",$_);
        foreach(@imgs) {
        #http://www.tu365.net/girl/UploadFiles_9401/201004/06/20100406142838148911_s.jpg
            if($_ =~ m/_s\.jpe?g$/i) {
                $_ =~ s/_s\.(jpe?g)$/_big.$1/i;
                $data{$_ . "\t" . &get_name($_)}=1;
            }
        }
    }
    close FI;
    if($r{work_dir}) {
        $r{work_dir} =~ s/\s*-.*$//;
    }
	push @{$r{data}},keys %data;
    return %r;
}
