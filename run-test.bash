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

# Don't generate PCAPs, print to PDF
declare -r S1_BW=50Mbps
declare -r pcaps="false"
declare -r doPdf="true"

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
    for stag in "audio" "video"
    do
	  RUN=$(date '+%s')
	  RUN=$((RUN % 512))
      local tag=`printf "llt-simple-marking-%s-%02d-%02d" ${stag} ${nodes} ${maxnodes}`
      echo ">> Running ${stag} trial with ${nodes} of ${maxnodes} marking"
	  cmd="llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --pcaps=${pcaps} --markers=${nodes} --nodes=${maxnodes} --run=${tag} --stag=${stag}"

	  [ "${stag}" == "uvideo" ] && cmd="${cmd} --pps=100 --bytes=100" # 80kbps = 10kBps;  small packets
	  [ "${stag}" == "mvideo" ] && cmd="${cmd} --pps=100 --bytes=200" # 160kbps = 20kBps; medium packets
	  [ "${stag}" == "svideo" ] && cmd="${cmd} --pps=100 --bytes=400" # 320kbps = 40kBps; big packets
	  [ "${stag}" == "video" ] &&  cmd="${cmd} --pps=100 --bytes=800" # 640kbps = 80kBps; very big
	  [ "${stag}" == "Uvideo" ] && cmd="${cmd} --pps=50 --bytes=200"  # 80kbps = 10kBps;  medium packets
	  [ "${stag}" == "Mvideo" ] && cmd="${cmd} --pps=50 --bytes=400"  # 160kbps = 20kBps; big packets

	  echo ">>   ${cmd}"
	  NS_LOG="LLTSimple" ../../waf --run "${cmd}"
      save_results ${base_from} ${base_to}/`printf "%02d-%02d" ${maxnodes} ${nodes}`/${stag}

    done
    nodes=$((nodes + 1))
  done
  zipname=`printf "%s-%s.zip" $(basename $(pwd)) ${start}`
  zip -9rD ${zipname} $2

  if [ "%{doPdf}" == "true" ]; then
    pdfname=`printf "simple-%s.pdf" ${start}`
    ./doPlot ${zipname} ${pdfname}
  fi
  # ./plotCBR ${zipname}
}

main $*

# vim: ai ts=2 sw=2 et sts=2 ft=sh
