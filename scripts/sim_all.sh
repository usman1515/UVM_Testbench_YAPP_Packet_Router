#!/bin/bash

# script start time
start_time=$(date +%s)

# compile UVM environment
make compile

# array to store test names
declare -a test_list=(
                        "test_1"
                        "test_2"
					)

# simulate all tests
for ((i=0; i < ${#test_list[@]}; i++));
do
	make runtest TEST=${test_list[i]}
done

# script end time
end_time=$(date +%s)
# elapsed time with second resolution
elapsed=$(( end_time - start_time ))

echo " "
echo "----------------------------------------------------------------------------"
echo "-------------------------------- Elapsed Time ------------------------------"
eval "echo Start time:   $(date -ud "@$start_time" +'$((%s/3600/24)) days %H hr %M min %S sec')"
eval "echo End time:     $(date -ud "@$end_time" +'$((%s/3600/24)) days %H hr %M min %S sec')"
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"
echo "----------------------------------------------------------------------------"
echo " "