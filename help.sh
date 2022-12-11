#
#
#
#
# ===================================================================================
#														Help
# ===================================================================================

help(){

cat << EOF

Usage: $basename$0 [ -option ] files ...

   OPTIONS

   -md5                Convert all passwords from a file to MD5
   -sha1               Convert all passwords from a file to SHA-1
   -sha256             Convert all passwords from a file to SHA-2
   -sha3               Convert all passwords from a file to SHA-3

   -c, --compare       Compares two dictionaries and shows the hit rate
   -j, --join         Joins all dictionaries in a directory 
                       and generates a file as output
   -e, --each          Compares each file in a directory gets the file with the most hits

EOF


}

#Messages
declare -A messages=(

	[encrypt]="Encrypting passwords...wait"
    [bruteforce]="Comparing Files"
	[closeprocess]="Waiting for remaining processes.."
    [ordering]="Ordering...wait"
    [ordered]="Ordered"
)

#Traps
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

ctrl_c() {

	echo -e "${yellow}[!]${end} ${messages['closeprocess']}"

	kill -15 "${PIDS[@]}" 2>&-
}

