
spinner(){

	local PID="$!"
	local i=1
 	sp="/ - \\ |"

	echo -n ' '

  	while [ -d "/proc/${PIDS[@]}" ]
	do

		printf "\b${sp:i++%${#sp}:1}"
		sleep .1

	done

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

sortList(){

	echo -e "$1 -> ${green}checking..${end}"
	echo -e "$2 -> ${green}checking..${end}"

	if sort "$1" > "$PWD/tmp/${1##passwds/}" && sort "$2" > "$PWD/tmp/$2" 
	then
		uniq $PWD/tmp/${1##passwds/} >  $PWD/tmp/${1##passwds/}-uniq
		cp $PWD/tmp/${1##passwds/}-uniq $PWD/tmp/${1##passwds/}
		rm $PWD/tmp/${1##passwds/}-uniq
	fi

	return 1
}

joinDictionaries(){

	[[ ! -d "$1" ]] && { echo "[*] It is not a directory"; exit 1; }

	[[ -z "$( ls -A $1 )" ]] && { echo "[*] Directory is empty"; exit 1;}

	if $( cat $1* > all-passwords)
	then
		
		sort all-passwords > "$PWD/tmp/sort-all-passwords"
		uniq "$PWD/tmp/sort-all-passwords" > all-passwords
		rm "$PWD/tmp/sort-all-passwords" 

		bruteForce "all-passwords" "$2"
	fi
}


bruteForce(){
	
	local sizeWordList_2=$( wc -l < "$2" )

  	clear
	ascii_menu bruteforce

	SECONDS=0

	sortList "$@"
	output=$( comm -12 "$PWD/tmp/${1##passwds/}" "$PWD/tmp/$2" > match )

	size=$( wc -l < match )	
	local sizeWordList_1=$( wc -l < "$PWD/tmp/${1##passwds/}" )

	echo "${1##passwds/}" | tee -a saida.txt
	echo -e	"\n[*] Hit Ratio: $( bc <<< "scale=6;( $size/$sizeWordList_1)*100" )%" | tee -a saida.txt
	echo -e "[*] Match: $size \n\n" | tee -a saida.txt

	time_elapsed

	exit 0

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
	local md5pass=$( md5sum <<< "$3" )
	echo "${md5pass%*-}" >> "$temp${2%.*}-md5"
}

sha1Hash(){
	local sha1pass=$( sha1sum <<< "$3" )
	echo "${sha1pass%*-}" >> "$temp${2%.*}-sha1"
}

sha256Hash(){
	local sha256pass=$( sha256sum <<< "$3" )
	echo "${sha256pass%*-}" >> "$temp${2%.*}-sha256"
}

sha3Hash(){
	local sha3pass=$( openssl dgst -sha3-512 <<< "$3" )
	echo "${sha3pass#(*=}" >> "$temp${2%.*}-sha3"
}


hashPassword(){

 	clear
 	# Test parameters
 	testParameters "$@"

 	#Verifying if tool is installed
 	tools "$1"

 	ascii_menu "encrypt"

 	while IF= read -r line
 	do

		case "$1" in

			-md5 ) md5Hash "$@" "$line"      ;;
			-sha1) sha1Hash "$@" "$line" 	 ;;
			-sha256) sha256Hash "$@" "$line" ;;
			-sha3) sha3Hash "$@" "$line"     ;;

		esac

 	done < "$2"  &

	PIDS+=("$!")
 	spinner

	echo -en "\r${green}[*] ${end}Encrypt finish - file saved in $PWD/$temp\n"

}
