#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 50G
#SBATCH --time 6:00:00


function clean_up {
  echo "### Running Clean_up ###"
  # - delete temporary files from the compute-node, before copying
  rm -rf "/hdddstore/mkuiack1/"$SB"-"$SLICE".vis"
  rm -rf "/hddstore/mkuiack1/"$SB"-"$SLICE".ms"
  rm -rf "/hddstore/mkuiack1/"$SB"-"$SLICE
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
OBS=$2

START=$3
END=$4

SLICE=${START:0:10}"T"${START:11:8}"-"${END:11:8}


INPUT=$OBS"/"$SB"-"$OBS"-lba_outer.vis"

mkdir /hddstore/mkuiack1

# Load LOFAR cookbook Simage
singularity exec -B /hddstore/mkuiack1/:/opt/Data/,/zfs/helios/filer0/mkuiack1/:/opt/Archive/  \
        $HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_trim_a2m.sh \
        $SB $START $END $INPUT

mkdir "/zfs/helios/filer0/mkuiack1/"$OBS"/"$SLICE"_all/"

# Copy ms to archive 
rsync -av "/hddstore/mkuiack1/"$SB"-"$SLICE".ms" "/zfs/helios/filer0/mkuiack1/"$OBS"/"$SLICE"_all/"


# run_script runs all: AARTFAAC2MS, DPPP, and WSClean
singularity exec -B /hddstore/:/opt/Data  \
        $HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_script_full.sh \
        $SB $SLICE

rm -rf "/hddstore/mkuiack1/"$SB"-"$SLICE"/Ateam_LBA_CC.sourcedb"

# send output to Archive
rsync -av "/hddstore/mkuiack1/"$SB"-"$OBS".ms" \
        "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"

rsync -av "/hddstore/mkuiack1/"$SB"-"$SLICE \
        "/zfs/helios/filer0/mkuiack1/"$OBS"/"$SLICE"_all/"$SB"-"$SLICE

# send output to struis
rsync -av "/hddstore/mkuiack1/"$SB"-"$SLICE \
        "mkuiack@struis.science.uva.nl:/scratch/mkuiack/lookhere/"


# Clean up workspace 
#rm -rf /hddstore/mkuiack1/$SB-$OBS
