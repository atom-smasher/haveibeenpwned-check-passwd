#!/bin/bash --noprofile

#######################################
## atom smasher's haveibeenpwned-check-passwd.bash
## https://github.com/atom-smasher/haveibeenpwned-check-passwd
## v1.02       26 apr 2026
## Distributed under the GNU General Public License
## http://www.gnu.org/copyleft/gpl.html

## check if a password (technically a password's sha1 hash) has
##     been found in the haveibeenpwned.com database
## https://haveibeenpwned.com/api/v3

pw="${*}"

sha=$(printf '%s' "${pw}" | sha1sum | awk '{print toupper($1)}')
prefix=${sha:0:5}
suffix=${sha:5}

## if the `curl` fails, exit with an error
trap 'echo ERROR ; exit 1' ERR
match=$( curl -fsS "https://api.pwnedpasswords.com/range/$prefix" )
trap - ERR

## testing
#echo ${sha}
#echo ${prefix}
#echo ${suffix}

## if there's a match, print that info and `exit 0`
line=$(echo "${match}" | grep  "^${suffix}:")
[[ -n "${line}" ]] && {
    echo "${prefix}${line}" | awk -F: '{print "SHA1:    "$1"\nMatches: "$2}'
    exit 0
}

## if there's no match, print that info and `exit 0`
echo 'No matches found.'
exit 0
