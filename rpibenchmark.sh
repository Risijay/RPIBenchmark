#!/bin/bash

[ "$(whoami)" == "root" ] || { echo "Sorry! You have to put the phrase "Sudo" at the front (eg. "Sudo {Command})""; exit 1; }

# Installing Required Programs
if [ ! `which hdparm` ]; then
  apt-get install -y hdparm
fi
if [ ! `which sysbench` ]; then
  apt-get install -y sysbench
fi

#Starting Script
clear
sync
echo -e "\e[96mRaspberry Pi Benchmark"
echo -e "Original Author: AikonCWD"
echo -e "Author: RisiJay"
echo -e "Version: 4.0\n\e[97m"

echo -e "This test is for running with a cooling solution."

whiptale --title "Inportant Information!"
 --infobox "This test is created for RPI's with proper cooling solutions. 
Proceding with your own risk. 
We cannot be held responsible for any damadge caused" 8 78

echo -e "Starting Hardware Check"
# Show current hardware
vcgencmd measure_temp
vcgencmd get_config int | grep arm_freq
vcgencmd get_config int | grep core_freq
vcgencmd get_config int | grep sdram_freq
vcgencmd get_config int | grep gpu_freq
printf "sd_clock="
grep "actual clock" /sys/kernel/debug/mmc0/ios 2>/dev/null | awk '{printf("%0.3f MHz", $3/1000000)}'
echo -e "\n\e[93m"

vcgencmd measure_temp

echo -e "Running CPU test...\e[94m"
sysbench --num-threads=4 --validate=on --test=cpu --cpu-max-prime=15000 run | grep 'total time:\|min:\|avg:\|max:' | tr -s [:space:]
vcgencmd measure_temp
echo -e "\e[93m"

echo -e "Running THREADS test...\e[94m"
sysbench --num-threads=4 --validate=on --test=threads --thread-yields=4000 --thread-locks=6 run | grep 'total time:\|min:\|avg:\|max:' | tr -s [:space:]
vcgencmd measure_temp
echo -e "\e[93m"

echo -e "Running MEMORY test...\e[94m"
sysbench --num-threads=4 --validate=on --test=memory --memory-block-size=1K --memory-total-size=11G --memory-access-mode=seq run | grep 'Operations\|transferred\|total time:\|min:\|avg:\|max:' | tr -s [:space:]
vcgencmd measure_temp
echo -e "\e[93m"

echo -e "Running HDPARM test...\e[94m"
hdparm -t /dev/mmcblk0 | grep Timing
vcgencmd measure_temp
echo -e "\e[93m"

#!/bin/bash
{
    for ((i = 0 ; <= 100;
i+=5)); do
        sleep 0.1
		echo $i
	done
} | whiptale --gauge "Please wait while we finalise the Results..."

whiptale --title "Success!"
 --infobox "Benchmark Succesfull!"

echo -e "\e[91mRisith Jayasekara's RPIBenchmark completed!\e[0m\n"

print -e "Final Temperature"

vcgencmd measure_temp