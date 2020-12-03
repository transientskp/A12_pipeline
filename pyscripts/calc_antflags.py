import pandas as pd
import numpy as np
import sys
import astropy.stats as astats



SB = sys.argv[1]
OBS = sys.argv[2]

def mad(data, axis=None):
    return np.mean(np.absolute(data - np.mean(data, axis)), axis)


badstations = np.array([], dtype="int")

all_means = []

for stat_name in ["/opt/Data/mkuiack1/{0}-{1}/parsets/{0}-{1}-AOQ_STD.tsv".format(SB,OBS),  
                  "/opt/Data/mkuiack1/{0}-{1}/parsets/{0}-{1}-AOQ_SumP2.tsv".format(SB,OBS)]:


    aqdf = pd.read_csv(stat_name, delimiter="\t")

    sum_A2 = aqdf.groupby("ANTENNA2").sum()
    sum_A1 = aqdf.groupby("ANTENNA1").sum()
    tot_sum = sum_A1+ sum_A2

    # look for bad stations    
    for key in [2,8]:
        for station in np.arange(1,13):
            station_index = np.arange(0,48)+48*(station-1)
            all_means.append(np.nanmedian(tot_sum[tot_sum.keys()[key]].values[station_index])/np.nanmedian(tot_sum[tot_sum.keys()[key]].values) )
        for station in np.arange(1,13):
            station_index = np.arange(0,48)+48*(station-1)
            all_means.append(np.nanmedian(tot_sum[tot_sum.keys()[key+1]].values[station_index])/np.nanmedian(tot_sum[tot_sum.keys()[key+1]].values) )



    # look for bad dipoles
    for key in [4,6,8]:

        if tot_sum.keys()[key] == 'SumP2_POL3_I':
            continue 

        check_sum = np.append(tot_sum[tot_sum.keys()[key]].values, 
                            tot_sum[tot_sum.keys()[key+1]].values)


        all_outliers = np.array([])
        
        for station in np.arange(1,13):

                
                station_index = np.append(np.arange(0,48)+48*(station-1),
                                          576+np.arange(0,48)+48*(station-1))
                
# Orig flag  
#                outliers = np.array(np.abs(check_sum[station_index] \
#                                             - np.median(check_sum[station_index])) \
#                                      > 3*mad(check_sum[station_index]), dtype=bool)

                outliers = astats.sigma_clip(np.log(check_sum[station_index]), sigma=3).mask
#                all_means.append(np.nanmedian(check_sum[station_index][~outliers])/np.nanmedian(check_sum) )                

                badstations = np.append(badstations,
                                        np.array(range(0,576)*2)[station_index][outliers])

# Orig flag
#ant_num, count  = np.unique(badstations, return_counts=True)
#all_badstations = ant_num[count > 2]
#badstations = np.append(badstations, np.array([497,499], dtype=int))
#all_badstations = np.unique(badstations)


ant_num, count  = np.unique(badstations, return_counts=True)
all_badstations = ant_num[count > 2]#np.unique(badstations)

for station in np.arange(1,13)[astats.sigma_clip(np.array(all_means)\
                                            .reshape(len(all_means)/12,12).T.mean(axis=1), 
                                            sigma=2.5).mask]:
        print "remove station:", station
        all_badstations = np.append(all_badstations,
                                np.linspace(0,47,48,dtype=int)+48*(station-1))

## Manually Remove stations
#for station in [7,11]:
#        print "remove station:", station
#        all_badstations = np.append(all_badstations,
#                                np.linspace(0,48,48,dtype=int)+48*(station-1))


        
all_badstations = np.unique(all_badstations)



idx = np.argsort([x.zfill(4) for x in np.array(all_badstations, dtype=str)])
flags = ','.join(np.array(all_badstations[idx], dtype=str))

print all_badstations, "len:", len(all_badstations)
print "output string:", ','.join(np.array(all_badstations[idx], dtype=str))

outF = open ("/opt/Data/mkuiack1/{0}-{1}/parsets/antflag.parset".format (SB, OBS), "w")
outF.write('''## Flag bad baselines

msin.datacolumn=FLAG_DATA
msout.datacolumn=FLAG_DATA
msout=.

steps=[preflagger]

preflagger.type=preflagger

preflagger.mode=set
preflagger.baseline={}'''.format(flags))
outF.close()

