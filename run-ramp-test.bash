#!/bin/bash
# -*- mode: Shell-script; indent-tabs-mode: nil; sh-basic-offset: 2; sh-indentation: 2; -*-
set -eu
set -o pipefail

# interesting log tags:
# - LltRealtimeApp
# - PfFfMacScheduler
# - EpcSgwPgwApplication
# - EpcTftClassifier
# - EpcTft

declare -r S1_BW=50Mbps
declare -r pcaps="false"

# $1: source
# $2: destination
function save_results() {
  local d="$2"
  echo "saving test results to ${d}"
  mkdir -p ${d}
  [ ${pcaps} == "true" ] && mv $1/*.{txt,pcap,sca} ${d}
  [ ${pcaps} == "true" ] || mv $1/*.{txt,sca} ${d}
}

function main() {
  local base_from=$1 base_to=$2

  start=$(date "+%Y%m%d-%H%M")
  nodes=${3:-20}
  # UNCOMMENT for constant bit rate of 720kbps
  # for RATE in 100 200 250 500
  RATE=100
  for SIZE in 900 800 450 400
  do
	# UNCOMMENT for constant bit rate of 720kbps
    #     [ ${RATE} -eq 100 ] && stag="Big"
    #     [ ${RATE} -eq 200 ] && stag="Medium"
    #     [ ${RATE} -eq 250 ] && stag="Small"
    #     [ ${RATE} -eq 500 ] && stag="Tiny"
	[ ${SIZE} -eq 900 ] && stag="very"
	[ ${SIZE} -eq 800 ] && stag="high"
	[ ${SIZE} -eq 450 ] && stag="medium"
	[ ${SIZE} -eq 400 ] && stag="low"

    marking="true"

    [ "$marking" == "true" ] && markers=${nodes}
    [ "$marking" == "true" ] || markers=0

	# UNCOMMENT for constant bit rate of 720kbps
    # SIZE=$((90000 / RATE))

	echo ">> Running ${stag} trial with ${nodes} nodes and ${markers} markers"
    echo ">> with ${RATE} pps and packets of ${SIZE} bytes"

		RUN=$(date '+%s')
		RUN=$((RUN % 512))

		local tag=`printf "llt-simple-ramp-%s-%02d-%03d-%3d" ${stag} ${nodes} ${RATE} ${SIZE}`

		cmd="llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --pcaps=${pcaps} --markers=${markers} --nodes=${nodes} --run=${tag}"
    cmd="${cmd} --stag=${stag}"
    cmd="${cmd} --pps=${RATE} --bytes=${SIZE}"
		echo ">>   ${cmd}"

		NS_LOG="LLTSimple" ../../waf --run "${cmd}"

    save_results ${base_from} ${base_to}/`printf "flow-%03d-%03d" ${RATE} ${SIZE}`
  done
  zipname=`printf "%s-%s.zip" $(basename $(pwd)) ${start}`
  zip -9rD ${zipname} $2

  ./plotCBR ${zipname}
}

main $*

# vim: ai ts=2 sw=2 et sts=2 ft=sh
