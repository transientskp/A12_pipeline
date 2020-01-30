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
echo "Running submit_for_processing_a12.sh: "; date
echo ""

A12_PIPE_DIR="$HOME"

# Notes

# max number of jobs
# - note the pilot job framework ensures that each job keeps going until the queue is empty
# loop over SBs for sbatch submission

for sb in *201812150115*cut.vis;
do
 
 echo "Submitting to squeue, SB: " $sb

 # srun command
 JOB_ID="$(sbatch $A12_PIPE_DIR/sbatch_srun_calibrate.sh $sb)"
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

# here, wait for all cal jobs to be finished

#sleep 5

#JOB_ID="$(sbatch $A12_PIPE_DIR/sbatch_srun_imager.sh)"    
#echo ${JOB_ID}
