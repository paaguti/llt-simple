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
  nodes=0
  maxnodes=${3:-5}

  while [ ${nodes} -le ${maxnodes} ]
  do
    for video in "false" "true"
    do
      [ "$video" == "true" ] && vtag="video"
      [ "$video" == "true" ] || vtag="audio"

	  RUN=$(date '+%s')
	  RUN=$((RUN % 512))
      local tag=`printf "llt-simple-marking-%s-%02d-%02d" ${vtag} ${maxnodes} ${nodes}`
      echo ">> Running ${vtag} trial with ${maxnodes} nodes and ${nodes} markers"
	  cmd="llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --pcaps=${pcaps} --markers=${nodes} --nodes=${maxnodes} --run=${tag} --stag={vtag}"
	  if [ "$video" == "true" ]; then
		  # 720kbps
		  cmd="${cmd} --pps=100 --bytes=900"
	  fi
	  echo ">>   ${cmd}"
	  NS_LOG="LLTSimple" ../../waf --run "${cmd}"
      save_results ${base_from} ${base_to}/`printf "%02d-%02d" ${maxnodes} ${nodes}`/${vtag}

    done
    nodes=$((nodes + 1))
  done
  zipname=`printf "%s-%s.zip" $(basename $(pwd)) ${start}`
  zip -9rD ${zipname} $2

  ./plotCBR ${zipname}
}

main $*

# vim: ai ts=2 sw=2 et sts=2 ft=sh
