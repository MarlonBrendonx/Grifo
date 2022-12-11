
spinner(){

	local PID="$!"
	local i=1
 	sp="/ - \\ |"

	printf "$1\t"

  	while [[ -d "/proc/${PID}" ]]
	do
		printf "\b${sp:i++%${#sp}:1}"
		sleep .1

	done
	printf "\n"
}


ascii_menu(){


cat << EOF


                                                      @&&&&                                         
                         /(,.(/                  &@@@&#%@&#@&@                                      
                      @&&#@@@&%&@@%%&@          ,&@@@@%@@@@&((                                      
                  &#%@@@@&@%&@#@@@@/%             ,&@@@@@@@%#&%                                     
                   #@&@&@@&@@@%#@@            @&@&%@@&@@@@&#&@@                                     
                        @@@@%@@@&%@     *@#(#@@%&&@&@@@%@#&@&&(                                     
                    /&@@@&&&@@&@@@  *%&&@&%##%(@&%&@@%&%&&&@@                                       
                    &@@@%@@%&(%&% &&@%@@&%##%@@%@@%@%@&@&&@@.                                       
                  @%@&&@@@@@@@&@@(@@@@&&@@&%#@#&@#%@@@@@&@                                          
                  @@#%@@@@@&&@@@   &%%&&%@&#@(%@&#%%@@@@(                                           
                  #(@@&@@@@@@@&%@@&##&/#@&@@&%&&((#%@#                                              
              @#%*%@%@@%&&@@@@@&@@@@#%%%@#&@@&(((##@                                                
               &@&@@@&%%#%%&@@&@@#&&%#((%@%#/((##%@                  @@&/@%%&@\                               
                  &@@&%##%%&&@@&#%&#(#@#%&%###%%%                  @@         @@/                   
                   @@&&&&&&&&@@@@#&@&(#%@&#&%&@#&@&&/           %#               .@                 
                    @@@&&%@&&@@@@%@@@@@@@@@@@@@@@@@%%&%        @/       &@%        @@               
                     &%&##%@@@@@&@@@@@&&@&&%@@@@@@&@@%&@/      &      @@%&          @@              
                     @#&//(#%&@@ @@@@#@%@&%%&#%@@#%%&@%#&@      @     @&&&%          @@             
                      (%&(((%%@#        @%@#%&&%@&%@%#&@%%%     %       &&           @#             
                       &%@((((@@      #@&##%%&&@@&#%(%@#@@&@.    @#      %          &&              
                       %%%((##%@      &&#((&&&@@@@@@@@@%@&@@@@       .             &@/              
                        (@#(##@@       @@&%%@@@@&&&&@%&@@&@@@@%@                 %@&                
                         /&((#@@      ,& &%&&@@@@&@&@&@&( @@@@@%&%@@@&@ @@    @@@@                  
                     &@&@&#/(%@@     &&%(#(##%#%%&@@@@%@    &(@@#&#&@&@@@@@&@@&                     
                    @@&@@@@@@@@@     \#%%%/&@&&&&&&&#%&@          
                    
                                                                                  Griffo 1.0.0



EOF


echo -e "${messages[$1]}: ${green}[ON]${end}\n"
 
}


sizeWordlist(){

	local min=$( bc <<< "scale=4;$1/$jobs" )
	number_of_jobs="${min%%.*}"

	return 0

}

time_elapsed(){

	echo -en "\rtime elapsed: $(( $SECONDS/3600 )) h: $(( ( $SECONDS%3600 )/60   )) m: $(( $SECONDS%3600%60 )) s\n"

}


sortFile(){
	
	if sort "$1" > "$PWD/tmp/${1##passwds/}"  
	then
		(( $DELETE_REPETEAD_LINES )) && { 

			uniq $PWD/tmp/${1##passwds/} >  $PWD/tmp/${1##passwds/}-uniq
			cp $PWD/tmp/${1##passwds/}-uniq $PWD/tmp/${1##passwds/}
			rm $PWD/tmp/${1##passwds/}-uniq
		}

	fi

}

sortList(){

	if [[ ! -f "$PWD/tmp/${1##passwds/}" ]] 
	then
	   sortFile "$1" &
	   spinner "$1 -> ${green}${status}${end}"
	else
		echo -e "$1 -> ${green}${messages[ordered]}${end}"
	fi

	if [[  ! -f "$PWD/tmp/$2" ]]
	then
		sortFile "$2" &
		spinner "$2 -> ${green}${status}${end}"
	else
		echo -e "$2 -> ${green}${messages[ordered]}${end} \n"
	fi



	return 1
}

joinDictionaries(){

	[[ ! -d "$1" ]] && { echo "[*] It is not a directory"; exit 1; }

	[[ -z "$( ls -A $1 )" ]] && { echo "[*] Directory is empty"; exit 1;}


	if $( cat ${1%%/}/* > all-passwords)
	then

		sort all-passwords > "$PWD/tmp/sort-all-passwords"
		uniq "$PWD/tmp/sort-all-passwords" > all-passwords
		rm "$PWD/tmp/sort-all-passwords" 

		echo "[*] all-passwords generated"
		
	fi
}

compareEachDictionaries(){

	[[ ! -d "$1" ]] && { echo "[*] It is not a directory"; exit 1; }
	[[ -z "$( ls -A $1 )" ]] && { echo "[*] Directory is empty"; exit 1;}
	[[ ! -e "tmp/best-passwords/" ]] && mkdir tmp/best-passwords/

	verifyExistFiles "tmp/best-passwords/" && (( $? == 0 )) || (( $? == 2 )) && {

		for dic in $(ls $1*)
		do
			bruteForce "passwds/${dic##passwds/}" "$2" "compareEachDictionaries"
		done

		findBestMatch
		clear

		echo -e "\n"
	}

	for best in "$PWD/tmp/best-passwords"/*
	do
		bruteForce "best-passwords/${best##*/}" "$2" 
	done

}

findBestMatch(){

	[[ ! -d "$PWD/tmp/best-passwords" ]] && mkdir "$PWD/tmp/best-passwords"

	for num in $( seq 500 500 5000 )
	do
		[[ $num == 500 ]] && num="$num"_
		
		bestResult=$( cat results.csv | grep "passwds/passwords_$num" | cut -d ';' -f1,3 | sort -rn -t ';' -k2 | head -1  )
		match=$( cut -d ';' -f2 <<< "$bestResult" ) 
		dictionaries=$( cat results.csv | grep "passwds/passwords_$num*" | egrep "*$match$" | cut -d ';' -f1  )

	
		for dic in $( tr " " "\n" <<< $dictionaries )
		do	
			if cat "$dic" >> "$PWD/tmp/best-passwords/best-passwords-$num"
			then
				echo "[*] File $dic concat to $PWD/tmp/best-passwords/best-passwords-$num"
			fi
		done

		if sort "$PWD/tmp/best-passwords/best-passwords-$num" > "$PWD/tmp/sort-best-passwords"
		then
			uniq "$PWD/tmp/sort-best-passwords" > "$PWD/tmp/best-passwords/best-passwords-$num"
			rm "$PWD/tmp/sort-best-passwords" 
		fi
	done 

}


bruteForce(){
	
	local sizeWordList_2=$( wc -l < "$2" )
	
	SECONDS=0

	sortList "$@"

	output=$( comm -12 "$PWD/tmp/${1##passwds/}" "$PWD/tmp/$2" > match) &
	spinner "\nComparing files "

	size=$( wc -l < match )	
	local sizeWordList_1=$( wc -l < "$PWD/tmp/${1##passwds/}" )
	local hitRatio=$( bc <<< "scale=6;( $size/$sizeWordList_1)*100" )

	echo "${1##passwds/}" >> saida.txt
	echo -e	"\n[*] Hit Ratio: $hitRatio%" | tee -a saida.txt
	echo -e "[*] Match: ${green}$size${end} \n\n" | tee -a saida.txt
	
	[[ ! "$3" ]] || echo "$1;$hitRatio;$size" >> results.csv
	
	time_elapsed
}

tools(){

	case "$1" in

		-md5)  verifyTool "md5sum" 	  ;;
		-sha1) verifyTool "sha1sum"       ;;
		-sha256) verifyTool "sha256sum"   ;;
    	-sha3) verifyTool "openssl"	  ;;

	esac

}


verifyTool(){

	[[ $( which "$1" )  ]] && return 0 || { echo -e "${red}[x]${end} The $1 tool is not installed" ; exit 1;}

}

md5Hash(){
	local md5pass=$( echo -n "$3" | md5sum )
	echo "${md5pass%*-}" >> "$temp${2%.*}-md5"
}

sha1Hash(){
	local sha1pass=$( echo -n "$3" | sha1sum )
	echo "${sha1pass%*-}" >> "$temp${2%.*}-sha1"
}

sha256Hash(){
	local sha256pass=$( echo -n "$3" | sha256sum )
	echo "${sha256pass%*-}" >> "$temp${2%.*}-sha256"
}

sha3Hash(){
	local sha3pass=$(  echo -n "$3" | openssl dgst -sha3-512 )
	echo "${sha3pass#(*=}" >> "$temp${2%.*}-sha3"
}



choiceToolHash(){
	case "$1" in

		-md5 ) md5Hash "$@" "$line"      ;;
		-sha1) sha1Hash "$@" "$line" 	 ;;
		-sha256) sha256Hash "$@" "$line" ;;
		-sha3) sha3Hash "$@" "$line"     ;;

	esac
}


hashPassword(){
	
 	clear

	[[ $(ls $PWD/tmp/*$1 2>- ) ]] && rm $PWD/tmp/*$1

 	# Test parameters
 	testParameters "$@"

 	#Verifying if tool is installed
 	tools "$1"

 	ascii_menu "encrypt"

	echo -en "This may take a while "

	SECONDS=0

	while IF= read -r line
 	do	
		choiceToolHash "$@" "$line"		
 	done < "$2"  & spinner

	echo -en "\r${green}[*] ${end}Encrypt finish - file saved in $PWD/$temp\n"

	time_elapsed	
}
