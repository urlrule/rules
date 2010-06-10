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
use Encode;
my $gb = find_encoding('gb2312');

#use MyPlace::HTML;

sub get_album_list {
    my $code="";
    foreach(@_) {
        $_ =~ s/^\s*_Callback\s*\(//;
        $_ =~ s/^\s*\);/;/;
        $_ =~ s/\s+:\s+/=>/g;
        $code = $code . $_; 
    }
    return eval($code);
}

sub _process
{
    my ($url,$rule,$html) = @_;
    my @data;
    my @pass_data;
    my @pass_name;
    my @html = split(/\n/,$gb->decode($html));
    my $list_ref = &get_album_list(@html);
    return undef unless($list_ref and ref $list_ref);
    my $albums = $list_ref->{"album"};
    return undef unless($albums and ref $albums);
    my $photo_url = $url;
    $photo_url =~ s/list_album/list_photo/;
    $photo_url =~ s/\/\/alist\./\/\/plist./;
    $photo_url =~ s/\/\/xalist\./\/\/xaplist./;
    foreach my $album (@{$albums})
    {
        my $album_name = $album->{"name"};
        $album_name =~ s/^[\s　]+//;
        $album_name =~ s/[\s　]+$//;
        $album_name = "_noname" unless($album_name);
        push @pass_data,$photo_url  . '&albumid=' . $album->{id};
        push @pass_name,$album_name;
    }
    return (pass_name=>\@pass_name,data=>\@data,pass_data=>\@pass_data,base=>$url,no_subdir=>0,work_dir=>undef);
}

sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my $http = MyPlace::HTTPGet->new();
    my (undef,$html) = $http->get($url);
    my ($status,@result) =  &_process($url,\%rule,$html);
    return $status ? ($status,@result) : ('base'=>$url);
}
1;


#       vim:filetype=perl
