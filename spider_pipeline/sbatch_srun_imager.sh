#!/bin/bash

#SBATCH -n 1
#SBATCH -t 48:00:00
#SBATCH -c 24

#
# cli sbatch checks
#
#   $ scontrol show job 28
#   $ squeue


echo ""
echo "running sbatch_srun_imager.sh: "; date
echo "on " $HOSTNAME
echo ""

#IFS='.' tokens=($1)

# Remove any stale imaging directory in the temp directory
[ ! -d "$TMPDIR"/A12_img ] && rm -r "$TMPDIR"/A12_img

# Create the temp data directory on each node if it's not there
[ ! -d "$TMPDIR"/A12_img ] && mkdir "$TMPDIR"/A12_img

# Copy the calibrated visibility data to be imaged
#mv /project/aartfaac/Data/*.avg "$TMPDIR"/A12_img/

singularity exec --bind /project/aartfaac/Data/,"$TMPDIR"/A12_img/ --pwd $PWD /project/aartfaac/Software/sandbox python $PWD/image_single.py

# Move the averaged data and images to the project data directory and empty the temp directory
rm -r "$TMPDIR"/A12_img/*band.ms
mv "$TMPDIR"/A12_img/*.avg /project/aartfaac/Data/
mv "$TMPDIR"/A12_img/*.fits /project/aartfaac/Data/

# If the temp directory on the work node is empty, remove it (it's removed after the last file move/delete has completed)
[ ! -n "$(ls -A "$TMPDIR"/A12_img)" ] && rm -r "$TMPDIR"/A12_img

