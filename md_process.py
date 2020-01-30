## ------ language="Python" file="md_process.py"

import os

## ------ begin <<convert_vis_to_ms>>[0]

def convert():
    for data in glob.glob('SB*.vis'):
        os.system('/lofarsoft/include/aartfaac2ms/build/aartfaac2ms -mem 95 -mode 1 -flag 
        ' + data + ' ' + data.split(".")[0] + '.ms' + ' A12-AntennaField.conf')
        ## ------ begin <<flag_bad_dipoles>>[0]
        # Flag bad dipoles
        os.system('/lofarsoft/aoflagger-code/build/src/badstations -flag ' + data.split(".")[0] + '.ms')
        ## ------ end
## ------ end
## ------ begin <<concat>>[0]

os.system('DPPP msin=SB3*.ms msout=high_band.ms steps=[]') #concatenate

## ------ end
## ------ begin <<calibrate>>[0]

def calibrate():
    for ms in glob.glob('high_band_sel.ms'):
        os.system('/usr/local/bin/DPPP DI_cal.parset msin='+ms+' msin.datacolumn=DATA cal.sourcedb=Ateam_LBA_CC.sourcedb 
        cal.parmdb='+ms+'/instrument.h5 cal.applysolution=true msout.datacolumn=DI_CORRECTED_DATA')

## ------ end
## ------ begin <<calibrate>>[1]

os.system('DPPP $HOME/DDE_cal.parset msin='+ms+' dcal.sourcedb=$HOME/Ateam_LBA_CC.sourcedb 
dcal.h5parm='+ms+'/dde_instrument.h5 msout.datacolumn=CORRECTED_DATA')

## ------ end
## ------ begin <<average>>[0]
os.system('DPPP $HOME/avg.parset msin='+ms+' msout='+ms+'.avg') # decrease channel number before imaging
## ------ end
## ------ begin <<clip>>[0]
os.system('DPPP $HOME/Amp_clip.parset msin='+ms)
## ------ end
## ------ begin <<image>>[0]
os.system('cd $TMPDIR/A12_img/; /usr/local/bin/wsclean -size 3300 3300 -scale 0.05 -j 24 -parallel-gridding 6 
-parallel-reordering 6 -no-update-model-required -pol I -weight briggs 0.0 -name A12_test -niter 1000000 
-fits-mask $HOME/mask_inv.fits -reuse-primary-beam -multiscale -multiscale-scales 0,4,8,16,32,64 -auto-mask 3 
-auto-threshold 0.3 -local-rms -mgain 0.8 -fit-beam -clean-border 21 -apply-primary-beam -join-channels 
-channels-out 6 -data-column DATA '+ms)
## ------ end

if __name__=='__main__':

    convert()

## ------ end
