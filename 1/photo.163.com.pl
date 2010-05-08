#!/usr/bin/perl -w
#http://photo.163.com/photos/keaidejia_wq/
#Mon May  5 23:50:51 2008
use strict;

#================================================================
# apply_rule will be called,the result returned have these meaning:
# $result{base}          : Base url to build the full url
# $result{work_dir}      : Working directory (will be created if not exists)
# $result{data}          : Data array extracted from url,will be passed to $result{action}(see followed)
# $result{action}        : Command which the $result{data} will be piped to,can be overrided
# $result{no_subdir}     : Do not create sub directories
# $result{pass_data}     : Data array which will be passed to next level of urlrule
# $result{pass_name}     : Names of each $result{pass_data}
# $result{pass_arg}      : Additional arguments to be passed to next level of urlrule
#================================================================

sub apply_rule {
    my $url=shift;
    my %r;
    $r{base}=$url;
    my $data_url;
    my $u_id;
    if($url =~ m{/photos/([^/]+)/} or $url =~ m{/js/albumsinfo\.php\?user=([^&]+)}) {
        $data_url = "http://photo.163.com/js/albumsinfo.php?user=$1&from=guest";
        $u_id=$1;
    }
    else {
        open FI,"-|","netcat \'$url\'";
        while(<FI>) {
	    #<script type="text/javascript" src="/js/albumsinfo.php?user=keaidejia_wq&from=guest"></script>
            if(m{src=\"(/js/albumsinfo\.php\?user=([^&\"]+)[^\"]*)\"}) {
                $data_url = "http://photo.163.com$1";
                $u_id = $2;
                last;
            }
        }
        close FI;
    }
    if($data_url && $u_id) {
        open FI,"-|","netcat \'$data_url\'";
        while(<FI>) {
            if(/gAlbumsIds\[\d+\]\s*=\s*(\d+)\s*;/) {
                push @{$r{pass_data}},"/js/photosinfo.php?user=$u_id&aid=$1&from=guest"
            }
        }
        close FI;
    }
    $r{no_subdir}=1;
    $r{work_dir}=$u_id if($u_id);
    return %r;
}
