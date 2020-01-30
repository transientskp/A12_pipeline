#!/bin/bash
#SBATCH -n 1
#SBATCH -t 2:00:00
#SBATCH -c 1
echo "Hello I am running a singularity job to transfer data"
echo "I am running on " $HOSTNAME

scp -r -oProxyCommand="ssh -W %h:%p shulevski@portal.lofar.eu" ais007:/data/SB348-201906100905-lba_outer.vis $HOME

echo "DATA TRANSFERRED"
exit 0
