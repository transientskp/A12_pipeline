'''
This script takes an AARTFAAC observation timestamp yyyymmddHHMMSS and outputs a text file
where each line is an input for the A12 imaging batch array pipeline, A12_array.sh

This must be run in the lofar singularity with the Archive location bound as /opt/Archive/
'''


import pandas as pd 
import os
import sys
import subprocess
import glob



obs=sys.argv[1]

visfile = glob.glob('/opt/Archive/{}/SB*-{}-lba_outer.vis'.format(obs,obs))

process = subprocess.Popen(['$HOME/bin/afedit', 
                            '-show-lst', 
                            visfile[0]],
                     stdout=subprocess.PIPE, 
                     stderr=subprocess.PIPE)
stdout, stderr = process.communicate()

if len(stdout) > 1:
    start, end =  pd.to_datetime(stdout[26:73].split(" - "))
else:
    print "No times to parse"
    sys.exit()


SLICES = pd.date_range(start.round("1s")+pd.Timedelta(seconds=1), 
              end.round("1s")+pd.Timedelta(seconds=1), freq="3min")

SUBBANDS = [os.path.basename(x).split("-")[0] 
            for x in glob.glob("/opt/Archive/{}/SB*vis".format(obs))]

OBS_JOBS = pd.DataFrame([])

for _slice in range(len(SLICES)-1):
    for _subband in range(len(SUBBANDS)):
        OBS_JOBS = pd.concat([OBS_JOBS, 
                              pd.DataFrame([SUBBANDS[_subband], obs,
                                                      SLICES[_slice].strftime("%Y-%m-%dT%H:%M:%S"), 
                                                      (SLICES[_slice+1]+pd.Timedelta(seconds=10))
                                                      .strftime("%Y-%m-%dT%H:%M:%S")]).T])

OBS_JOBS.to_csv("$HOME/{}_JOBS.txt".format(obs), index=False, header=False, sep=" ")

sys.exit()
