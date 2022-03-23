#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 20G
#SBATCH --time 12:00:00
#SBATCH --array=1-128%32
#SBATCH --exclude=helios-cn[013-020]
##### ### SBATCH -w helios-cn018,helios-cn39

OBSSLICEFILE=$1

$HOME/A12_pipeline/helios_pipeline/A12_pipelinearray.sh `sed $SLURM_ARRAY_TASK_ID'q;d' $OBSSLICEFILE` 


