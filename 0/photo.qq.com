#!/usr/bin/perl -w
#http://photo.qq.com
#Thu Jun 10 21:49:56 2010
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


use MyPlace::URLRule::Utils qw/get_url get_html/;
#use Encode;
#my $gb = find_encoding('gb2312');

#use MyPlace::HTML;

sub _process
{
    my ($url,$rule,$html) = @_;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my $photos = [];
	my %info;
	my $id;
	my $keys = '(desc|name|lloc|lloc2|origin_url|rawshoottime|url)';
    foreach(@html) {
		if(m/\}/) {
			if($info{origin_url}) {
				push @$photos,{%info};
			}
			%info = ();
		}
		elsif(m/"$keys"\s*:\s*(.+?)\s*,?\s*$/) {
			my $k = $1;
			my $v = $2;
			$v =~ s/(?:^"|"$)//g;
			$v =~ s/\\\//\//g;
			$info{$k} = $v;
		}
    }
            foreach my $photo (@{$photos})
            {
                if($photo->{'origin_url'}) 
                {
					use URI::Escape;
                   my $filename = $photo->{"name"} || $photo->{"desc"} || "";
				   $filename = uri_unescape($filename);
                   $filename =~ s/^[　\s]+//;
                   $filename =~ s/[\s　]+$//;
				   $filename = ($filename ? "${filename}_" : "") . ($photo->{rawshoottime} || $photo->{lloc} || $photo->{lloc2} || "") . ".jpg";
				   $filename =~ s/[:\\\/\?\*!]//g;
				   $filename =~ s/\s+/_/g;
                   push @data,$photo->{'origin_url'} . "\t" . $filename;
                }
            }
    return (data=>\@data,pass_data=>\@pass_data,base=>$url,no_subdir=>1,work_dir=>undef);
}

sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my $html = get_url($url,'-v','charset:gbk');
    return &_process($url,\%rule,$html);
}
1;


#       vim:filetype=perl
