#!/bin/bash

#SBATCH -n 1
#SBATCH -t 4:00:00
#SBATCH -c 4

#
# cli sbatch checks
#
#   $ scontrol show job 28
#   $ squeue


echo ""
echo "running sbatch_srun_source_finding.sh: "; date
echo "on " $HOSTNAME
echo ""

#IFS=" " tokens=($date)
#echo $tokens

singularity exec --bind /project/aartfaac/Data/ --pwd $PWD /project/aartfaac/Software/sandbox python $PWD/Light_curve_gen.py --chunk_id $1
