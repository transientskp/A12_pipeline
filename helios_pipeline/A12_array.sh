#!/bin/bash

#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 25G
#SBATCH --time 240:00:00
#SBATCH --array=1-150%32
### ## #SBATCH --array=1-128%32
#### ## SBATCH --exclude=helios-cn[013-020]
##### #### ### #SBATCH --w helios-cn005,helios-cn006,helios-cn007,helios-cn018,helios-cn019
#### ####SBATCH --exclude=helios-cn[013-020]
##### ### SBATCH -w helios-cn018,helios-cn39


#OBSSLICEFILE=$1

#$HOME/A12_pipeline/helios_pipeline/A12_pipelinearray.sh `sed $SLURM_ARRAY_TASK_ID'q;d' $OBSSLICEFILE` 

######################################################
### update for line number
### number of line excess 128
### !!!!!!! 09 May 2022
######################################################

OBSSLICEFILE=$1

numline=$(wc -l ~/_202012032122_JOBS.txt | awk '{print $1}') 
#numline=$(wc -l $OBSSLICEFILE)
echo "1) numline is"
echo $numline
echo "2) division is"
echo $numline/150
#echo "3) division is"
#echo (($numline/150))

numlinediv=$(echo  $(($numline/150 + $numline%150 >0)))
#numlinediv= $(($numline/150 + $numline%150 >0))
#numlinediv= $((($numline/150) + ($numline%150 >0)))
echo "numlinediv is:"
echo $numlinediv

#$(((100 / 3) + (100 % 3 > 0)))

START=$SLURM_ARRAY_TASK_ID
NUMLINES=$numlinediv
STOP=$((SLURM_ARRAY_TASK_ID*NUMLINES))
#STOP=$((SLURM_ARRAY_TASK_ID*NUMLINES +16000))
START="$(($STOP - $(($NUMLINES - 1)) ))"
#START="$(($STOP - $(($NUMLINES - 1))))"
#START="$(($STOP - $(($NUMLINES - 1))))"

echo "START=$START"
echo "STOP=$STOP"

for (( N = $START; N <= $STOP; N++ ))
do
    echo "for loop starts"
    echo $N
    #LINE=$(sed -n "$N"p ~/3Dates.txt)
    #ALL3Dates
    ###!!!!!! tobeaveraged101102 NOT YET check first the ones in 70 deg !!!!!!!
    ### /zfs/helios/filer1/idayan/tobeaveraged101102.txt 540540
    #/home/idayan/202012calcdurat.txt
    #LINE=$(sed -n "$N"p /home/idayan/202012calcdurat.txt)
    #LINE=$(sed -n "$N"p /zfs/helios/filer1/idayan/tobeaveraged101102.txt)
    #LINE=$(sed -n "$N"p ~/REMAINIGDATES-GPs10110204up.txt) ###LINE=$(sed -n "$N"p ~/testsearchGPlist.txt)
    #LINE=$(sed -n "$N"p ~/imgsin60.txt)
    #LINE=$(sed -n "$N"p ~/ALL202007Dates2.txt)
    echo "in middle of for loop"
    #echo $LINE
    #echo
    #$HOME/A12_pipeline/helios_pipeline/A12_pipelinearray.sh $LINE
    $HOME/A12_pipeline/helios_pipeline/A12_pipelinearray.sh `sed $N'q;d' $OBSSLICEFILE` 
    #$HOME/A12_pipeline/helios_pipeline/A12_pipelinearray.sh `sed $SLURM_ARRAY_TASK_ID'q;d' $OBSSLICEFILE` 
    #python /home/idayan/dataframe2/IMAGES-IN-TARGET/IN70-loccheck.py $LINE
    
    #python /home/idayan/dataframe2/IMAGES-IN-TARGET/fileshavetarget-parallel.py $LINE
    #python /home/idayan/dataframe2/GP-SEARCH/GPsearch-un202007.py $LINE
    #python /home/idayan/dataframe2/Cal-All-automate.py --fitsfile=$LINE
    
    #python /home/idayan/dataframe2/testconfautomate.py --fitsfile=$LINE
    #echo "processing done"
    #echo $(wc -l ~/ALL202007Dates2.txt)
    
done
