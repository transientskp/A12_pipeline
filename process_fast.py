import os
import time
import glob
import sys 
            
def convert_vis(sb):
    
    for data in glob.glob(os.environ.get('TMPDIR')+'/A12_cal/'+sb):
        os.system('/usr/local/bin/aartfaac2ms -mem 95 -mode 1 -flag ' + data + ' ' + data.split(".")[0] + '.ms' + ' $HOME/A12-AntennaField.conf')
    
    for ms in glob.glob(os.environ.get('TMPDIR')+'/A12_cal/'+sb):
        # Flag bad dipoles
        os.system('$HOME/aoflagger-code/build/src/badstations -flag ' + ms.split(".")[0] + '.ms')    

def proc(sb):
    
    #'''
    # DI calibration, CasA, CygA
    # Calibrate on the A-team to get enough S/N, so we do not subtract the A-team before DI cal.
    for ms in glob.glob(os.environ.get('TMPDIR')+'/A12_cal/'+sb):
        os.system('DPPP $HOME/sol_lab/DI_cal.parset msin='+ms.split(".")[0]+'.ms cal.sourcedb=$HOME/Ateam_LBA_CC.sourcedb cal.parmdb='+ms.split(".")[0]+'.ms/instrument')
        
        # Transform the solutions to time independent
        os.system('parmexportcal in='+ms.split(".")[0]+'.ms/instrument out='+ms.split(".")[0]+'.ms/instrument_tind')   
	
        # apply the solutions, thus set the flux scale
        os.system('DPPP $HOME/sol_lab/DI_applysol.parset msin='+ms.split(".")[0]+'.ms applycal.parmdb='+ms.split(".")[0]+'.ms/instrument_tind')

        # DDE calibration, CasA, CygA
        
        os.system('DPPP $HOME/sol_lab/DDE_cal.parset msin='+ms.split(".")[0]+'.ms dcal.sourcedb=$HOME/Ateam_LBA_CC.sourcedb dcal.h5parm='+ms.split(".")[0]+'.ms/dde_instrument.h5')

        # Convert DDE solutions from .h5 to parmdb format
        os.system('H5parm2parmdb.py '+ms.split(".")[0]+'.ms/dde_instrument.h5 '+ms.split(".")[0]+'.ms -i instrument -r dde')
        
        # Make the converted DDE solutions time independent
        os.system('parmexportcal in='+ms.split(".")[0]+'.ms/dde_instrument out='+ms.split(".")[0]+'.ms/dde_instrument_tind')

        # Subtract A-team
        os.system('DPPP $HOME/sol_lab/DDE_sub.parset msin='+ms.split(".")[0]+'.ms sub.sourcedb=$HOME/Ateam_LBA_CC.sourcedb sub.applycal.parmdb='+ms.split(".")[0]+'.ms/dde_instrument_tind')
        
        #os.system('DPPP $HOME/sol_lab/DDE_sub_h5.parset msin='+ms.split(".")[0]+'.ms sub.sourcedb=$HOME/Ateam_LBA_CC.sourcedb sub.applycal.parmdb='+ms.split(".")[0]+'.ms/dde_instrument.h5')
        
        # apply the DI solutions, on the subtracted data thus set the flux scale
        #os.system('DPPP $HOME/sol_lab/DI_applysol.parset msin='+ms.split(".")[0]+'.ms applycal.sourcedb=$HOME/Ateam_LBA_CC.sourcedb applycal.parmdb='+ms.split(".")[0]+'.ms/instrument_tind')

if __name__=='__main__':
    
    import sys
    sb = sys.argv[1]
    
    #copy_vis()
    convert_vis(sb)
    proc(sb)
