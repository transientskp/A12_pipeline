#!/bin/bash

# Script to image polarization stokes parameters of AARTFAAC-12 images. 
# run by sbatch image_pols.sh
# Mark Kuiack 2020.



SB=$1
OBS=$2

MSFILE="/opt/Data/mkuiack1/"$SB"-"$OBS".ms"

START=$3
END=$4

source /opt/lofarsoft/lofarinit.sh

ls -d $MSFILE

# interval start
array=(`seq $START $END`)
# interval end
array2=(`seq $((START+1)) $((END+1))`)  
# filename number string 
array3=(`seq -f "%05g" $START $END`)


for ((i=0;i<${#array[@]};++i)); \
               do time wsclean -size 2300 2300 -scale 0.05 -j  12  \
                -interval "${array[i]}" "${array2[i]}" -no-update-model-required -pol U,V,Q -weight briggs 0.0 \
                -name "/opt/Data/mkuiack1/"$SB"-"$OBS"-pols/"${array3[i]}"_"$SB"-"$OBS -niter 0 -no-dirty -auto-mask 3  -auto-threshold 0.3 \
                -local-rms -mgain 0.8  -fit-beam   \
                -data-column SUBTRACTED_DATA $MSFILE;
done

