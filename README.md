# Little big scripts :)
This project contains some Shell and SQL scripts that I’ve built during previous projects


> [`archive_yesterday_log.sh`} - shell script to archive the log files of yesterday and move them to the log backup dirictory

> [`delete_old_log_batch.sh`] - Ok, this one to delete the old log files after 20 days! it just takes so much space in the server. Runs inside a cron-job.

> [`appointments_statistics`] - 3 scripts:
 * SQL: runing a DB job to get differnet information about appointments statistcs (218 lines)
 * SQL: runing a DB job to get details information about it (133 lines)
 * Shell: take the first one and embead it in an HTML email body, then take the second one and add it as attachment. It runs inside a crontab everday after the DB jobs is executed

> [`engineers_capacity_report.sql`] - trying to simplify: this procedure find the capacity of each team (~1000 line)
