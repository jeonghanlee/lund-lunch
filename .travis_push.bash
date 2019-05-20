#!/bin/bash
# 
# Credit: https://www.vinaygopinath.me/blog/tech/commit-to-master-branch-on-github-using-travis-ci/
#
# Modified the original one to match with the repo
# 

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"
declare -gr SC_LOGDATE="$(date +%y%m%d%H%M)"


function git_configs
{
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

function git_commit
{
  git checkout master
  git add -f ${SC_TOP}/README.md
  git add -f ${SC_TOP}/lt_en.txt
  git add -f ${SC_TOP}/lt_sv.txt
  git commit -m "Update MENU : $SC_LOGDATE (Build $TRAVIS_BUILD_NUMBER)" -m "[skip ci]"
}

function git_push
{
  # Remove existing "origin"
  git remote rm origin
  # Add new "origin" with access token in the git URL for authentication
  git remote add origin https://jeonghanlee:${GH_TOKEN}@github.com/jeonghanlee/lund-lunch.git > /dev/null 2>&1
  git push origin master --quiet
}


git_configs
git_commit

if [ $? -eq 0 ]; then
  echo "Pushing to .."
  git_push
else
  echo "No changes. Nothing to do"
fi

