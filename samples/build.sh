#!/bin/bash -e

PWD=`pwd`
DART=dart
PUB=pub

# $1 steps to run
function pub_get() {
	for step in $1
	do
		pushd $PWD/$step
		$PUB get
		popd
	done
}

# $1 test script
# $2 steps to run
function run_test() {
	for step in $2
	do
		$DART $PWD/$step/test/$1.dart
	done
}

# $1 steps to build
function pub_build() {
	for step in $1
	do
		pushd $PWD/$step
		$PUB build
		popd
		mv $PWD/$step/build/web $PWD/build/$step
	done
}

rm -r -f $PWD/build
mkdir -p $PWD/build

pub_get "s1_basics s2_classes s3_game s4_element s5_template s6_board s7_enrollment s8_serialization s9_server s10_alltogether"

run_test "s2_classes_test" "s2_classes s3_game s4_element s5_template s6_board s7_enrollment s8_serialization s9_server s10_alltogether"

run_test "s3_game_test" "s3_game s4_element s5_template s6_board s7_enrollment s8_serialization s9_server s10_alltogether"

run_test "s8_event_codec_test" "s8_serialization s9_server s10_alltogether"

run_test "s8_event_codec_test_single" "s8_serialization s9_server s10_alltogether"

pub_build "s4_element s5_template s6_board s7_enrollment s10_alltogether"

