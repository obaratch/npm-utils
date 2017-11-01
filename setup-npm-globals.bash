#! /usr/local/bin/bash
# setup-npm-globals.bash
set -ue

# 
# NPM Global Dependency Setup Tool
# (C)Obalab, licence free for whatever
# 

# default list of modules to install GLOBALLY
INSTALL_LIST=""

DRY_RUN=false
CLEANUP=false

function help(){
  echo "NPM Global Dependency Setup Tool"
  echo "Usage: ./setup-npm-globals.bash -cdh -f [list-file]"
  echo "  c: Clean up all globally installed modules except npm itself."
  echo "  d: Dry-Run that skips actual modifications."
  echo "  h: This help."
  echo "  f: Read module-list from the specified file."
  exit 0
}
if [ $# -eq 0 ]; then
  help
fi

function run(){
  if [ $DRY_RUN ]; then
    echo "** emulating: $@"
  else
    RUNNER_LINE=$@
    eval ${RUNNER_LINE}
  fi  
}

function readlist(){
  echo "reading list form file: $1"
  filename=$1
  INSTALL_LIST=''
  exec < $filename
  while read line
  do
    if [[ ! $line =~ ^\#.* ]]; then
      INSTALL_LIST="${INSTALL_LIST} ${line}"
    fi
  done 
  INSTALL_LIST=`echo "${INSTALL_LIST}" | xargs`
  echo "${INSTALL_LIST}"
}

# parse arguments
while getopts cf:dh OPT
do
  case $OPT in
    "c" ) CLEANUP=true;;
    "f" ) readlist $OPTARG;;
    "d" ) DRY_RUN=true;;
    "h" ) help;;
  esac
done

# start
NODE_VER=`node -v`
echo "Setting up global dependencies for NodeJS: $NODE_VER"

# cleanup
if [ $CLEANUP ]; then
    echo "cleaning up..."
    run 'npm list -gp --depth=0 | awk -F/ '\''/node_modules/ && !/\/npm$/ {print $NF}'\'' | xargs npm uninstall -g'
    echo "cleaned up."
fi

# install
run "npm install -g $INSTALL_LIST"

# summary
echo "done."
npm list -g --depth=0
