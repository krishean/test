#!/usr/bin/env bash
basedir=$(dirname "$(realpath "$0")")
cd "${basedir}"
scriptname=$(basename "$0" .sh)
if [ $# -gt 0 ];then
    for repourl in "$@";do
        if [ -n "${repourl}" ];then
            echo "repo url: ${repourl}"
            if [[ "${repourl}" == *.git ]];then repourl="${repourl::-4}";fi
            reponame="${repourl##*/}"
            if [ ! -f "${reponame}.bundle" ];then
                git clone --mirror ${repourl}.git ${reponame}
                git -C ${reponame} bundle create ../${reponame}.bundle --all
                rm -rf ${reponame}
            else
                echo "file exists:"
            fi
            ls -lA "${reponame}.bundle"
        fi
    done
    echo "Done."
else
    echo "Usage: ${scriptname}.sh <repo urls...>"
fi
exit
