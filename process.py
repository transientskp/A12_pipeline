import os

def proc():
    #'''
    #msin='SB324-07080120_5m3ch.ms'
    msin='../../../Ext/A12_sandbox/SB371-201811071645-lba_outer_5min_1.ms'

    # Flag bad dipoles
    #os.system('/home/installdir/aoflagger/build/src/badstations -flag ' + msin)

    # DI calibration, CasA, CygA
    # Calibrate on the A-team to get enough S/N, so we do not subtract the A-team before DI cal.
    #os.system('DPPP DI_cal.parset msin='+msin+' msin.datacolumn=DATA cal.applysolution=true msout.datacolumn=DI_CORRECTED_DATA')

    os.system('DPPP DI_sub.parset sub.sources=[CasA_4_patch,CygAGG] msin.datacolumn=DI_CORRECTED_DATA msout.datacolumn=CORRECTED_DATA msin='+msin)

    start = time.time()
    #os.system('DPPP DI_cal_tracking.parset msin='+msin+' msin.datacolumn=DATA cal.parmdb='+msin+'/instrument cal.applysolution=true msout.datacolumn=DI_CORRECTED_DATA')
    os.system('DPPP DI_apply_tracking.parset msin='+msin+' applysol.parmdb='+msin+'/instrument_tind')
    print "--- %s seconds ---" % (time.time() - start)  

    # DDE calibration, CasA, CygA
    #os.system('/usr/local/bin/DPPP DDE_cal.parset msin='+msin+' msout.datacolumn=CORRECTED_DATA')

    # DI calibration, Galaxy
    # Calibrate on subtracted vis's (CORRECTED_DATA)
    #os.system('DPPP DI_cal.parset msin='+msin+' msin.datacolumn=CORRECTED_DATA cal.applysolution=false cal.sourcedb=A12_Galaxy_08.sourcedb cal.sources=[]')

    # DI calibration, Galaxy, SC1
    # Calibrate on subtracted vis's (CORRECTED_DATA)
    #os.system('DPPP DI_cal.parset msin='+msin+' msin.datacolumn=DI_SUB_DATA_SC1 cal.applysolution=false cal.sourcedb=A12_Galaxy_SC1.sourcedb cal.sources=[]')

    # DI subtraction, Galaxy
    #os.system('DPPP DI_sub.parset msin='+msin+' msin.datacolumn=CORRECTED_DATA sub.applysolution=false sub.sourcedb=A12_Galaxy_08.sourcedb sub.sources=[] msout.datacolumn=DI_SUB_DATA_SC1')

    # DI subtraction, Galaxy SC1
    #os.system('DPPP DI_sub.parset msin='+msin+' msin.datacolumn=DI_SUB_DATA_SC1 sub.applysolution=false sub.sourcedb=A12_Galaxy_SC1.sourcedb sub.sources=[] msout.datacolumn=DI_SUB_DATA_SC2')

    # DI subtraction using DDE solutions
    # CasA
    #os.system('DPPP DI_sub.parset sub.sources=[CasA] sub.applycal.parmdb='+msin+'/instrument.h5 msin.datacolumn=DI_CORRECTED_DATA msout.datacolumn=CasA_SUB msin='+msin)
    # CygA
    #os.system('DPPP DI_sub.parset sub.sources=[CygA] sub.applycal.parmdb='+msin+'/instrument.h5 msin.datacolumn=CasA_SUB msout.datacolumn=CORRECTED_DATA msin='+msin)


    # Imaging

    #os.system('wsclean -size 2100 2100 -scale 0.08 -no-update-model-required -save-weights -save-uv -weight briggs 0.0 -name A12_test_cleanborder_DI -niter 10000 -multiscale -multiscale-scales 0,10,30,60 -fit-beam -clean-border 21 -data-column DI_CORRECTED_DATA ' + msin)

    #os.system('wsclean -size 2100 2100 -scale 0.08 -no-update-model-required -save-weights -save-uv -weight briggs 0.0 -name A12_test_cleanborder_CasAsub -niter 10000 -multiscale -multiscale-scales 0,10,30,60 -fit-beam -clean-border 21 -data-column CasA_SUB ' + msin)

    #os.system('wsclean -size 2100 2100 -scale 0.08 -no-update-model-required -save-weights -save-uv -weight briggs 0.0 -name A12_test_cleanborder_CORR -niter 10000 -multiscale -multiscale-scales 0,10,30,60 -fit-beam -clean-border 21 -data-column CORRECTED_DATA ' + msin)
    #'''
    #os.system('ds9 A12_test_cleanborder_DI-image.fits A12_test_cleanborder_CORR-image.fits A12_test_cleanborder_CasAsub-image.fits')

    #wsclean -size 2100 2100 -scale 0.08 -update-model-required -apply-primary-beam -use-differential-lofar-beam -fits-mask mask.fits -auto-mask 3 -auto-threshold 0.3 -weight briggs 0.0 -name A12_test_cleanborder_CORR_MASKED -niter 20000 -multiscale -multiscale-scales 0,10,30,60 -fit-beam -clean-border 21 -data-column CORRECTED_DATA SB324-07080120_5m3ch.ms/

    # Proper clean
    #wsclean -size 2100 2100 -scale 0.08 -update-model-required -apply-primary-beam -use-differential-lofar-beam -fits-mask mask_inv.fits -weight briggs 0.0 -name A12_test_cleanborder_SC1 -niter 50000 -multiscale -multiscale-scales 0,10,30,60 -auto-mask 3 -auto-threshold 0.3 -local-rms -mgain 0.8 -fit-beam -clean-border 21 -data-column SC1_CORRECTED_DATA SB324-07080120_5m3ch.ms/

