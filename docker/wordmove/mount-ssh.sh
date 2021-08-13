#!/usr/bin/env bash
set -e

# Using `-v $HOME/.ssh:/root/.ssh:ro` produce permissions error while in the container
# when working from Linux and maybe from Windows.
# To prevent that we offer the strategy to mount the `.ssh` folder with
# `-v $HOME/.ssh:/tmp/.ssh:ro` thus this entrypoint will automatically handle problem.

if [[ -d /tmp/.ssh ]]; then

  cp -R /tmp/.ssh /root/.ssh
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/*
  chmod 644 /root/.ssh/*.pub
  chmod 644 /root/.ssh/known_hosts

fi

exec "$@"
