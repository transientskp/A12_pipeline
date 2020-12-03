#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 50G
#SBATCH --time 72:00:00

function clean_up {
  echo "### Running Clean_up ###"
  # - delete temporary files from the compute-node, before copying
  rm -rf "/hddstore/mkuiack1/"$SB"-"$SLICE".ms"
  rm -rf "/hddstore/mkuiack1/"$SB"-"$SLICE"-pols"
  # - exit the script
  exit
}


# call "clean_up" function when this script exits, it is run even if SLURM cancels the job 
trap 'clean_up' EXIT


echo ""
echo "running sbatch run all: "; date
echo "on " $HOSTNAME
echo ""

SB=$1
OBS=$2

START=$3
END=$4

SLICE=${START:0:10}"T"${START:11:8}"-"${END:11:8}


mkdir "/hddstore/mkuiack1/" 
rsync -av "/zfs/helios/filer0/mkuiack1/"$OBS"/"$SLICE"_all/"$SB"-"$SLICE".ms" "/hddstore/mkuiack1/"

mkdir "/hddstore/mkuiack1/"$SB"-"$SLICE"-pols"

# run_script runs all: AARTFAAC2MS, DPPP, and WSClean
singularity exec -B /hddstore/:/opt/Data  \
	$HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_pols2.sh \
	$SB $OBS $START $END & wait


echo "### SINGULARITY DONE ###"

# send output to Archive
rsync -av "/hddstore/mkuiack1/"$SB"-"$SLICE"-pols/"*".fits" \
	"/zfs/helios/filer0/mkuiack1/"$OBS"/"$SLICE"_all/"$SB"-"$SLICE"/pols/"

# send output to struis
#rsync -avP "/hddstore/mkuiack1/"$SB"-"$OBS"-pols/"*".fits" \
#	mkuiack@struis.science.uva.nl:"/scratch/mkuiack/lookhere/"$SB"-"$OBS"-pols/"

echo "done"

