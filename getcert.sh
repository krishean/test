#!/usr/bin/env bash
basedir=$(dirname "$(realpath "$0")")
scriptext=".sh"
scriptname=$(basename "$(realpath "$0")" "${scriptext}")
cd "${basedir}"
if [ $# -ge 2 ];then
    outFile="$1.pem"
    if [ ! -f "${basedir}/${outFile}" ] || ([ -f "${basedir}/${outFile}" ] &&
      [[ "$(read -e -p "File \"${outFile}\" already exists."$'\n'"Continue? (y/N): "; echo $REPLY)" == [Yy]* ]]);then
        echo -n|openssl s_client -connect "$1:$2"|sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'>"${basedir}/${outFile}"
    fi
else
    usageCmd="./${scriptname}${scriptext}"
    echo "usage: ${usageCmd} <hostName> <port>"
    echo "  port:"
    echo "    443 - https"
    echo "    636 - ldaps"
    echo "    8443 - https alternate"
fi
exit
