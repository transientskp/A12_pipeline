---
title: A12 calibration based on DP3
author: Aleksandar Shulevski
#bibliography: ref.bib
reference-section-title: References
---

# A12 calibration pipeline description

**Aleksandar Shulevski**
**AARTFAAC @ API (UvA) and ASTRON**

Preferred data processing strategy (so far)

We load the necessary libraries and define a convenient main:

``` {.py file=md_process.py}

import os

<<convert_vis_to_ms>>
<<concat>>
<<calibrate>>
<<average>>
<<clip>>
<<image>>

if __name__=='__main__':

    convert()

```

Record two continuous 1.5 MHz (8SBs) bandwidth data blocks (eg. around 61 MHz and 41 MHz).

The processing (pre-processing, calibration and imaging) environment consists of the default Docker image (<https://support.astron.nl/LOFARImagingCookbook/buildlofar.html)> provided by the Science and Operatopns Support group (SOS) at ASTRON, containing the standard LOFAR software environment. We further install the AARTFAAC specific tools: for .vis to .ms conversion (aartfaac2ms) and the aoflagger containing the dipole flagging binary (badstations) from andre Offringa's SourceForge repository as well as the Git based DP3 calibration environment (<https://github.com/lofar-astron/DP3>).

First, convert the .vis to .ms format:

``` {.py #convert_vis_to_ms}

def convert():
    for data in glob.glob('SB*.vis'):
        os.system('/lofarsoft/include/aartfaac2ms/build/aartfaac2ms -mem 95 -mode 1 -flag 
        ' + data + ' ' + data.split(".")[0] + '.ms' + ' A12-AntennaField.conf')
        <<flag_bad_dipoles>>
```

here, we do the conversion per SB, and flag for RFI (via the `-flag` option in the call).
Next, we flag for bad dipoles:

``` {.py #flag_bad_dipoles}
# Flag bad dipoles
os.system('/lofarsoft/aoflagger-code/build/src/badstations -flag ' + data.split(".")[0] + '.ms')
```

The separate SBs of one data block are concatenated:

```{.py #concat}

os.system('DPPP msin=SB3*.ms msout=high_band.ms steps=[]') #concatenate

```

The setting of the flux scale has to be done without channel averaging. A-team subtraction is best on full frequency resolution images. Consequently, image noise is lowest.

## DP3 calibration

The initial direction independent (DI) calibration is performed using the low resolution gaussian component model for the A-team sources available in the LOFAR GitHub repository and included with the standard LOFAR pre-processing pipeline (prefactor: <https://github.com/lofar-astron/prefactor>).

```{.py #calibrate}

def calibrate():
    for ms in glob.glob('high_band_sel.ms'):
        os.system('/usr/local/bin/DPPP DI_cal.parset msin='+ms+' msin.datacolumn=DATA cal.sourcedb=Ateam_LBA_CC.sourcedb 
        cal.parmdb='+ms+'/instrument.h5 cal.applysolution=true msout.datacolumn=DI_CORRECTED_DATA')

```

The DP3 parset for DI calibraton used is:

```{.sh}

numthreads=1
msout=.

steps=[cal]
cal.type=calibrate
cal.caltype=fulljones
cal.sources=[CasA_4_patch,CygAGG]
cal.solint=1
cal.nchan=3
cal.maxiter=500
cal.tolerance=1e-4
cal.usebeammodel=true
cal.usechannelfreq=false
cal.onebeamperpatch=false
cal.beammode=element
```

We apply the beam during the calibration since the model fluxes we use are real in the sense that they have been taken from a catalog expressed in physical units (Jy).

We calibrate each sub-band, using only CasA and CygA as calibrators (which have sufficient S/N per dipole to give optimal calilbration solutions) and apply the solutions thus setting the flux scale.

The direction dependent (DDE) calibration is performed next, using the corrected data from the previous (DI) step:

```{.py #calibrate}

os.system('DPPP $HOME/DDE_cal.parset msin='+ms+' dcal.sourcedb=$HOME/Ateam_LBA_CC.sourcedb 
dcal.h5parm='+ms+'/dde_instrument.h5 msout.datacolumn=CORRECTED_DATA')

```

We use the corresponding DDE DP3 parset:

```{.sh}
numthreads=1
msout=.

msin.datacolumn=DI_CORRECTED_DATA

steps=[dcal]

dcal.type=ddecal
dcal.directions=[[CasA_4_patch],[CygAGG]]
dcal.subtract=true

dcal.solint=1
dcal.nchan=3
dcal.maxiter=50
dcal.tolerance=1e-4
dcal.mode=fulljones
dcal.propagatesolutions=true
dcal.usebeammodel=true
dcal.onebeamperpatch=false
dcal.uvlambdamin=10
dcal.usechannelfreq=false
```

Again, we apply the beam, and use the DDE solutions to *subtract* CasA and CygA from the visibilities, hopefully preventing the worst of their sidelobes from influencing the final image.

We average the data, and apply the beam in the phase center direction (zenith):

```{.py #average}
os.system('DPPP $HOME/avg.parset msin='+ms+' msout='+ms+'.avg') # decrease channel number before imaging
```

using the parset:

```{.sh}
#msin = low_band.ms
msin.datacolumn = DATA
#msout = high_band_avg.ms

steps = [avg,applybeam]

avg.type = average
avg.freqstep = 4 # 4 for 8SB chunks
avg.timestep = 1
```

Finally, we clip any visibility outliers (greater than 10^4 Jy) per SB:

```{.py #clip}
os.system('DPPP $HOME/Amp_clip.parset msin='+ms)
```

using the DP3 `Amp_clip.parset`:

```{.sh}
numthreads=24
msin=
msout=.

msin.datacolumn=DATA

steps=[preflag]

preflag.type=preflagger
preflag.amplmax=10e4
```

and image the averaged data set using WSclean:

```{.py #image}
os.system('cd $TMPDIR/A12_img/; /usr/local/bin/wsclean -size 3300 3300 -scale 0.05 -j 24 -parallel-gridding 6 
-parallel-reordering 6 -no-update-model-required -pol I -weight briggs 0.0 -name A12_test -niter 1000000 
-fits-mask $HOME/mask_inv.fits -reuse-primary-beam -multiscale -multiscale-scales 0,4,8,16,32,64 -auto-mask 3 
-auto-threshold 0.3 -local-rms -mgain 0.8 -fit-beam -clean-border 21 -apply-primary-beam -join-channels 
-channels-out 6 -data-column DATA '+ms)
```

## Issues

The A-12 flux scale discrepancy can sometimes exceed LOFAR's known 20% flux scale systematic. This value is an HBA estimate, until further studies are available, we assume it to hold for LBA, even though the flux scale systematic stems from beam normalization issues which should be different in LBA.

In this case, one can compare the measured A12 image fluxes with (for example) VLSSr point source catalog fluxes (scaled appropriately to the A12 observing frequency) and correct the visibilities or image(s) with the derived correction factor.

Better flux scaling may be achievable by taking into account the diffuse Galactic emission when setting the flux scale in the DI calibratioin step. However, taking into account the diffuse emission using clean components may result in a very large source model, thus slowing down the calibration process. Also, the relative contribution of the A-team sources and the Galaxy to the flux in the recorded visibilities changes depending on LST and their relative position with respect to the dipole (primary) beam.

It may be feasible to only include the brightest part of the Galaxy (galactic center) when necessary. Tests to this effect were performed, but we did not notice signifficant improvement over the calibration procedure described above. Improved LBA dipole beam models taking into account mutual coupling may lead to improvements in the future, especially if we start using the SPARSE or INNER LBA station configurations.
