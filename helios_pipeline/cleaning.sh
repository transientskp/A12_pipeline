#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 50G
#SBATCH --time 6:00:00

function clean_up {
  echo "### Running Clean_up ###"
  # - delete temporary files from the compute-node, before copying
  rm -rf "/hddstore/mkuiack1/"$SB"-"$OBS".ms"
  rm -rf "/hddstore/mkuiack1/"$SB"-"$OBS"-cleaned"
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

mkdir "/hddstore/mkuiack1/" 
rsync -av "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"$SB"-"$OBS".ms" "/hddstore/mkuiack1/"

mkdir "/hddstore/mkuiack1/"$SB"-"$OBS"-cleaned"

# run_script runs all: AARTFAAC2MS, DPPP, and WSClean
singularity exec -B /hddstore/:/opt/Data  \
	$HOME/lofar-pipeline.simg  $HOME/A12_pipeline/helios_pipeline/run_clean.sh \
	$SB $OBS $START $END & wait


ls "/hddstore/mkuiack1/"$SB"-"$OBS".ms"
echo "### SINGULARITY DONE ###"

# send output to Archive
rsync -avP "/hddstore/mkuiack1/"$SB"-"$OBS"-cleaned/"*"-image.fits" \
	"/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"$SB"-"$OBS"/cleaned/"

rsync -avP "/hddstore/mkuiack1/"$SB"-"$OBS"-cleaned/"*"-dirty.fits" \
        "/zfs/helios/filer0/mkuiack1/202008122000/"$OBS"_all/"$SB"-"$OBS"/cleaned/"

# send output to struis
rsync -avP "/hddstore/mkuiack1/"$SB"-"$OBS"-cleaned/"*"-image.fits" \
	mkuiack@struis.science.uva.nl:"/scratch/mkuiack/lookhere/"$SB"-"$OBS"-cleaned/"

echo "FILE TRANSFER DONE"
# Clean up workspace 
#rm -rf "/ssdstore/mkuiack1/"$SB"-"$OBS"-cleaned"
#rm -rf "/ssdstore/mkuiack1/"$SB"-"$OBS".ms"

echo "RM done"

