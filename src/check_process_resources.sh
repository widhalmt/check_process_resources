#!/usr/bin/env bash
## Script written by Eli Keimig and Copyright (C) 2010 Eli Keimig. This script is released and distributed under the terms of the GNU General Public License.
## Adapted and enhanced by Thomas Widhalm (C) 2013. This script is still released and distributed under the terms of the GNU General Public License.

## Tested on Fedora 19 with bash-4.2.45-1.fc19.x86_64

## Set Variables
##
## Initialising variables is not necessary in bash but it helps to understand what variables are used
displayhelp="false"
runcheck=""
checkresult=""
process=""
fancyname=""
check=""
warning=""
critical=""

## Options to Accept //\\ Available Switches
optstr=h:p:N:C:w:c: ## The colon trailing the option means that an argument is required if the switch is used.

## Check for Switches
while getopts $optstr Switchvar
do
	case $Switchvar in
		c) critical=$OPTARG ;;
		w) warning=$OPTARG ;;
		C) check=$OPTARG ;;
		N) fancyname=$OPTARG ;;
		p) process=$OPTARG ;;
		h) displayhelp="true" ;;
	esac
done
shift $(( $OPTIND - 1 ))

## Display Help
if [[ "$displayhelp" == "true" ]]
then
	echo "
	::Process Resource Usage Check Help File::
	
		-C,		Specify a check type: CPU or Memory
					The default check type is Memory
		-c,		Specify a critical level for the check 
					The default is 70%
		-h,		Display help information
		-N,		Specify a fancy name for the process
					This is for display in Nagios messages
					Example: check_process.sh -p java -N Tomcat
					 The java process will be monitored and
					 the Nagios message will read:
					   'The Tomcat process is currently OK.'
		-p,		Specify a process to be monitored
		-w,		Specify a warning level for the check
					The default is 60%
		
	Script written by Eli Keimig and Copyright (C) 2010 Eli Keimig.
	Edited by Thomas Widhalm (C) 2013
	This script is released and distributed under the terms of the GNU
	General Public License.     >>>>    http://www.gnu.org/licenses/
	
	This program is free software: you can redistribute it and/or modify
	  it under the terms of the GNU General Public License as published by
	  the Free Software Foundation.

	  This program is distributed in the hope that it will be useful,
	  but WITHOUT ANY WARRANTY; without even the implied warranty of
	  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	  GNU General Public License for more details.
					>>>>	http://www.gnu.org/licenses/
		"
	exit
fi	

## Check for Process to be Monitored
if [[ "$process" == "" ]]
then
	echo "No process to check was specified. Check cannot be run. The '-p' switch can be used to specify the process"
	exit 3
fi

## Set and Read Fancy Name //\\ This is used for results sent to Nagios
if [[ "$fancyname" == "" ]]
then
	fancyname="$process"
fi

## Setting Check Tokens by Check Type //\\ CPU or Memory //\\ Default Check Type = Memory
if [[ "$check" != "" ]]
then
	check=$(echo "$check" | tr [:upper:] [:lower:])
	if [[ "$check" == "cpu" ]]
	then
	checktoken="3"
	elif [[ "$check" == "memory" ]]
	then
	checktoken="4"
	fi
else
	echo "Running default check type: MEMORY USAGE CHECK"
	check="memory"
	checktoken="4"
fi

## Setting Variables with Monitoring Process and Custom Check Tokens //\\ THIS RUNS THE CHECK
##
## the awk construct with sum+= will take every value awk would otherwise put out and sum it up
## this way all resources process which mach the input pattern will get sumed up instead of taking just the first one
if [[ "$checktoken" == "3" ]]
then
	runcheck="$(/bin/ps -C $process u | awk '{ sum+=$3} END {print "%CPU " sum}')"
elif [[ "$checktoken" == "4" ]]
then
	runcheck="$(/bin/ps -C $process u | awk '{ sum+=$4} END {print "%MEM " sum}')"
else
	echo "There is an error with your check's syntax. Please resolve the problem and rerun the check."
	exit 3
fi

## Rounding the check results for comparison to warning and critical thresholds.
checkresult="$(echo ${runcheck} | cut -d ' ' -f2 )"

## Check for Warning and Critical Levels - If Switches were not used, sets variables to default values
if [[ "$warning" == "" ]]
then
	echo "Warning level was not specified with the '-w' switch. Using default value of 60%."
	warning="60"
fi
if [[ "$critical" == "" ]]
then
	echo "Critical level was not specified with the '-c' switch. Using default value of 70%."
	critical="70"
fi

## Create Check Results that can be Read and Interpreted by Nagios
if [[ "$checkresult" == "" ]]
then
        echo "The "$fancyname" process doesn't appear to be running."
        exit 3
fi

roundedresult="$(awk -v var=$checkresult 'BEGIN { rounded = sprintf("%.0f", var); print rounded }')"

if [[ "$roundedresult" -lt "$warning" ]]
then
        echo "The "$fancyname" process "$check" usage is ok. Current "$check" usage: "${checkresult}"%.|${check}=${checkresult}%;${warning};${critical};"
        exit 0
## The following expression only works with [ not with [[
## TODO: Replace it with a working [[ test
elif [ "$roundedresult" -ge "$warning" -a "$roundedresult" -lt "$critical" ]
then
        echo "WARNING - The "$fancyname" process's current "$check" usage is "${checkresult}"%.|${check}=${checkresult}%;${warning};${critical};"
        exit 1
elif [[ "$roundedresult" -ge "$critical" ]]
then
        echo "CRITICAL - The "$fancyname" process's current "$check" usage is "${checkresult}"%.|${check}=${checkresult}%;${warning};${critical};"
        exit 2
fi

exit 0

