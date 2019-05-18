#!/bin/bash
#
#  Copyright (c) 2019  Jeong Han Lee
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
#
#   author  : Jeong Han Lee
#   email   : jeonghan.lee@gmail.com
#   date    : Thursday, May 16 21:27:02 CEST 2019
#   version : 0.0.1


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"
declare -gr SC_LOGDATE="$(date +%y%m%d%H%M)"

declare -gr trans_bin_path="translate-shell/build"
declare -gr output=${SC_TOP}/README.md
declare -gr sv_menu=${SC_TOP}/lt_sv.txt
declare -gr en_menu=${SC_TOP}/lt_en.txt

function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }


function die
{
    error=${1:-1}
    ## exits with 1 if error number not given
    shift
    [ -n "$*" ] &&
	printf "%s%s: %s\n" "$scriptname" ${version:+" ($version)"} "$*" >&2
    exit "$error"
}



function setup_trans
{
    git clone https://github.com/soimort/translate-shell
    make -C translate-shell
}

function do_README_header
{
    local weeknumber=`date +%V`
    echo "Enjoy your lunch at Lund : WEEK $weeknumber" > ${output}
    echo "==" >> ${output}
    echo "*Life is good, today is your day!*" >> ${output}
    printf "\n\n"  >> ${output}
  
}

function do_README_footer
{
    echo "###" >> ${output}
    echo "This file is generated at ${SC_LOGDATE}" >>  ${output}
}

function do_trans
{

    local content=$(curl -L http://mudhead.se/lt.html)
    local tempfile=$(mktemp -q)
    local tempfile2=$(mktemp -q)
    pushd ${trans_bin_path}

    echo ">>> We are not in ${trans_bin_path}"
    echo ${content} > lt.html

    echo ">>> Extracting contents from the original one"
    html2text lt.html 2>&1 | tee lt_sv_raw.txt
    cat lt_sv.txt  |  sed "s/\*\*\*\*\*/ \n /2;s/\*\*\*\\**/#/1"
    echo ">>> Extract Swedish Menu"
    cat lt_sv_raw.txt  |  sed "s/\*\*\*\*\*/ \n /2;s/\*\*\*\\**/#/1" > ${sv_menu}
      
    echo ">>> Translating contents to English ..... "
    ./trans -4 -no-warn -show-original n -show-prompt-message n -no-init -indent 0 -no-theme -show-languages n -e bing -s sv -t en --input ${sv_menu} 2>&1 | tee ${tempfile}
    cat ${tempfile} | sed  -e '/\[I.*/d;/WARNING/d;/ERROR/d;/Valid/d;/^$/d;/^###/d;/^ \*/d;s/\x1b\[[0-9;]*m//g;s/\x1b\[[0-9;]*[a-zA-Z]//g;s/\x1b\[[0-9;]*[mGKH]//g;s/\x1b\[[0-9;]*[mGKF]//g' > ${en_menu}
    

    popd
   
}


setup_trans

do_trans

echo ">>> Writing the README.md"
do_README_header

cat ${en_menu}  >> ${output}
do_README_footer

exit
