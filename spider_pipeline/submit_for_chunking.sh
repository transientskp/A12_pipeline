#!/bin/bash
# ------------------------------------------
#
# AUTHOR A SHULEVSKI (API)
#
#  * 02/11/2019	:: created version 0.1
#		:: step1 $ ./submit_for_chunking.sh
#
# ------------------------------------------
#
echo ""
echo "Running submit_for_chunking.sh: "; date
echo ""

A12_PIPE_DIR="$HOME"

# Notes

# max number of jobs
# - note the pilot job framework ensures that each job keeps going until the queue is empty
# loop over SBs for sbatch submission

for sb in /project/aartfaac/Data/*.vis;
do
 
 echo "Submitting to squeue, SB: " $sb

 # srun command
 JOB_ID="$(sbatch $A12_PIPE_DIR/sbatch_srun_chunker.sh $sb)"
 ##tokens=($JOB_ID)
 echo ""
 echo "   queue check: squeue -u $USER "
 echo "   job check: "
 echo ${JOB_ID}
 ##scontrol show job ${tokens[3]}
 echo ""
 echo ""

 sleep 1

done
