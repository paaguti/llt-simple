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
  local tag
  local cmd

  start=$(date "+%Y%m%d-%H%M")
  nodes=0
  maxnodes=${3:-5}

  while [ ${nodes} -le ${maxnodes} ]
  do
    for stag in "video" "Video"
    do
	  RUN=$(date '+%s')
	  RUN=$((RUN % 512))
	  [ "${stag}" == "uvideo" ] && tag="llt-simple-100-100-%02d-%02d" # 80kbps  = 10kBps;  small packets
	  [ "${stag}" == "mvideo" ] && tag="llt-simple-100-200-%02d-%02d" # 160kbps = 20kBps;
	  [ "${stag}" == "svideo" ] && tag="llt-simple-100-400-%02d-%02d" # 320kbps = 40kBps;
	  [ "${stag}" == "video" ]  && tag="llt-simple-100-800-%02d-%02d" # 640kbps = 80kBps;

	  [ "${stag}" == "Uvideo" ] && tag="llt-simple-50-200-%02d-%02d"  # 80kbps  = 10kBps;  medium packets
	  [ "${stag}" == "Mvideo" ] && tag="llt-simple-50-400-%02d-%02d"  # 160kbps = 20kBps;
	  [ "${stag}" == "Svideo" ] && tag="llt-simple-50-800-%02d-%02d"  # 320kbps = 40kBps;
	  [ "${stag}" == "Video" ]  && tag="llt-simple-50-1600-%02d-%02d" # 640kbps = 80kBps;

      tag=`printf ${tag} ${nodes} ${maxnodes}`
      echo ">> Running ${stag} trial with ${nodes} of ${maxnodes} marking"

	  cmd="llt-simple --RngRun=${RUN} --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --pcaps=${pcaps} --markers=${nodes} --nodes=${maxnodes} --run=${tag} --stag=${stag}"

	  [ "${stag}" == "uvideo" ] && cmd="${cmd} --pps=100 --bytes=100" # 80kbps  = 10kBps;  small packets
	  [ "${stag}" == "mvideo" ] && cmd="${cmd} --pps=100 --bytes=200" # 160kbps = 20kBps;
	  [ "${stag}" == "svideo" ] && cmd="${cmd} --pps=100 --bytes=400" # 320kbps = 40kBps;
	  [ "${stag}" == "video" ] &&  cmd="${cmd} --pps=100 --bytes=800" # 640kbps = 80kBps;

	  [ "${stag}" == "Uvideo" ] && cmd="${cmd} --pps=50 --bytes=200"  # 80kbps  = 10kBps;  medium packets
	  [ "${stag}" == "Mvideo" ] && cmd="${cmd} --pps=50 --bytes=400"  # 160kbps = 20kBps;
	  [ "${stag}" == "Svideo" ] && cmd="${cmd} --pps=50 --bytes=800"  # 320kbps = 40kBps;
	  [ "${stag}" == "Video" ] &&  cmd="${cmd} --pps=50 --bytes=1600" # 640kbps = 80kBps;

	  echo ">>   ${cmd}"
	  NS_LOG="LLTSimple" ../../waf --run "${cmd}"
      save_results ${base_from} ${base_to}/`printf "%02d-%02d" ${maxnodes} ${nodes}`/${stag}

    done
    nodes=$((nodes + 1))
  done
  zipname=`printf "%s-%s.zip" $(basename $(pwd)) ${start}`
  echo zip -9rD ${zipname} $2
  zip -9rD ${zipname} $2

  if [ "${doPdf}" == "true" ]; then
    pdfname="mvideo-Mvideo.pdf"
    echo ./doPlot ${zipname} ${pdfname}
    ./doPlot ${zipname} ${pdfname}
  fi
}

main $*

# vim: ai ts=2 sw=2 et sts=2 ft=sh
