#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 20G
#SBATCH --time 12:00:00
#SBATCH --array=1-2528%32
## ## #SBATCH --array=1-128%32

OBSSLICEFILE=$1

$HOME/A12_pipeline/helios_pipeline/A12_pipelinearray.sh `sed $SLURM_ARRAY_TASK_ID'q;d' $OBSSLICEFILE` 


