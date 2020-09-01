#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 100G
#SBATCH --time 12:00:00

#
# cli sbatch checks
#
#   $ scontrol show job 28
#   $ squeue


echo ""
echo "running sbatch run all: "; date
echo "on " $HOSTNAME
echo ""

SB=$1
OBS=$2


rsync -avP "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"$SB"-"$OBS".ms" "/ssdstore/mkuiack1/"

# run_script runs all: AARTFAAC2MS, DPPP, and WSClean
singularity exec -B /ssdstore/:/opt/Data  \
	$HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_script_full.sh \
	$SB $OBS

# send output to Archive
rsync -avP "/ssdstore/mkuiack1/"$SB"-"$OBS \
	"/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"$SB-$OBS

rsync -avP "/ssdstore/mkuiack1/"$SB"-"$OBS".ms" \
        "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"

rm -rf "/ssdstore/mkuiack1/"$SB"-"$OBS".ms"

# send output to struis
rsync -avP /ssdstore/mkuiack1/$SB-$OBS \
	mkuiack@struis.science.uva.nl:"/scratch/mkuiack/lookhere/"


# Clean up workspace 
rm -rf /ssdstore/mkuiack1/$SB-$OBS

