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

# $1: source
# $2: destination
function save_results() {
  local d="$2"
  echo "saving test results to ${d}"
  mkdir -p ${d}
  # mv $1/*.{txt,pcap,sca} ${d}
  mv $1/*.{txt,sca} ${d}
}

function main() {
  local base_from=$1 base_to=$2

  start=$(date "+%Y%m%d-%H%M")
  nodes=0
  maxnodes=5
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
	  echo ">>   llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --video=${video} --markers=${nodes} --nodes=${maxnodes} --run=${tag}"
	  NS_LOG="LLTSimple" ../../waf --run "llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --video=${video} --markers=${nodes} --nodes=${maxnodes} --run=${tag}"
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
