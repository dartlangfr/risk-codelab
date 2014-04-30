#!/bin/bash -e

REMOTE=$1 
  : ${REMOTE:=origin}
FIRST_STEP=s1_basics
STEPS=(s1_basics s2_classes s3_game s4_element s5_template s6_board s7_enrollment s8_serialization s9_server s10_alltogether)

# $1 branch name
function create_branch() {
	git branch -f $1
}

# $1 destination directory
# $2 steps to copy
function step_branch() {
	cp -a -f "$PWD/$2/." "$PWD/$1"
	git add $PWD/$1
	git commit -m "'Step $2'"
	create_branch $2
}

# $1 remote
# $2 steps to push
function push_branch() {
	git push -f $1 $2
}

function log() { echo -e "\n##########################################\n# $*\n##########################################\n"; }
# $1 steps to output
function foreach() { printf "%s\n" $*; }
# $1 command to run
function execute() { xargs -l1 -i bash -c "log $* {}; $* {}"; }

# Needed for create
export -f log create_branch step_branch push_branch

create_branch $FIRST_STEP

foreach ${STEPS[@]:1} | execute step_branch $FIRST_STEP

foreach ${STEPS[@]} | execute push_branch $REMOTE

