#!/usr/bin/env bash
basedir=$(dirname "$(realpath "$0")")
#cd "${basedir}"
scriptext=".sh"
scriptname=$(basename "$(realpath "$0")" "${scriptext}")
if [ -n "$1" ] && [ -f "$1" ];then
    fileName="$1"
    mimeType=$(file -b --mime-type "${fileName}")
    data=$(base64 "${fileName}")
    echo "data:${mimeType};base64,${data//=/%3D}"
else
    utility_name="./${scriptname}${scriptext}"
    echo "usage: ${utility_name} <fileName>"
fi
exit
