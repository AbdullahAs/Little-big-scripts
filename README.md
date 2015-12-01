# Little big scripts :)
This project contains some Shell and SQL scripts that I’ve built during previous projects


> [`archive_yesterday_log.sh`} - shell script to archive the log files of yesterday and move them to the log backup dirictory

> [`delete_old_log_batch.sh`] - Ok, this one to delete the old log files after 20 days! it just takes so much space in the server. Runs inside a cron-job.

> [`appointments_statistics`] - 3 scripts:
> * SQL: runing a DB job to get differnet information about appointments statistcs
> * SQL: runing a DB job to get details information about it
> * Bash: take the first one and embead it in an HTML email body, then take the second one and add it as attachment. It runs inside a crontab everday after the DB jobs is executed


