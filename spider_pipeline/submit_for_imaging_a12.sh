#!/bin/bash
# ------------------------------------------
#
# AUTHOR A SHULEVSKI (API)
#
#  * 16/11/2019	:: created version 0.1
#		:: step1 $ ./submit_for_imaging_a12.sh
#
# ------------------------------------------
#
echo ""
echo "Running submit_for_imaging_a12.sh: "; date
echo ""

A12_PIPE_DIR="$HOME"

JOB_ID="$(sbatch $A12_PIPE_DIR/sbatch_srun_imager.sh)"    
echo ${JOB_ID}
