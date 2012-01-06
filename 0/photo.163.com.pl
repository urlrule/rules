#!/usr/bin/perl -w
#http://photo.163.com/photos/keaidejia_wq/105231587/
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
    my $a_id;
    if( $url =~ m{/js/photosinfo\.php\?user=([^&]+)&aid=([^&]+)} or 
        $url =~ m{/photos/([^/]+)/([^/]+)/} 
    ) {
        $u_id = $1;
        $a_id = $2;
        $data_url = "http://photo.163.com/js/photosinfo.php?user=$u_id&aid=$a_id&from=guest";
    }
    else {
        open FI,"-|","netcat \'$url\'";
        while(<FI>) {
            #<script type="text/javascript" src="/js/photosinfo.php?user=keaidejia_wq&aid=105231587&from=guest"></script>
            if(m{src=\"(/js/photosinfo\.php\?user=([^&\"]+)&aid=([^&\"]+)[^\"]*)\"}) {
                $data_url = "http://photo.163.com$1";
                $u_id = $2;
                $a_id = $3;
                last;
            }
        }
        close FI;
    }
    if($data_url) {
        open FI,"-|","netcat \'$data_url\'";
        while(<FI>) {
#gPhotosInfo[4093740825] = [841,2,"500x750","","http://img.photo.163.com/wwqUmL59aC6xBnGkwU3_aw==/814025632647248714.jpg","http://img.photo.163.com/7Uty746sXDMmIdCB0bdZqA==/814025632647248713.jpg"];
            if(/gPhotosInfo\[(\d+)\]\s*=\s*\[\s*(\d+)\s*,/) {
                my $id=$1;
                my $s_id=$2;
                if(/gPhotosInfo\[\d+\]\s*=\s*\[([^,]*,){5}\s*\"([^\",]+)\"\s*\]\s*;/) {
                    push @{$r{data}},$2;
                }
                else {
                    push @{$r{data}},"http://img$s_id.photo.163.com/$u_id/$a_id/$id.jpg";
                }
            }
        }
        close FI;
    }
    $r{work_dir}=$a_id if($a_id);
    return %r;
}
1;
