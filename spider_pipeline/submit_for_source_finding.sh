#!/bin/bash
# ------------------------------------------
#
# AUTHOR A SHULEVSKI (API)
#
#  * 14/01/2020	:: created version 0.1
#
# ------------------------------------------
#
echo ""
echo "Running submit_for_source_finding.sh: "; date
echo ""

A12_PIPE_DIR="$HOME"

# Notes

# max number of jobs
# - note the pilot job framework ensures that each job keeps going until the queue is empty
# loop over SBs for sbatch submission

start=2
end=27

for ((i=start; i<=end; i++));
do
 
 echo "Submitting: " $i

 # srun command
 JOB_ID="$(sbatch $A12_PIPE_DIR/sbatch_srun_source_finding.sh $i)"
 ###tokens=($JOB_ID)
 echo ""
 echo "   queue check: squeue -u $USER "
 echo "   job check: "
 echo ${JOB_ID}
 ###scontrol show job ${tokens[3]}
 echo ""
 echo ""

 sleep 1

done
