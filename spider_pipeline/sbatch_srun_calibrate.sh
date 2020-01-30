#!/bin/bash

#SBATCH -n 1
#SBATCH -t 48:00:00
#SBATCH -c 1

#
# cli sbatch checks
#
#   $ scontrol show job 28
#   $ squeue


echo ""
echo "running sbatch_srun_calibrate.sh: "; date
echo "on " $HOSTNAME
echo ""

IFS='.' tokens=($1)

# Create the temp data directory on each node if it's not there (first job on the node creates it)
[ ! -d "$TMPDIR"/A12_cal ] && mkdir "$TMPDIR"/A12_cal

# Copy the visibility data (per SB) to be processed
cp ${tokens[0]}.vis "$TMPDIR"/A12_cal/

singularity exec --bind /project/aartfaac/Data/ --pwd $PWD /project/aartfaac/Software/sandbox python $PWD/process.py ${tokens[0]}.vis

# Move the calibrated SBs to the project data directory and remove the raw visibilities
mv "$TMPDIR"/A12_cal/${tokens[0]}.ms /project/aartfaac/Data/
rm -r "$TMPDIR"/A12_cal/${tokens[0]}.vis

# If the temp directory on the work node is empty, remove it (it's removed after the last file move/delete has completed)
[ ! -n "$(ls -A "$TMPDIR"/A12_cal)" ] && rm -r "$TMPDIR"/A12_cal

