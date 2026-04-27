#!/bin/bash --noprofile

#######################################
## atom smasher's haveibeenpwned-check-passwd.bash
## https://github.com/atom-smasher/haveibeenpwned-check-passwd
## v1.06 - 28 apr 2026
## Distributed under the GNU General Public License
## http://www.gnu.org/copyleft/gpl.html

## check if a password (technically a password's sha1 hash) has
##     been found in the haveibeenpwned.com database
## https://haveibeenpwned.com/api/v3

pw="${*}"

## test if no agument is given, and request a password
[[ "${pw}" ]] || {
    ## if the script is killed, restore output to terminal
    trap "stty echo" EXIT
    ## turn off echo
    stty -echo
    ## read secret
    read -p 'Password: ' pw
    ## turn on echo
    stty echo
    printf '\r'
    echo '         (password read from input)'
} >&2

sha=$(printf '%s' "${pw}" | sha1sum | awk '{print toupper($1)}')
pw=${sha1}
prefix=${sha:0:5}
suffix=${sha:5}

## if the `curl` fails, exit with an error
trap 'echo ERROR ; exit 1' ERR
match=$( curl -fsS "https://api.pwnedpasswords.com/range/${prefix}" )
trap - ERR

## testing
#echo ${sha}
#echo ${prefix}
#echo ${suffix}

## if there's a match, print that info and `exit 0`
line=$(echo "${match}" | grep  "^${suffix}:")
[[ "${line}" ]] && {
    echo "${prefix}${line}" | awk -F: '{print "SHA1:    "$1"\nMatches: "$2}'
    exit 0
}

## if there's no match, print that info and `exit 0`
echo 'No matches found.'
exit 0
