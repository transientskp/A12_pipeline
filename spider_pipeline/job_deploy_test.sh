#!/bin/bash

#[ ! -d "$HOME"/testdir ] && mkdir "$HOME"/testdir

#[ ! -n "$(ls -A "$HOME"/testdir)" ] && echo "Empty..."

IFS='.' tokens=($1)
#echo $1
#echo ${tokens[0]}.ms
#echo $1

for sb in /project/aartfaac/Data/*.vis;
do

 echo "Submitting to squeue, SB: " "$sb"
 IFS='/' parts=($sb)
 echo "${parts[4]}"
done
