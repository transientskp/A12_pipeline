#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 50G
#SBATCH --time 6:00:00

function clean_up {
  echo "### Running Clean_up ###"
  # - delete temporary files from the compute-node, before copying
  rm -rf "/hddstore/mkuiack1/"$SB"-"$OBS".vis"
  rm -rf "/hddstore/mkuiack1/"$SB"-"$OBS".ms"
  rm -rf "/hddstore/mkuiack1/"$SB"-"$OBS
  # - exit the script
  exit
}

# call "clean_up" function when this script exits, it is run even if SLURM cancels the job 
trap 'clean_up' EXIT

##### pipeline below #####

echo ""
echo "running aartfaac2ms: "; date
echo "on " $HOSTNAME
echo ""

SB=$1

START=$2
END=$3

OBS=${START:0:10}"T"${START:11:8}"-"${END:11:8}

INPUT=$4
#rsync -avP "/zfs/helios/filer0/mkuiack1/202008122000/"$SB"-"$OBS".vis" "/ssdstore/mkuiack1/"

mkdir /hddstore/mkuiack1

# Load LOFAR cookbook Simage
singularity exec -B /hddstore/mkuiack1/:/opt/Data/,/zfs/helios/filer0/mkuiack1/:/opt/Archive/  \
        $HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_trim_a2m.sh \
        $SB $START $END $INPUT

mkdir "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"

#rm -rf "/hddstore/mkuiack1/"$SB"-"$OBS".vis"
#rsync -avP "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"$SB"-"$OBS".ms" "/ssdstore/mkuiack1/"

# run_script runs all: AARTFAAC2MS, DPPP, and WSClean
singularity exec -B /hddstore/:/opt/Data  \
        $HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_script_full.sh \
        $SB $OBS

# send output to Archive
rsync -av "/hddstore/mkuiack1/"$SB"-"$OBS".ms" \
	"/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"

rsync -av "/hddstore/mkuiack1/"$SB"-"$OBS \
        "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"

#rsync -avP "/ssdstore/mkuiack1/"$SB"-"$OBS".ms" \
#        "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"
#rm -rf "/hddstore/mkuiack1/"$SB"-"$OBS".ms"

# send output to struis
#rsync -av /hddstore/mkuiack1/$SB-$OBS \
#        mkuiack@struis.science.uva.nl:"/scratch/mkuiack/lookhere/"


# Clean up workspace 
#rm -rf /hddstore/mkuiack1/$SB-$OBS
