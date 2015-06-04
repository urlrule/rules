#!/bin/sh
echo Writing disk usage to DU.txt
du -s --time -B M -c * | tee DU.txt
echo Writing file lists to FILES.txt
find * | tee FILES.txt

