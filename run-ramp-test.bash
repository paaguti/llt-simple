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
  nodes=${3:-10}

  PPS=100
  while [ ${PPS} -lt 900 ]; do
    for SIZE in 50 100; do
      for marking in "false" "true"; do
        BW=$((SIZE * PPS / 125))
        [ "$marking" == "true" ] && markers=${nodes}
        [ "$marking" == "true" ] || markers=0
        stag=`printf "ramp-%s-%02d-%03d-%03dk" ${marking} ${nodes} ${SIZE} ${BW}`

	    echo ">> Running trial with ${nodes} nodes and ${markers} markers"
        echo ">> with ${PPS} pps and packets of ${SIZE} bytes"
		RUN=$(date '+%s')
		RUN=$((RUN % 512))

		local tag=`printf "llt-simple-%s" ${stag}`

		cmd="llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --pcaps=${pcaps}"
        cmd="${cmd} --markers=${markers} --nodes=${nodes} --run=${tag}"
        cmd="${cmd} --stag=${stag}"
        cmd="${cmd} --pps=${PPS} --bytes=${SIZE}"
		echo ">>   ${cmd}"
		NS_LOG="LLTSimple" ../../waf --run "${cmd}"
        save_results ${base_from} ${base_to}/`printf "flow-%s-%03d-%03d" ${marking} ${PPS} ${SIZE}`
      done
    done
    PPS=$((PPS + 100))
  done
  zipname=`printf "%s-ramp-%s.zip" $(basename $(pwd)) ${start}`
  zip -9rD ${zipname} $2

  ./plotCBR ${zipname}
}

main $*

# vim: ai ts=2 sw=2 et sts=2 ft=sh
