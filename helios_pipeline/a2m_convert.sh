#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 40G
#SBATCH --time 4:00:00

echo ""
echo "running aartfaac2ms: "; date
echo "on " $HOSTNAME
echo ""

SB=$1

START=$2
END=$3

OBS=${START:0:10}"T"${START:11:8}-${END:11:8}

INPUT=$4
#rsync -avP "/zfs/helios/filer0/mkuiack1/202008122000/"$SB"-"$OBS".vis" "/ssdstore/mkuiack1/"

mkdir /ssdstore/idayan

# Load LOFAR cookbook Simage
singularity exec -B /ssdstore/idayan/:/opt/Data/,/zfs/helios/filer0/mkuiack1/:/opt/Archive/  \
        $HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_trim_a2m.sh \
        $SB $START $END $INPUT

mkdir "/zfs/helios/filer0/idayan/202008122000/"$OBS"_all/" #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

rsync -avP "/ssdstore/idayan/"$SB"-"$OBS".ms" "/zfs/helios/filer0/idayan/202008122000/"$OBS"_all/" #!!!!!!!!!!!!!!!!!!!

rm -rf "/ssdstore/idayan/"$SB"-"$OBS".vis"
rm -rf "/ssdstore/idayan/"$SB"-"$OBS".ms"

