
'''
Mark Kuiack, Aug 2020.
Read the outputs of aoquality, as csv, detect statistical outliers, and write DPPP antenna flaggin parset. 
'''


import pandas as pd
import numpy as np
import sys

SB = sys.argv[1]
OBS = sys.argv[2]

def mad(data, axis=None):
    return np.mean(np.absolute(data - np.mean(data, axis)), axis)


badstations = np.array([], dtype="int")

for stat_name in ["/opt/Data/mkuiack1/{0}-{1}/parsets/{0}-{1}-AOQ_STD.tsv".format(SB,OBS),  
                  "/opt/Data/mkuiack1/{0}-{1}/parsets/{0}-{1}-AOQ_SumP2.tsv".format(SB,OBS)]:

    aqdf = pd.read_csv(stat_name, delimiter="\t")

    sum_A2 = aqdf.groupby("ANTENNA2").sum()
    sum_A1 = aqdf.groupby("ANTENNA1").sum()
    tot_sum = sum_A1+ sum_A2

    # for key in tot_sum.keys()[2:]:
    for key in tot_sum.keys()[4:8]:

#         outliers = np.abs(tot_sum[key] - np.mean(tot_sum[key])) > 1.*np.std(tot_sum[key])
        outliers = np.abs(tot_sum[key] - np.mean(tot_sum[key])) > 2.*mad(tot_sum[key])

        badstations = np.append(badstations, tot_sum[key][outliers].index)
        print stat_name, key, ":", len(tot_sum[key][outliers])

all_badstations = np.unique(badstations)
idx = np.argsort([x.zfill(4) for x in np.array(all_badstations, dtype=str)])

print all_badstations, "len:", len(all_badstations)
print "output string:"
print ','.join(np.array(all_badstations[idx], dtype=str))

out_list = np.append(all_badstations, 
                     np.array(np.linspace(24,48,25,dtype=int), dtype=str))

idx = np.argsort([x.zfill(4) for x in np.unique(out_list)])
flags = ','.join(np.unique(out_list)[idx])

#flags = ','.join(np.array(all_badstations[idx], dtype=str))

outF = open ("/opt/Data/mkuiack1/{0}-{1}/parsets/antflag.parset".format (SB, OBS), "w")
outF.write('''## Flag bad baselines

msin.datacolumn=FLAG_DATA
msout.datacolumn=FLAG_DATA
msout=.

steps=[preflagger,count]

preflagger.type=preflagger

preflagger.mode=set
preflagger.baseline={}'''.format(flags))
outF.close()

