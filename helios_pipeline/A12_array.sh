#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 25G
#SBATCH --time 240:00:00
#SBATCH --array=1-128%32
<<<<<<< HEAD
#### #####SBATCH -w helios-cn018,helios-cn39
#SBATCH --exclude=helios-cn[013-020]
##### #### ### #SBATCH --w helios-cn005,helios-cn006,helios-cn007,helios-cn018,helios-cn019,helios-cn020,helios-cn021,helios-cn022,helios-cn023,helios-cn024,helios-cn025,helios-cn026,helios-cn027,helios-cn028,helios-cn029,helios-cn030
=======
#SBATCH --exclude=helios-cn[013-020]
##### ### SBATCH -w helios-cn018,helios-cn39

>>>>>>> 70ff4028326493ed4df813088a219ed04433dc71
OBSSLICEFILE=$1

$HOME/A12_pipeline/helios_pipeline/A12_pipelinearray.sh `sed $SLURM_ARRAY_TASK_ID'q;d' $OBSSLICEFILE` 


