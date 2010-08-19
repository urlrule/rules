#!/usr/bin/perl -w
#http://blog.163.com/imjihye_fans/album/
#Thu Aug 19 01:44:40 2010
use strict;

#use MyPlace::HTTPGet;
#use MyPlace::HTML;
use MyPlace::163::Blog;

sub apply_rule {
    my $url = shift(@_);
    my $rule = shift(@_);
    my $id;
    my @querys;
    if($url =~ m/photo\.blog\.163\.com\/([^\/\?]+)\??(.*)$/) {
        $id = $1;
        @querys = split('&',$2);
    }
    return (count=>0,pass_count=>0) unless($id);
    my $blog = MyPlace::163::Blog->new($id);
    my $albums = $blog->get_albums(@querys);
    return (count=>0,pass_count=>0) unless($albums);
    my @pass_data;
    my @pass_name;
    foreach(@{$albums}) {
        push @pass_data,$_->{purl};
        push @pass_name,$_->{name};
    }
    return (
        count=>0,
        pass_data=>\@pass_data,
        pass_name=>\@pass_name,
        work_dir=>$id,
        pass_count=>scalar(@pass_data),
    );
}


1;

__END__

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
# urlrule_quick_parse($url,$rule,$data_exp,$data_map,$pass_exp,$pass_map,$charset)
# urlrule_parse_data($url,$rule,$data_exp,$data_map,$charset)
# urlrule_parse_pass_data($url,$rule,$pass_exp,$pass_map,$charset)
#================================================================

#       vim:filetype=perl
