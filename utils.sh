
verifyExistFiles(){
    
    [[ "$(ls -A $1)" ]] && {	
		    echo -e "There are files saved in tmp/best-passwords/. Do you want to remove? [y/n]"
            
            while read op
            do
                case ${op,,} in 

                    y ) if rm "$1"* && rm results.csv; then return 0; fi ;;
                    n ) return 1 ;;

                    *) echo "[x] Invalid option" ;;
                esac

            done
    }

    return 2

}




testParameters(){

    (( "$UID" == 0 )) && { echo -e "${yellow}[!]${end} No root required !"; exit 1; }
    #(( "$#" == 0 )) && { echo -e "${yellow}[!]${end} Empty parameters !"; exit 1; }
    #[[ -e "$temp" ]] && rm -f $temp* || mkdir "${temp%/}";
    #echo 0 > temp
    [[ -e xaa  ]] && rm -f x* 2>&-


    case "$1" in

  	-md5 | -sha1 | -sha256 | -sha3  )

		(( "$#" < 2 )) && { echo -e "${yellow}[!]${end} Missing parameters !"; help; exit 1; } ||\
		[[ ! -e "$2" ]] && { echo -e "${yellow}[!]${end} $2 does not exist"; exit 1; }
		[[ ! -z "$3" ]] && { echo -e "${yellow}[!]${end} file $3 is not necessary"; help; exit 1; }
	 ;;

	esac

}

