#!/bin/sh

# NOTE: Replace this with the path to your Phabricator directory.
ROOT="/app/phabricator"

if [ "$1" != "git" ];
then
    exit 1
fi

exec "$ROOT/bin/ssh-auth" $@