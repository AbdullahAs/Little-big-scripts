
#!/bin/bash
# ===================================================================================
# INITIALIZATION
# ===================================================================================

SENDMAILEXE=/home/oracle/test/sendEmail-v1.56/sendEmail
SQLPLUSCMD=/u01/app/oracle/product/11.2.0/db_1/bin/sqlplus

# Date Variables
YESTERDAY=$(perl -e 'use POSIX; print strftime "%Y-%m-%d",localtime time-86400;')
TODAY=$(date +%Y%m%d)

# Mail Variables
TITLEMAIL="Appointments Statistics Report of $YESTERDAY"
MAILSENDER="xxx@x.x"
MAILRCVR="y@y.y; z@z.z"
MAILRCVR_CC="c@c.c"
MAILHOST= 'xxx'
CONTENTTYPE="message-content-type=html"
REPORTS_FOLDER="xxx"


# ===================================================================================
# Email
# ===================================================================================

# Rename the file to add the date
cd "${REPORTS_FOLDER}/reports_history"
MAILFILES_PACKAGE="${REPORTS_FOLDER}/reports_history/appointments_statistics_detailed_report.csv"

# appointments_statistics_report.csv file is generated through a DB job daily just before the crobjob runs
# Create the HTML table out of the csv file
TABLE1=`
while read INPUT ;
do
	echo "<tr><td>${INPUT//;/</td><td>}</td></tr>" ;
done < appointments_statistics_report.csv;
`

# Mail body
cd ..
BODYMAIL=`cat header.html`
BODYMAIL=${BODYMAIL}"$TABLE1 \n\n"
BODYMAIL=${BODYMAIL}`cat footer.html`

# To send the mail
${SENDMAILEXE} -f ${MAILSENDER} -t ${MAILRCVR} -cc ${MAILRCVR_CC} -u "${TITLEMAIL}" -m "${BODYMAIL}" -s ${MAILHOST} -o ${CONTENTTYPE} -a ${MAILFILES_PACKAGE}
