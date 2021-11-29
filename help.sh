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

   -bf, --bruteforce   brute force attack generating correct passwords
                       and hit rate as output

EOF


}

#Messages
declare -A messages=(

	[encrypt]="Encrypting passwords...wait"
        [bruteforce]="Brute Force Attack"

)

#Traps
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

ctrl_c() {
	kill -15 "${PIDS[@]}"
}

