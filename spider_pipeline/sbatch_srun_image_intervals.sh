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
echo "running sbatch_srun_image_intervals.sh: "; date
echo "on " $HOSTNAME
echo ""

#IFS=" " tokens=($date)
#echo $tokens

rnd=$((RANDOM))

echo "Random: " ${rnd}

# Create the temp data directory on each node if it's not there
[ ! -d "$TMPDIR"/A12_img_int_${rnd} ] && mkdir "$TMPDIR"/A12_img_int_${rnd}

# Copy the calibrated visibility data to be imaged
cp -r /project/aartfaac/Data/*.avg "$TMPDIR"/A12_img_int_${rnd}/

singularity exec --bind /project/aartfaac/Data/,"$TMPDIR"/A12_img_int_${rnd}/ --pwd $PWD /project/aartfaac/Software/sandbox python $PWD/image_many.py $1 $2 ${rnd}

# Move images to the project data directory and empty the temp directory
rm -r "$TMPDIR"/A12_img_int_${rnd}/*.avg
mv "$TMPDIR"/A12_img_int_${rnd}/*.fits /project/aartfaac/Data/

# If the temp directory on the work node is empty, remove it (it's removed after the last file move/delete has completed)
[ ! -n "$(ls -A "$TMPDIR"/A12_img_int_${rnd})" ] && rm -r "$TMPDIR"/A12_img_int_${rnd}

