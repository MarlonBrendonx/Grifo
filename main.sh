#! /bin/env bash

#---------------------HEADER----------------------------------------------------------|

# AUTOR		     : Marlon Brendo Ramos <marlonbrendo2013@gmail.com>
# DATA-DE-CRIAÇÃO    : 2021-11-16
# PROGRAMA	     : Grifo
# LICENÇA	     :
# DESCRIÇÃO	     :
#
#------------------------------------------------------------------------------------|



# ===================================================================================
#				Bibliotecas
# ===================================================================================

source help.sh || { echo "Error loading the help.sh"; exit 1; }
source core.sh || { echo "Error loading the core.sh"; exit 1; }
source config.conf || { echo "Error loading the config.conf"; exit 1; }

# ===================================================================================
#				Variáveis
# ===================================================================================

# Colors
red="\033[0;31m"
blue="\033[1;34m"
yellow="\033[1;33m"
green="\033[0;32m"
end="\033[0m"

params=""
jobs=$( nproc )
number_of_jobs=0
match=0
temp="tmp/"
PIDS=()

# ===================================================================================
#				Testes
# ===================================================================================

(( "$UID" == 0 )) && { echo -e "${yellow}[!]${end} No root required !"; exit 1; }
#(( "$#" == 0 )) && { echo -e "${yellow}[!]${end} Empty parameters !"; exit 1; }
[[ -e "$temp" ]] && rm -f $temp* || mkdir "${temp%/}";
echo 0 > temp
[[ -e xaa  ]] && rm -f x* 2>&-


#===================================================================================
#				Funções
#===================================================================================
testParameters(){

  case "$1" in

  	-md5 | -sha1 | -sha256 | -sha3 )

		(( "$#" < 2 )) && { echo -e "${yellow}[!]${end} Missing parameters !"; help; exit 1; } ||\
		[[ ! -e "$2" ]] && { echo -e "${yellow}[!]${end} $2 does not exist"; exit 1; }
		[[ ! -z "$3" ]] && { echo -e "${yellow}[!]${end} file $3 is not necessary"; help; exit 1; }
	 ;;

	esac

}


#=============================================================================
#				Main
#=============================================================================


main(){


	case "$1" in

  		-bf | --bruteforce ) shift; bruteForce "$@" 		;;
		-md5) shift; hashPassword "-md5" "$@"  			;;
		-sha1) shift; hashPassword "-sha1" "$@" 		;;
		-sha256) shift; hashPassword "-sha256" "$@" 		;;
    		-sha3) shift; hashPassword "-sha3" "$@" 		;;

  	-h | --help ) shift; help;;

	*) help ;;

	esac

}


main "$@"
