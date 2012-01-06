#!/usr/bin/perl -w
#http://www.bookcool.com/pdf/21/index.htm
#Sat Nov  1 07:38:44 2008
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
#<FONT face=æ¥·ä½_GB2312 color=#000000>ç¤¾ä¼ç§å­¦ç±» 3 
#<TD align=left width="50%"><A 
#      href="http://www.bookcool.com/pdf/21/ts021095.pdf"># # # ( # ) </A></TD>
#          <TD align=left width="50%"><A 
#                href="http://www.bookcool.com/pdf/21/ts021096.pdf"># # # # </A></TD></TR>
#                  <TR>

sub apply_rule {
    my $rule_base= shift(@_);
    my %rule = %{shift(@_)};
    my %r;
    $r{pipeto}="exec_threads 5";
    $r{no_subdir}=1;
    open FI,"-|","netcat \'$rule_base\'|gb2utf|sed -e \'s\/\\r\\n\/\/gm\'";
    while(<FI>) {
        unless($r{work_dir}) {
            if(m/<FONT face=楷体_GB2312 color=#000000>\s*([^\n\r]+)\s*/){ 
                $r{work_dir}=$1;
                $r{work_dir} =~ s/\s+$//g;
                $r{work_dir} =~ s/^\s+//g;
            }
        }
        if(m/href\s*=\s*"([^"]+)\/([^\/"]+)\.([^\."]+)"\s*\>\s*([^<>]+)\s*\<\s*\/\s*A\>/) {
            push @{$r{data}},"download -u \"$1/$2.$3\" -s \"$2 - $4.$3\"";
        }
    }
    close FI;
    return %r;
}


1;
