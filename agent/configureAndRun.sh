#!/bin/bash

if [ "$DEBUG" == 'true' ]; then
  set -x
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
trap cleanup SIGINT

cleanup() {
  echo "Stopping agent..."
  echo $DIR
  echo $runAgentPid
  touch $DIR/exiting
  if [ -d /proc/$runAgentPid ]; then
    kill -2 $runAgentPid
  fi
  sleep 1
  echo "Preparing to exit..."
  if [ -d /proc/$sleepPid ]; then
    disown $sleepPid
    kill -9 $sleepPid
    while kill -0 $sleepPid 2> /dev/null; do
      sleep 1
    done
  fi
  echo "Agent stopped."
}

check() {
  retval=$1
  if [ $retval -ne 0 ]; then
      >&2 echo "Return code was not zero but $retval"
      exit 999
  fi
}

ifRun() {
  file=$DIR/$1
  if [ -f $file ]; then
    . $file
  fi
}

echo Starting supervisord in the background...
/usr/bin/supervisord -n >> /dev/null 2>&1 &
echo Starting configuration for $(hostname)...
ifRun preConfigure.sh
. $DIR/configureAgent.sh
ifRun postConfigure.sh
echo Configuration done. Starting run for $(hostname)...
ifRun preRun.sh
. $DIR/runAgent.sh &
runAgentPid=$!
echo run agent pid is $runAgentPid
sleep infinity &
sleepPid=$!
wait $sleepPid
ifRun postRun.sh
echo 'Done.'
exit 0
