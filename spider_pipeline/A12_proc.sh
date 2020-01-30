#!/bin/bash
#SBATCH -n 1
#SBATCH -t 48:00:00
#SBATCH -c 12
echo "Running a singularity job using the software installed in my image"
echo "On " $HOSTNAME

mkdir "$TMPDIR"/A12_cal
cp "$HOME"/SB309-201910042053-lba_outer.vis "$TMPDIR"/A12_cal/
cp "$HOME"/SB310-201910042053-lba_outer.vis "$TMPDIR"/A12_cal/

singularity exec --bind /project/aartfaac/Data/ --pwd $PWD /project/aartfaac/Software/sandbox python $PWD/process.py

mv "$TMPDIR"/A12_cal/*.ms /project/aartfaac/Data
rm -r "$TMPDIR"/A12_cal/

echo "SUCCESS"
exit 0
