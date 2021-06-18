#!/bin/bash

# Example: 
# time singularity exec -B /ssdstore/:/opt/Data,/zfs/helios/filer0/mkuiack1/:/opt/Archive  $HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_script.sh SB328 202007100001

OBS=$2
SB=$1

MSFILE="/opt/Data/mkuiack1/"$SB"-"$OBS".ms"


# making work dirs
#mkdir /opt/Data/ack1
mkdir /opt/Data/mkuiack1/$SB-$OBS
mkdir /opt/Data/mkuiack1/$SB-$OBS/parsets
mkdir /opt/Data/mkuiack1/$SB-$OBS/imgs
mkdir /opt/Data/mkuiack1/$SB-$OBS/logs

source /opt/lofarsoft/lofarinit.sh 
source $HOME/env/bin/activate

SOURCEDB='Ateam_LBA_CC.sourcedb'

scp -r $HOME/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb /opt/Data/mkuiack1/$SB-$OBS/$SOURCEDB


# load LOFAR tools images
#singularity  shell -B /ssdstore/mkuiack1/:/opt/Data,/zfs/helios/filer0/mkuiack1/:/opt/Archive  $HOME/lofar-pipeline.simg
#source /opt/lofarsoft/lofarinit.sh 

# AOquality to output dipole metrics for outlier flagging
aoquality query_b StandardDeviation $MSFILE | tee "/opt/Data/mkuiack1/"$SB"-"$OBS"/parsets/"$SB"-"$OBS"-AOQ_STD.tsv"
aoquality query_b SumP2 $MSFILE | tee "/opt/Data/mkuiack1/"$SB"-"$OBS"/parsets/"$SB"-"$OBS"-AOQ_SumP2.tsv"

# Create antflag.parset from aoquality outputs
python $HOME/calc_antflags.py $SB $OBS

# flag antenna in two steps first bad crosscorr, then all autocorr
time DPPP /opt/Data/mkuiack1/$SB-$OBS/parsets/antflag.parset msin=$MSFILE msin.datacolumn=DATA msout.datacolumn=PROCESSED_DATA
#time DPPP $HOME/A12_pipeline/parsets/antflag.parset msin=$MSFILE msin.datacolumn=DATA  msout.datacolumn=FLAG_DATA
time DPPP $HOME/A12_pipeline/parsets/autoflag.parset msin=$MSFILE msin.datacolumn=PROCESSED_DATA  msout.datacolumn=PROCESSED_DATA
time DPPP $HOME/A12_pipeline/parsets/MADflag.parset msin=$MSFILE msin.datacolumn=PROCESSED_DATA  msout.datacolumn=PROCESSED_DATA
#time DPPP $HOME/A12_pipeline/parsets/antflag.parset msin=$MSFILE msin.datacolumn=FLAG_DATA  msout.datacolumn=FLAG_DATA

# Calculate DI calibration solution
time DPPP $HOME/A12_pipeline/parsets/DI_noapply.parset  msin=$MSFILE msin.datacolumn=PROCESSED_DATA \
	cal.sourcedb=/opt/Data/mkuiack1/$SB-$OBS/$SOURCEDB \
	cal.parmdb=$MSFILE/instrument cal.applysolution=false #| tee "/opt/Data/mkuiack1/"$SB"-"$OBS"/logs/$MSFILE-calcDI.log"

echo "### DI time"

# Apply DI Calibration solution 
time DPPP $HOME/A12_pipeline/parsets/DI_apply.parset  msin=$MSFILE  msin.datacolumn=PROCESSED_DATA \
	apply.sourcedb=/opt/Data/mkuiack1/$SB-$OBS/$SOURCEDB \
	apply.parmdb=$MSFILE/instrument msout.datacolumn=PROCESSED_DATA #| tee "/opt/Data/mkuiack1/"$SB"-"$OBS"/logs/"$MSFILE"-applyDI.log"


# Calculate and apply DDE solution
time DPPP $HOME/A12_pipeline/parsets/DDE_cal.parset  msin=$MSFILE msin.datacolumn=PROCESSED_DATA  \
	cal.sourcedb=/opt/Data/mkuiack1/$SB-$OBS/$SOURCEDB  \
	cal.h5parm=$MSFILE/dde_instrument.h5 msout.datacolumn=PROCESSED_DATA #| tee "/opt/Data/mkuiack1/"$SB"-"$OBS/logs/$MSFILE-DDcal.log
echo "### time DDE cal"

# Subtract A-team
time DPPP $HOME/A12_pipeline/parsets/Subtract.parset  msin=$MSFILE  \
	sub.sourcedb=/opt/Data/mkuiack1/$SB-$OBS/$SOURCEDB  \
	sub.applycal.parmdb=$MSFILE/dde_instrument.h5 msin.datacolumn=PROCESSED_DATA \
	msout.datacolumn=PROCESSED_DATA #| tee /opt/Data/mkuiack1/$SB-$OBS/logs/$MSFILE-sub.log

echo "### time subtract"

rm -rf /opt/Data/mkuiack1/$SB-$OBS/$SOURCEDB

# Image final data product: SUBTRACTED_DATA
array=(`seq 0 189`); array2=(`seq 1 190`); array3=(`seq -f "%05g" 0 189`) 
#array=(`seq 0 94`); array2=(`seq 1 95`); array3=(`seq -f "%05g" 0 94`)

for ((i=0;i<${#array[@]};++i)); \
	do echo /opt/Data/imgs/"${array3[i]}"_$SB-$OBS; \
		time wsclean -size 2300 2300 -scale 0.05 -j  23  \
	       	-interval "${array[i]}" "${array2[i]}" -no-update-model-required -pol I -weight briggs 0.0 \
		-name /opt/Data/mkuiack1/$SB-$OBS/imgs/"${array3[i]}"_$SB-$OBS -niter 0 -no-dirty -auto-mask 3  -auto-threshold 0.3 \
		-local-rms -mgain 0.8  -fit-beam -clean-border 21   \
		-data-column PROCESSED_DATA $MSFILE; 
done

python $HOME/A12_pipeline/pyscripts/FitsFixer.py "/opt/Data/mkuiack1/"$SB"-"$OBS"/imgs/*fits"

# exit singularity to rsync data from node