def mask_it():
    from astropy.io import fits
    import numpy as np
    import copy
    import glob
    
    for image in glob.glob('/home/shulevski/Documents/Research/Projects/A12_LBA/03Mar19/8min_images/*8min-MFS*pb.fits'):
    #for image in glob.glob('/media/shulevski/shulevski/Documents/Research/Projects/A12_LBA/transport/*-image.fits'):
    #for image in glob.glob('/home/shulevski/Documents/Research/Projects/A12_LBA/transport/mosaic/08/A12_CORR_MASKED_08-image-pb.fits'):
        print image
        #print f.split('-')

        #'''
        #image='A12_test_cleanborder_DI_SUB_SC2-I-image-pb.fits'

        hdulist=fits.open(image)
        img = hdulist[0].data[0,0,:,:]
        mask = np.zeros([3300,3300])
        #mask = np.zeros([1200,1200])
        #x,y=np.meshgrid(2100,2100)
        #x,y = np.array(range(0,2100)),np.array(range(0,2100))
        #print x
        #for x in range(2100):
        #for y in range(2100):
        #print (np.sqrt((x-1050)**2. + (y-1050)**2.) - 700.)
        #print x,y
        x, y = np.ogrid[:3300, :3300]
        #x, y = np.ogrid[:1200, :1200]
        #mask[((np.sqrt((x-1650)**2. + (y-1650)**2.) - 1120.) > 0)] = 1
        mask[((np.sqrt((x-1650)**2. + (y-1650)**2.) - 700.) > 0)] = 1
        #mask[((np.sqrt((x-600)**2. + (y-600)**2.) - 550.) > 0)] = 1
        #from matplotlib import pyplot as plt
        #plt.imshow(mask)
        #plt.show()
        img[np.array(mask,dtype=bool)] = np.nan
        #hdulist.writeto('A12_masked_'+image.split('-')[1]+'.fits')
        hdulist.writeto('/home/shulevski/Documents/Research/Projects/A12_LBA/03Mar19/8min_images/A12_03Mar19_'+image.split('-')[1] + '_' + image.split('-')[2] +'_masked.fits')
        #hdulist.writeto('/home/shulevski/Documents/Research/Projects/A12_LBA/transport/A12_8SB_V_4ch.fits')

        #new_hdu = fits.PrimaryHDU(mask)
        #new_hdu.header = hdulist[0].header

        #new_hdu.writeto('mask_inv.fits', clobber=True)
        #'''

def extract_sky():
    # Sky model extraction using the LSMTool
    '''
    lsm=lsmtool.load('A12_test_cleanborder_CORR-sources-pb.txt')
    lsm.info()
    lsm.select('I > 200')
    lsm.group(algorithm='cluster')
    lsm.setPatchPositions()
    lsm.plot()
    lsm.write('A12_test_model_patches.reg', format='ds9')
    lsm.write('A12_Galaxy.skymodel')    
    '''
