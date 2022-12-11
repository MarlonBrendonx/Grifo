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
source utils.sh || { echo "Error loading the utils.sh"; exit 1; }
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
status=${messages[ordering]}


# ===================================================================================
#				Testes
# ===================================================================================

testParameters  "$@"

#===================================================================================
#				Funções
#===================================================================================


#==================================================================================
#				Main
#==================================================================================
main(){

	ascii_menu bruteforce

	case "$1" in

  		-c | --compare ) shift; bruteForce "$@" 			;;
		-j | --join) shift; joinDictionaries "$@" 			;;
		-e | --each) shift; compareEachDictionaries "$@"	;;
		-md5) shift; hashPassword "-md5" "$@"  				;;
		-sha1) shift; hashPassword "-sha1" "$@" 			;;
		-sha256) shift; hashPassword "-sha256" "$@" 		;;
    	-sha3) shift; hashPassword "-sha3" "$@" 			;;
  		-h | --help ) shift; help							;;

		*) help 											;;

	esac

}


main "$@"
