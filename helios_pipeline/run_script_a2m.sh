#!/bin/bash

SB=$1
OBS=$2

source /opt/lofarsoft/lofarinit.sh
source $HOME/env/bin/activate

/home/mkuiack1/bin/aartfaac2ms -mode 1  -use-dysco \
        "/opt/Data/"$SB"-"$OBS".vis" "/opt/Data/"$SB"-"$OBS".ms"  \
        $HOME/A12_pipeline/A12-AntennaField.conf