def image_noise():
    from astropy.io import fits
    import matplotlib.pyplot as plt
    import numpy as np
    from astropy.modeling import models, fitting

    #odd_image=fits.open(name='A12_test_cleanborder_DDE_odd-I-image-pb.fits', mode='readonly')[0].data[0][0]
    #even_image=fits.open(name='A12_test_cleanborder_DDE_even-I-image-pb.fits', mode='readonly')[0].data[0][0]

    window_blc=550
    window_size=550

    #slice=np.array(odd_image[window_blc:window_blc+window_size, window_blc:window_blc+window_size] - even_image[window_blc:window_blc+window_size, window_blc:window_blc+window_size])

    #slice=fits.open(name='/home/shulevski/Documents/Research/Projects/A12_source_counts/PD_code/A12_18Feb19_MASKED_UVcut-MFS-ZEA-image-pb.fits', mode='readonly')[0].data[0][0][window_blc:window_blc+window_size, window_blc:window_blc+window_size]

    slice=fits.open(name='/home/shulevski/Documents/Research/Projects/A12_source_counts/PD_code/A12_results_UVcut_41MHz/A12_03Mar19_V-MFS-image.fits', mode='readonly')[0].data[0][0][window_blc:window_blc+window_size, window_blc:window_blc+window_size]

    #slice=fits.open(name='/home/shulevski/Documents/Research/Projects/A12_LBA/03Mar19/4min_images/A12_03Mar19_odd_MFS_I_masked.fits', mode='readonly')[0].data[0][0][window_blc:window_blc+window_size, window_blc:window_blc+window_size] - fits.open(name='/home/shulevski/Documents/Research/Projects/A12_LBA/03Mar19/4min_images/A12_03Mar19_even_MFS_I_masked.fits', mode='readonly')[0].data[0][0][window_blc:window_blc+window_size, window_blc:window_blc+window_size]
 
    plt.imshow(slice, vmin=0.2, vmax=1.0)
    plt.show()

    #plt.plot(np.abs(slice.flatten()))
    
    #bins = np.arange(min(slice.flatten()), max(slice.flatten()), step=0.1)

    val, bins, patches = plt.hist(slice.flatten(), bins='auto', label='Image noise histogram')
    plt.xscale('log')
    # Fit the data using a Gaussian
    
    g_init = models.Gaussian1D(amplitude=1., mean=0, stddev=1.)
    l_init = models.Lorentz1D(amplitude=1., x_0=0, fwhm=1.)
    #v_init = models.Voigt1D(x_0=0, amplitude_L=1., fwhm_G=1., fwhm_L=1.)

    fit_g = fitting.LevMarLSQFitter()
    fit_l = fitting.LevMarLSQFitter()
    #fit_v = fitting.LevMarLSQFitter()
    
    g = fit_g(g_init, bins[0:len(bins)-1], val)
    l = fit_l(l_init, bins[0:len(bins)-1], val)
    #v = fit_v(v_init, bins[0:len(bins)-1], val)
    
    plt.plot(bins, g(bins), label='Gaussian')
    plt.plot(bins, l(bins), label='Lorentzian')
    #plt.plot(bins, v(bins), label='Voigt')

    print "Gaussian: ", g.amplitude, g.mean, g.stddev
    print "Lorentzian: ", l.amplitude, l.x_0, l.fwhm
    plt.legend()
    #print v.amplitude_L, v.x_0, v.fwhm_G, v.fwhm_L

    plt.show()

    noise=np.std(slice)

    print "Image noise: ", noise, " [Jy/PSF]"

def mosaic_it():

    os.system('rm *.fits')
    os.system('rm *.tbl')
    os.system('rm projdir/*')
    #execute in the parent folder of the images folder
    os.system('mImgtbl images Kimages.tbl')
    #os.system('mMakeHdr Kimages.tbl AIT_new.hdr') # for some reason, this does not work with A12 all sky images 
    os.system('mProjExec -p images Kimages.tbl AIT_mos.hdr projdir Kstats.tbl')
    os.system('mImgtbl projdir images.tbl')
    os.system('mAdd -p projdir images.tbl AIT_mos.hdr A12_mos.fits')

