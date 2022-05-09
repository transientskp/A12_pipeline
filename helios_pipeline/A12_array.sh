#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 25G
#SBATCH --time 240:00:00
#SBATCH --array=1-2528%32
### ## #SBATCH --array=1-128%32
#### ## SBATCH --exclude=helios-cn[013-020]
##### #### ### #SBATCH --w helios-cn005,helios-cn006,helios-cn007,helios-cn018,helios-cn019
#### ####SBATCH --exclude=helios-cn[013-020]
##### ### SBATCH -w helios-cn018,helios-cn39


OBSSLICEFILE=$1

$HOME/A12_pipeline/helios_pipeline/A12_pipelinearray.sh `sed $SLURM_ARRAY_TASK_ID'q;d' $OBSSLICEFILE` 


