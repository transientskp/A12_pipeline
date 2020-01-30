#!/bin/bash

#SBATCH -n 1
#SBATCH -t 4:00:00
#SBATCH -c 8

#
# cli sbatch checks
#
#   $ scontrol show job 28
#   $ squeue


echo ""
echo "running sbatch_srun_chunker.sh: "; date
echo "on " $HOSTNAME
echo ""
echo "Submitting: " $1

# Chunks written in the HOME directory; chunk boundaries on-the-fly detemination TBD
singularity exec --bind /project/aartfaac/Data/ --pwd $PWD /project/aartfaac/Software/sandbox python $PWD/chunk.py $1


