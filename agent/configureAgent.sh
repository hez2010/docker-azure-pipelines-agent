#!/bin/bash

if [ "$DEBUG" == 'true' ]; then
  set -x
fi
set -eo pipefail
if [ -z $AGENT_POOL ]; then AGENT_POOL=Default; fi
if [ -z $AGENT_URL ]; then
  >&2 echo 'Variable "$AGENT_URL" is not set.'
  exit 1
fi
if [ -z $AGENT_PAT ]; then
  >&2 echo 'Variable "$AGENT_PAT" is not set.'
  exit 2
fi
if [ ! -f $DIR/.credentials ]; then
  agent_url=$AGENT_URL
  agent_pool=$AGENT_POOL
  agent_pat=$AGENT_PAT
  export DOTNET_VERSION=$(dotnet --version)
  work_dir="$DIR/_works/$(hostname)"
  if ! [ -d $work_dir ]; then
    sudo mkdir -p $work_dir
  fi
  sudo chown -R agentuser:agentuser $work_dir
  $DIR/bin/Agent.Listener configure --url $agent_url --pool $agent_pool --auth PAT --token $agent_pat --agent $(hostname) --work $work_dir --unattended
  check $?
fi
unset AGENT_PAT
unset AGENT_POOL
unset AGENT_URL
