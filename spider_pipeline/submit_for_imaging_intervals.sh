#!/bin/bash
# ------------------------------------------
#
# AUTHOR A SHULEVSKI (API)
#
#  * 23/10/2019	:: created version 0.1
#		:: step1 $ ./submit_for_processing_a12.sh
#
# ------------------------------------------
#
echo ""
echo "Running submit_for_imaging_intervals.sh: "; date
echo ""

A12_PIPE_DIR="$HOME"

# Notes

# max number of jobs
# - note the pilot job framework ensures that each job keeps going until the queue is empty
# loop over SBs for sbatch submission

start=0
end=30
# proc_node = total_intervals_to_be_imaged / end
proc_node=30

for ((i=start; i<=end; i++));
do
 
 echo "Submitting: " $i

 # srun command
 JOB_ID="$(sbatch $A12_PIPE_DIR/sbatch_srun_image_intervals.sh $i $proc_node)"
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
