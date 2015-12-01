#!/bin/bash
YESTERDAY=$(perl -e 'use POSIX; print strftime "%s",localtime time-86400;')
YESTERDAY_FORMATED=$(perl -e 'use POSIX; print strftime "%d-%m-%y",localtime time-86400;')

# ziping the log files of yesterday

cd /home/mlogistics/shared/log/
find . -type f -mtime $(echo $(date +%s) - $YESTERDAY | bc -l | awk '{print $1 / 86400}' | bc -l) | xargs tar -rf log_$YESTERDAY_FORMATED.tar
gzip log_$YESTERDAY_FORMATED.tar

mv /home/mlogistics/shared/log/log_$YESTERDAY_FORMATED.tar.gz /home/mlogistics/backup/shared/log/

echo "Done"