#!/bin/bash

SB=$1
OBS=$2

MSFILE="/opt/Data/idayan/"$SB"-"$OBS".ms"

START=$3
END=$4

source /opt/lofarsoft/lofarinit.sh

ls $MSFILE

array=(`seq $START $END`)
array2=(`seq $((START+1)) $((END+1))`)  
array3=(`seq -f "%05g" $START $END`)

#for ((i=0;i<${#array[@]};++i));
#	do echo "${array[i]}" "${array2[i]}" "${array3[i]}";
#done
#
for ((i=0;i<${#array[@]};++i)); 
	do echo /opt/Data/imgs/"${array3[i]}"_$SB-$OBS;
	wsclean -size 2300 2300 -scale 0.05 -j 6  \
                -interval "${array[i]}" "${array2[i]}" -no-update-model-required -pol I -weight briggs 0.0 \
                -name /opt/Data/idayan/"$SB"-"$OBS"-cleaned/"${array3[i]}"_$SB-$OBS-CLEAN -niter 1000000 \
                -multiscale -multiscale-scales 0,4,8,16,32,64 -fits-mask $HOME/A12_pipeline/masks/o2300_m1050.fits  \
                -auto-mask 3  -auto-threshold 0.3 -local-rms -mgain 0.8 -fit-beam  \
                -data-column SUBTRACTED_DATA $MSFILE;
 
#	wsclean -size 2300 2300 -scale 0.05 -j 6 -parallel-gridding 6 -no-reorder \
#		-interval "${array[i]}" "${array2[i]}" -no-update-model-required -pol I -weight briggs 0.0 \
#		-name /opt/Data/idayan/"$SB"-"$OBS"-cleaned/"${array3[i]}"_$SB-$OBS-CLEAN -niter 1000000 \
#		-multiscale -multiscale-scales 0,4,8,16,32,64 -fits-mask $HOME/A12_pipeline/masks/o2300_m1050.fits  \
#		-auto-mask 3  -auto-threshold 0.3 -local-rms -mgain 0.8 -fit-beam  \
#		-data-column SUBTRACTED_DATA $MSFILE; 
done
# obs-date wrong
#wsclean -size 2300 2300 -scale 0.05 -j 6 -parallel-gridding 6 -no-reorder  \
#               -interval $START $((END+1)) -intervals-out $((END+1)) -no-update-model-required -pol I -weight briggs 0.0 \
#               -name /opt/Data/idayan/"$SB"-"$OBS"-cleaned/"$SB"-"$OBS"_CLEAN -niter 1000000 \
#               -multiscale -multiscale-scales 0,4,8,16,32,64 -fits-mask "$HOME/A12_pipeline/masks/o2300_m1050.fits"  \
#               -auto-mask 3  -auto-threshold 0.3 -local-rms -mgain 0.8 -fit-beam  \
#               -data-column SUBTRACTED_DATA  $MSFILE;



