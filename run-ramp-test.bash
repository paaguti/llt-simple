#!/bin/bash

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
  nodes=1
  maxnodes=${3:-20}
  while [ ${nodes} -le ${maxnodes} ]
  do
    for video in "false" "true"
    do
      [ "$video" == "true" ] && vtag="video"
      [ "$video" == "true" ] || vtag="audio"

      for marking in "false" "true"
      do
        [ "$marking" == "true" ] && mtag="mark"
        [ "$marking" == "true" ] || mtag="nomark"

        [ "$marking" == "true" ] && markers=${nodes}
        [ "$marking" == "true" ] || markers=0

		RUN=$(date '+%s')
		RUN=$((RUN % 512))
		local tag=`printf "llt-simple-marking-%s-%02d-%02d" ${vtag} ${maxnodes} ${nodes}`
		cmd="llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --pcaps=${pcaps} --markers=${nodes} --nodes=${maxnodes} --run=${tag}"
		if [ "$video" == "true" ]; then
			cmd="${cmd} --pps=100 --bytes=900"
		fi
		echo ">> Running ${vtag} trial with ${maxnodes} nodes and ${nodes} markers"
		echo ">>   ${cmd}"
		NS_LOG="LLTSimple" ../../waf --run "${cmd}"
        save_results ${base_from} ${base_to}/`printf "nodes-%02d" ${nodes}`/${vtag}/${mtag}
      done
    done
    nodes=$((nodes + 1))
  done
  zipname=`printf "%s-%s.zip" $(basename $(pwd)) ${start}`
  zip -9rD ${zipname} $2

  ./mkCBRtable ${zipname}
}

main $*

# vim: ai ts=2 sw=2 et sts=2 ft=sh
