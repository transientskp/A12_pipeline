#!/bin/bash

# Example: 
# time singularity exec -B /ssdstore/:/opt/Data,/zfs/helios/filer0/mkuiack1/:/opt/Archive  $HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_script.sh SB328 202007100001

MSFILE=$3
OBS=$2
SB=$1

#VISFILE="/opt/Data/vis/"$1
#VISFILE=$SB"-"$OBS"-lba_outer.vis"
#MSFILE="/opt/Data/mkuiack1/ms/"$SB"-"$OBS"-lba_outer.vis_dysco.ms"

# making work dirs
# mkdir /ssdstore/mkuiack1
# mkdir /ssdstore/mkuiack1/vis
# mkdir /ssdstore/mkuiack1/ms
# mkdir /ssdstore/mkuiack1/imgs

# move data to work on
# rsync -avP /zfs/helios/filer0/mkuiack1/202007100001/SB284-202007100001-lba_outer.vis /ssdstore/mkuiack1/vis
# mkdir /ssdstore/mkuiack1/

# load LOFAR tools images
# singularity  shell -B /ssdstore/mkuiack1/:/opt/Data,/zfs/helios/filer0/mkuiack1/:/opt/Archive  $HOME/lofar-pipeline.simg
#source /opt/lofarsoft/lofarinit.sh 

# making work dirs
#mkdir /opt/Data/mkuiack1
#mkdir /opt/Data/mkuiack1/vis
#mkdir /opt/Data/mkuiack1/ms
#mkdir /opt/Data/mkuiack1/imgs

# Convert portion of vis to ms
#time $HOME/soft/src/aartfaac2ms/build/aartfaac2ms -mode 1 -flag -interval 300 360 -use-dysco \
#	/opt/Archive/$OBS/$VISFILE $MSFILE \
#	$HOME/A12_pipeline/A12-AntennaField.conf

# AOquality to output dipole metrics for outlier flagging
# aoquality query_b StandardDeviation $MSFILE | tee SB281-AOQ_out.tsv 

# flag antenna in two steps first bad crosscorr, then all autocorr
time DPPP $HOME/A12_pipeline/parsets/antflag.parset msin=$MSFILE msin.datacolumn=DATA msout.datacolumn=FLAG_DATA
time DPPP $HOME/A12_pipeline/parsets/autoflag.parset msin=$MSFILE msin.datacolumn=FLAG_DATA  msout.datacolumn=FLAG_DATA

# Calculate DI calibration solution
time DPPP $HOME/A12_pipeline/parsets/DI_noapply.parset  msin=$MSFILE  \
	msin.datacolumn=FLAG_DATA cal.sourcedb=$HOME/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb  \
	cal.parmdb=$MSFILE/instrument.h5 cal.applysolution=false | tee $MSFILE-calcDI.log

# Apply DI Calibration solution 
time DPPP $HOME/A12_pipeline/parsets/DI_apply.parset  msin=$MSFILE  msin.datacolumn=FLAG_DATA \
	apply.sourcedb=$HOME/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb  \
	apply.parmdb=$MSFILE/instrument.h5 msout.datacolumn=DI_CORRECTED_DATA | tee $MSFILE-applyDI.log

# Calculate and apply DDE solution
time DPPP $HOME/A12_pipeline/parsets/DDE_cal.parset  msin=$MSFILE  \
	cal.sourcedb=$HOME/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb  \
	cal.h5parm=$MSFILE/dde_instrument.h5 msout.datacolumn=DDE_CORRECTED_DATA | tee $MSFILE-DDcal.log

# Subtract A-team
time DPPP $HOME/A12_pipeline/parsets/Subtract.parset  msin=$MSFILE  \
	sub.sourcedb=$HOME/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb  \
	sub.applycal.parmdb=$MSFILE/dde_instrument.h5 msin.datacolumn=DDE_CORRECTED_DATA \
	msout.datacolumn=SUBTRACTED_DATA | tee $MSFILE-sub.log

# Image final data product: SUBTRACTED_DATA
#time wsclean -size 3300 3300 -scale 0.05 -j 23 -parallel-gridding 6 -parallel-reordering 6 \
#	-no-update-model-required -pol I -weight briggs 0.0 -name /opt/Data/imgs/$SB-$OBS -niter 1000000 \
#	-fits-mask $HOME/A12_pipeline/masks/o3300_m1100.fits -reuse-primary-beam -multiscale \
#	-multiscale-scales 0,4,8,16,32,64 -auto-mask 3  -auto-threshold 0.3 -local-rms -mgain 0.8 -fit-beam \
#	-clean-border 21 -apply-primary-beam -join-channels  -channels-out 3 -data-column SUBTRACTED_DATA $MSFILE

array=(`seq 0 60`); array2=(`seq 1 61`); array3=(`seq -f "%05g" 0 60`) 

for ((i=0;i<${#array[@]};++i)); \
	do echo /opt/Data/imgs/"${array3[i]}"_$SB-$OBS; \
		time wsclean -size 2300 2300 -scale 0.05 -j  23  \
	       	-interval "${array[i]}" "${array2[i]}" -no-update-model-required -pol I -weight briggs 0.0 \
		-name /opt/Data/mkuiack1/calib_test/"${array3[i]}"_$SB-$OBS -niter 0 -no-dirty -auto-mask 3  -auto-threshold 0.3 \
		-local-rms -mgain 0.8  -fit-beam -clean-border 21   \
		-data-column SUBTRACTED_DATA $MSFILE; 
done


# exit singularity to rsync data from node
