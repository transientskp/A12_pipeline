#!/bin/bash

SB=$1

START=$2
END=$3

SLICE=${START:0:10}"T"${START:11:8}"-"${END:11:8}

INPUT=$4

source /opt/lofarsoft/lofarinit.sh
#source $HOME/env/bin/activate

echo $(ls "/opt/Archive/"$INPUT)

echo "Running afedit"
/home/mkuiack1/local/bin/usr/local/bin/afedit -utc-start $START -utc-end $END \
	"/opt/Archive/"$INPUT "/opt/Data/"$SB"-"$SLICE".vis"

echo $(ls "/opt/Data/"$SB"-"$SLICE".vis")
echo "Running aartfaac2ms"
/home/mkuiack1/local/bin/usr/local/bin/aartfaac2ms -mode 1  -use-dysco \
        "/opt/Data/"$SB"-"$SLICE".vis" "/opt/Data/"$SB"-"$SLICE".ms"  \
        $HOME/A12_pipeline/A12-AntennaField.conf


