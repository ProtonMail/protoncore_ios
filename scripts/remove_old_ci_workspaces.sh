#!/bin/zsh

# Just to be sure that somebody don't run this on their machine by accident and delete something by accident.
if [ `hostname` = "46150.local" ]; then
    find ~/gitlab-runner-home/builds/ -maxdepth 1 -ctime +8h -type d -exec rm -rf {} \; ! -name '*[!0-9]*'   
else
    echo "This script runs only on 46150 CI machine."
    exit 1
fi
