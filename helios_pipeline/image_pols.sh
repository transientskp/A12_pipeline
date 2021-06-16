#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 50G
#SBATCH --time 72:00:00

function clean_up {
  echo "### Running Clean_up ###"
  # - delete temporary files from the compute-node, before copying
  rm -rf "/hddstore/idayan/"$SB"-"$OBS".ms"
  rm -rf "/hddstore/idayan/"$SB"-"$OBS"-pols"
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

mkdir "/hddstore/idayan/" 
rsync -av "/zfs/helios/filer0/idaayan/202008122000/"$OBS"_all/"$SB"-"$OBS".ms" "/hddstore/idayan/"

mkdir "/hddstore/idayan/"$SB"-"$OBS"-pols"

# run_script runs all: AARTFAAC2MS, DPPP, and WSClean
singularity exec -B /hddstore/:/opt/Data  \
	$HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_pols.sh \
	$SB $OBS $START $END & wait


echo "### SINGULARITY DONE ###"

# send output to Archive
rsync -avP "/hddstore/idayan/"$SB"-"$OBS"-pols/"*".fits" \
	"/zfs/helios/filer0/idayan/202008122000/"$OBS"_all/"$SB"-"$OBS"/pols/"

# send output to struis
#rsync -avP "/hddstore/mkuiack1/"$SB"-"$OBS"-pols/"*".fits" \
#	mkuiack@struis.science.uva.nl:"/scratch/mkuiack/lookhere/"$SB"-"$OBS"-pols/"

echo "done"

