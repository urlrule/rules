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


use MyPlace::HTTPGet;
#use Encode;
#my $gb = find_encoding('gb2312');

#use MyPlace::HTML;

sub _process
{
    my ($url,$rule,$html) = @_;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
    foreach(@html)
    {
        $_ =~ s/^\s*_Callback\s*\(//;
        $_ =~ s/^\s*\);\s*$/;/;
        $_ =~ s/"\s+:\s+/"=>/g;
		s/([\@\%\$])/\\$1/g;
    }
    my $photo_list_ref = eval join("\n",@html);
	print STDERR "Error: (eval) $@\n" if($@);
    if($photo_list_ref and ref $photo_list_ref)
    {
        my $photos = $photo_list_ref->{"pic"};
        if($photos and ref $photos)
        {
            foreach my $photo (@{$photos})
            {
                if($photo->{'origin_url'}) 
                {
					use URI::Escape;
                   my $filename = $photo->{"name"} || "";
				   $filename = uri_unescape($filename);
                   $filename =~ s/^[　\s]+//;
                   $filename =~ s/[\s　]+$//;
                   $filename .= "_" . $photo->{"lloc2"} . ".jpg";
                   push @data,$photo->{'origin_url'} . "\t" . $filename;
                }
            }
        }
    }
    return (data=>\@data,pass_data=>\@pass_data,base=>$url,no_subdir=>1,work_dir=>undef);
}

sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my $http = MyPlace::HTTPGet->new();
    my (undef,$html) = $http->get($url,'charset:gbk');
    return &_process($url,\%rule,$html);
}
1;


#       vim:filetype=perl
