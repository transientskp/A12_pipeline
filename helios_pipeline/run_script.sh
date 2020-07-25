#!/bin/bash

# Measurement set to operate on
MSFILE=/opt/Data/SB315-202007100001-lba_outer.vis_dysco.ms

# flag antenna in two steps first bad crosscorr, then all autocorr
DPPP $HOME/A12_pipeline/parsets/antflag.parset msin=$MSFILE msout.datacolumn=FLAG_DATA
DPPP $HOME/A12_pipeline/parsets/autoflag.parset msin=$MSFILE msin.datacolumn=FLAG_DATA  msout.datacolumn=FLAG_DATA

# Calculate DI calibration solution
time DPPP /home/mkuiack1/A12_pipeline/parsets/DI_noapply.parset  msin=$MSFILE  \
	msin.datacolumn=FLAG_DATA cal.sourcedb=/home/mkuiack1/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb  \
	cal.parmdb=$MSFILE/instrument.h5 cal.applysolution=false | tee dysco-calcDI.log

# Apply DI Calibration solution 
time DPPP /home/mkuiack1/A12_pipeline/parsets/DI_apply.parset  msin=$MSFILE  msin.datacolumn=FLAG_DATA \
	apply.sourcedb=/home/mkuiack1/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb  \
	apply.parmdb=$MSFILE/instrument.h5 msout.datacolumn=DI_CORRECTED_DATA | tee dysco-applyDI.log

# Calculate and apply DDE solution
time DPPP /home/mkuiack1/A12_pipeline/parsets/DDE_cal.parset  msin=$MSFILE  \
	cal.sourcedb=/home/mkuiack1/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb  \
	cal.h5parm=$MSFILE/dde_instrument.h5 msout.datacolumn=DDE_CORRECTED_DATA | tee dysco-DDcal.log

# Subtract A-team
time DPPP /home/mkuiack1/A12_pipeline/parsets/Subtract.parset  msin=$MSFILE  \
	sub.sourcedb=/home/mkuiack1/A12_pipeline/skymodel/Ateam_LBA_CC.sourcedb  \
	sub.applycal.parmdb=$MSFILE/dde_instrument.h5 msin.datacolumn=DDE_CORRECTED_DATA \
	msout.datacolumn=SUBTRACTED_DATA | tee dysco-sub.log

# Image final data product: SUBTRACTED_DATA
time wsclean -size 3300 3300 -scale 0.05 -j 23 -parallel-gridding 6 -parallel-reordering 6 \
	-no-update-model-required -pol I -weight briggs 0.0 -name A12_test -niter 1000000 \
	-fits-mask /home/mkuiack1/A12_pipeline/masks/o3300_m1100.fits -reuse-primary-beam -multiscale \
	-multiscale-scales 0,4,8,16,32,64 -auto-mask 3  -auto-threshold 0.3 -local-rms -mgain 0.8 -fit-beam \
	-clean-border 21 -apply-primary-beam -join-channels  -channels-out 3 -data-column SUBTRACTED_DATA $MSFILE