def plot_flux_timeseries():

    import glob
    from astropy.io import fits
    from astropy.table import Table
    from astropy.table import Column
    import pandas as pd
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    import datetime

    frcat = []
    for cat in sorted(glob.glob('/host/Users/A12/A12_LBA/transport/frames/*srl.fits')):
        with fits.open(cat) as fcat:
                catab=Table.read(fcat, hdu=1)
                catab['Obsdate'] = datetime.datetime.strptime(fcat[1].header['HIERARCH I_DATE-OBS'],"%Y-%m-%dT%H:%M:%S.%f")
                #catab.add_column(Column(fcat[1].header['HIERARCH I_DATE-OBS'], name='Obsdate'))
                frcat.append(catab.to_pandas())
                #print catab['E_Peak_flux']
    frcat = pd.concat(frcat)
    #print frcat
    #plt.switch_backend('Agg')
    axis = frcat.loc[frcat['Source_id'] == 0].plot(x='Obsdate', y='Peak_flux', yerr='E_Peak_flux')
    frcat.loc[frcat['Source_id'] == 1].plot(x='Obsdate', y='Peak_flux', yerr='E_Peak_flux', ax=axis)

    #axis = frcat.loc[frcat['Source_id'] == 0].plot(x='Obsdate', y='Total_flux', yerr='E_Total_flux')
    #frcat.loc[frcat['Source_id'] == 0].plot(x='Obsdate', y='Peak_flux', yerr='E_Peak_flux', ax=axis)

    axis.axhline(130., color='r', linestyle='--', lw=2)
    axis.axhline(100., color='g', linestyle='--', lw=2)
    axis.xaxis.set_major_locator(mdates.MinuteLocator())
    axis.xaxis.set_major_formatter(mdates.DateFormatter('%HH:%MM:%SS'))
    axis.legend(['3C380, VLSS', '3C 81, VLSS', '3C 380', '3C 81'])
    axis.set_ylabel("Flyx density [Jy]")

    fig=axis.get_figure()

    #fig.savefig('Source_plt_5s_cnt.png')
    plt.show()

def aperture_flux_measurement():

        import glob
        from astropy.io import fits
        from astropy.table import Table
        from astropy.coordinates import SkyCoord
        import pandas as pd
        import numpy as np
        import bdsf

        #for image in sorted(glob.glob('/host/Users/A12/A12_LBA/transport/A12_masked_image.fits')):
         #       print image
          #      with fits.open(image) as fimage:
           #             img = bdsf.process_image(image, src_ra_dec=[(350.866417, 58.811778), (299.868153, 40.733916)], frequency=fimage[0].header['CRVAL3'], src_radius_pix=5.)
                        #img.write_catalog(catalog_type='srl', format='fits', clobber=True)

        #with fits.open(glob.glob('/home/shulevski/Documents/Research/Projects/A12_LBA/Flare_dwarves/aleksandar_callingham_highpriority.fits')) as fcat:
        catab=Table.read('/home/shulevski/Documents/Research/Projects/A12_LBA/Flare_dwarves/aleksandar_callingham_highpriority.fits', hdu=1)
        #print catab.colnames
        pancat = catab.to_pandas()
        #print (pancat['ra'], pancat['dec'])
        coords = []
        kept = []
        for idx, row in pancat.iterrows():
                 coords.append((row['ra'], row['dec']))
        #print coords
        image = '/home/shulevski/Documents/Research/Projects/plot_scripts/A12_18Feb19_MASKED-MFS_full-image-pb.fits'
        with fits.open(image) as fimage:
                zra, zdec = fimage[0].header['CRVAL1'], fimage[0].header['CRVAL2']
                print "zra, zdec ", zra, zdec
                if zra < 0.:
                        zra = zra + 360.
                zenith = SkyCoord(zra, zdec, frame='icrs', unit='deg')
                print "Zenith: ", zenith
                for i in coords:
                        print i
                        star = SkyCoord(i[0], i[1], frame='icrs', unit='deg')
                        print "Star: ", star
                        print zenith.separation(star).degree
                        if zenith.separation(star).degree < 60.:
                                print "For addition: ", coords.index(i)
                                kept.append(i)
                                print "Adding: ", star , " with separation ", zenith.separation(star).degree, " degrees"

                #print fimage[0].header['CRVAL1'], fimage[0].header['CRVAL2']
                print "Kept: ", kept
                img = bdsf.process_image(image, src_ra_dec=kept, frequency=fimage[0].header['CRVAL3'], src_radius_pix=5., thresh_isl=3., thresh_pix=5.)
                #img.show_fit()
                img.write_catalog(outfile='JOE.fits', catalog_type='srl', format='fits', clobber=True)  
    

if __name__=='__main__':
    
    #proc()
    image_noise()
    #mask_it()
    #mosaic_it()
    #plot_flux_timeseries()
    #aperture_flux_measurement()
