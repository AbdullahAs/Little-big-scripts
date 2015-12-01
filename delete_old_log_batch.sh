#!/bin/bash

# last 20 days
EDGE_DATE=$(perl -e 'use POSIX; print strftime "%s",localtime time-1728000;')
DATE_FORMATED=$(perl -e 'use POSIX; print strftime "%d-%m-%y",localtime time-1814400;')
ARCHIVEDIR=/varsoft/delivery/mlogistics/archivelog

cd $ARCHIVEDIR

# Finding and delete the old logs
find . -type f -mtime $(echo $(date +%s) - $EDGE_DATE | bc -l | awk '{print $1 / 86400}' | bc -l) | rm $ARCHIVEDIR/log_${DATE_FORMATED}.tar

