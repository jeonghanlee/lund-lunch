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
declare -gr output=${SC_TOP}/README.txt
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


function do_download
{
    local content=$(curl -L http://mudhead.se/lt.html)
     
    local tempfile1=$(mktemp -q)
    local tempfile2=$(mktemp -q)
    
    pushd ${trans_bin_path}
    echo ">>> We are not in ${trans_bin_path}"
    echo ${content} > lt.html

    echo ">>> Extracting contents from the original one"
    html2text lt.html 2>&1 | tee ${tempfile1}
    echo ">>> Extract Swedish Menu"
    cat ${tempfile1} | sed "s/\*\*\*\*\*/ \n /2;s/\*\*\*\\**/#/1" > ${tempfile2}
    cat ${tempfile2} | sed  -e '/\[I.*/d;/^\[Valid/d;/^###/d;/^ \*/d;s/^[[:space:]]*//g;s/\*/@/g' > ${sv_menu}

    popd
    
}

function do_trans
{

 
    local tempfile1=$(mktemp -q)
    local tempfile2=$(mktemp -q)

    local line_list=();
    local weekday=();

    echo ""
    while IFS= read -r line_data; do
	if [ "$line_data" ]; then

	    if [[ $line_data =~ ^\#.* ]]; then
		echo "------ $i : ${line_data}"
	    elif [[ $line_data =~ \@ ]]; then
		if [[ $line_data != ^\*.* ]]; then
		    echo ${line_data} | sed 's/\@/\'$'\n\@/g' > ${tempfile1}
		    line_data=$(cat ${tempfile1})
		    line_list[i]="${line_data}"
		    echo "<<<... $i : ${line_data}"
		else
		    #		    line_list[i]="${line_data}"
		    echo ">>>... $i : ${line_data}"

		fi
	    else
		# 		line_data="${line_list[i-1]}"
		# 		line_data+=" "
		# 		line_date+="${line_data}"
		# #		line_list[i-1]="${line_list[i-1]} ${line_data}"
		echo "...... $i : ${line_data}"
		#		((--i))
	    fi
	    
	    ((++i))
#	    echo "...... $i : ${line_data}"

	    
	    # if [[ $string == *foo* ]]
	    # [[ "$line_data" == ^.*\*.* ]] && continue
	    # #	    raw_pvlist[i]="${line_data}"
	    # line_list[i]="${line_data}"
	    # echo "$i : ${line_data}"
	    # ((++i))
	fi
    done < "${sv_menu}"

    # for aline in ${line_list[@]}; do
    # 	    echo "??? $aline"
    # done
    
    # echo ">>> Translating contents to English ..... "
    # ./trans -4 -no-warn -show-original n -show-prompt-message n -no-init -indent 0 -no-theme -show-languages n -e bing -s sv -t en --input ${sv_menu} 2>&1 | tee ${tempfile}
    # cat ${tempfile} | sed  -e '/\[I.*/d;/WARNING/d;/ERROR/d;/Valid/d;/^$/d;/^###/d;/^ \*/d;s/\x1b\[[0-9;]*m//g;s/\x1b\[[0-9;]*[a-zA-Z]//g;s/\x1b\[[0-9;]*[mGKH]//g;s/\x1b\[[0-9;]*[mGKF]//g;/s/$/\n/g;s/^[[:space:]]*//g' > ${tempfile2}
    

   
}


#setup_trans
do_download

do_trans



# echo ">>> Writing the ${output}"
# do_README_header

# cat ${en_menu}  >> ${output}
# do_README_footer

exit
