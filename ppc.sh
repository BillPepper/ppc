#!/bin/bash
running=true
p=0
c=0
e=0
d=0
int=120

declare -a prblHosts=()
declare -a hosts=('8.8.8.8' '9.9.9.9')
declare -a daHosts=()

while [ $running ]
do
	clear
	echo ''
	echo ' Persistent Ping Check'
	echo ' ----------------------------------------------------------------------------------------------------------------------'
	echo -e "  \e[34mPings: $p \t \e[32mSuccess: $c \t \e[31mErrors: $e \t \e[34mInterval: $int Seconds \t Hosts: 3\e[0m\t\t\t\t" $(date +%H:%M)

	echo ' ----------------------------------------------------------------------------------------------------------------------'
	i=1
	for hs in "${hosts[@]}"
	do
		stat=""
		for ph in "${prblHosts[@]}"
		do
			if [ $ph = $hs ] 
			then
				stat="!"
			fi
		done

		deAc="false"
		for dh in "${daHosts[@]}"
		do
			if [ $dh = $hs  ]
			then
				deAc="true"
			fi
		done

		size=${#hs}
		t="\t\t"
		if [ $size -lt 6  ]
		then
			t="\t\t\t"
		elif [ $size -gt 14  ]
		then
			t="\t"
		fi	
		
		if [ $deAc = "false"  ]
		then
			/bin/ping -q -c1 $1 &> /dev/null $hs
		fi

		if [ $? -eq 0 ] && [ $deAc = "false" ]
		then
			if !((i % 2))
			then
				echo -n -e "  $i\e[31m$stat\t\e[32m$hs\e[0m $t"
			else
				echo -n -e "\e[36m  $i\e[31m$stat\t\e[32m$hs\e[0m $t"
			fi
			let c++
		elif [ $deAc = "true"  ]
		then
			echo -n -e "\e[33m  $i$stat\t\e[33m$hs\e[0m $t"
		else
			new=1	
			pbH=0
			for ph in "${prblHosts[@]}"
			do
				if [ $ph = $hs  ]
				then
					new=0
				fi
				let pbH++
			done
			echo -n -e "  $i\t\e[31m$hs\e[0m $t"

			if [ $new -eq 1  ]
			then
				prblHosts+=($hs)
			fi	
			let e++
		fi
		if [ $? -eq 0 ]	&& [ $deAc = "false" ]
		then
			if !((i % 2))
			then
				echo -n -e "\e[0m" $(ping -c 1 $hs | grep --only-matching 'time=.*\|(.*\..*\..*\..*)' | tr -d '\n') "\e[0m"
			else
				echo -n -e "\e[36m" $(ping -c 1 $hs | grep --only-matching 'time=.*\|(.*\..*\..*\..*)' | tr -d '\n') "\e[0m"
			fi
			echo "" 
		else
			if [ $deAc = "true" ]
			then
				echo -e "\e[33m Host is deactivated\e[0m"
			else
				echo -e "\e[31m No Contact\e[0m"
			fi
		fi
		
		let i++
		let p++
	done
	echo ' ----------------------------------------------------------------------------------------------------------------------'	
	echo -n -e " \e[31m$pbH \e[0mProblem Hosts: "
	for ph in "${prblHosts[@]}"
	do
		echo -n -e "\e[31m$ph \e[0m"
	done
	echo -e -n "\tdeactivated Hosts: "
	for daH in "${daHosts[@]}"
	do
		echo -n -e "\e[33m$daH \e[0m"
	done
	echo "" 
	echo ' ----------------------------------------------------------------------------------------------------------------------'
	read -t $int -p "  Type a command or wait $int Seconds (ac/deac/exit/rst/int): " input
	if [ $input = "exit" ]
	then
		exit
	elif [ $input = "deac" ]
	then
		read -p "Hostname to deactivate: " input
		daHosts+=($input)
		echo $input "will be ignored next time"
		sleep 2s
	elif [ $input = "ac" ]
	then
		read -p "Hostname to activate: " input
		declare -a tmpArr=()
		for achs in ${daHosts[@]}
		do
			if [ $input != $achs ]
			then
				tmpArr+=$achs
			fi
		done
		daHosts=$tmpArr
		echo "$input will be activated"
		sleep 2s

	elif [ $input = "int" ]
	then
		read -p "new interval in sec: " input
		int=$input
		echo "new interval is " $int " sec"
		sleep 2s
	elif [ $input = "rst" ]
	then
		e=0
		c=0
	fi
done
