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
  [ ${pcaps} == "true" ] && mv -vf $1/*.{txt,pcap,sca} ${d}
  [ ${pcaps} == "true" ] || mv -vf $1/*.{txt,sca} ${d}
}

function main() {
  local base_from=$1 base_to=$2

  start=$(date "+%Y%m%d-%H%M")
  nodes=3
  maxnodes=5
  video="true"

  [ "$video" == "true" ] && vtag="video"
  [ "$video" == "true" ] || vtag="audio"

  RUN=$(date '+%s')
  RUN=$((RUN % 512))
  local tag=`printf "llt-simple-marking-%s-%02d-%02d" ${vtag} ${maxnodes} ${nodes}`
  cmd="llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --pcaps=${pcaps} --markers=${nodes} --nodes=${maxnodes} --run=${tag} --stag=${vtag}"
  if [ "$video" == "true" ]; then
	  cmd="${cmd} --pps=100 --bytes=900"
  fi
  echo ">> Running ${vtag} trial with ${maxnodes} nodes and ${nodes} markers"
  echo ">>   ${cmd}"
  NS_LOG="LLTSimple" ../../waf --run "${cmd}"

  save_results $1 $2
  zipname=`printf "%s-%s.zip" $(basename $2) ${start}`
  zip -9rD ${zipname} $2

  ./plotCBR ${zipname}
}

main $*

# vim: ai ts=2 sw=2 et sts=2 ft=sh
