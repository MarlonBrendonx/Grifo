
spinner(){

	local PID="$!"
	local i=1
 	sp="/ - \\ |"

	echo -n ' '

  	while [ -d "/proc/${PID[@]}" ]
	do

		printf "\b${sp:i++%${#sp}:1}"
		sleep .1

	done

}

verifyDivision(){

	(( "$1" % "$2"  == 0 )) && { number_of_jobs="$2"; return 0;} || return 1

}

findDivisor(){

	local count=2

	while (( "$count" <= "$1"  ))
	do

		(( "$1" % "$count" == 0 )) && { number_of_jobs="$count"; return  0;}
		count=$(( $count + 1 ))

	done

	return 1

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

bruteForce(){


	local match=0
	local it=0
	local total=0
	local time_elapsed=0
  	local sizewordlist1=$( wc -l < "$1" )
 	local sizewordlist2=$( wc -l < "$2" )

  	clear
	ascii_menu bruteforce



	if findDivisor "$sizewordlist2"
	then

		split -l $(( "$sizewordlist2" / "$number_of_jobs" )) "$2" 2>&-

	fi

	if [[ "$?" == 0   ]]
	then

		SECONDS=0

		for file in x*
		do

			echo -e "$file -> ${green}checking..${end}"

			while IFS= read -r line
			do



				[[ $( grep -xw -F "$line" "$file" 2>&- !=''  )  ]] && {

				match=$(( match + 1  ));
				echo $(( "$(<temp)" + 1 )) > temp;
				sleep 0.005;

				(( STOP_FIRST_MATCH  == 0 )) && {

					echo -e "${blue}[*] Password found${end} : $line"; ctrl_c; exit 0; 

				}


				}


			done < "$1" &


			PIDS+=("$!")
			sleep 1

		done


		wait

		total=$(<temp)

		(( "$total" == 0  )) && { echo -e "${red}[x]${end} Password not found !"; exit 1;} || \
		{

			echo -e  "\n[*] Match: $total"
		   	echo   "[*] Hit Ratio: $( bc <<< "scale=4;($total/$sizewordlist2)*100"  )"
			#echo -e "[*] Number of Attempts: $it \n"
			time_elapsed

		}
	fi

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
