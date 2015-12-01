create or replace PROCEDURE App_Statistics_Detailed_CSV AS

BEGIN

DECLARE
    F UTL_FILE.FILE_TYPE;
    i integer;

    
    CURSOR C1
    IS 
        SELECT 
          t.master_id appoinmtnet_id,  
          thi.SALES_ID,       
          DECODE (thi.completion_code,
                  0, 'Successful',
                  'Failed'
                 ) AS Appointement_result,
          CASE
             WHEN thi.completion_code = '0'
                THEN ''
             ELSE thi.completion_code_text
          END AS Fail_Reason,
          thi.completion_text,
          thi.ODBCODE,
          ra.starttime,
          ra.endtime,
          thi.region,
          t.UPDATE_USER eng_name,
          usr.MOBILE eng_phone1,
          usr.phone eng_phone2,
          ac1.ACTIVITY_DT inWork,
          ac2.ACTIVITY_DT closed
        FROM tbtaskinfo ti
        JOIN TBTHI_MO thi ON ti.ID = thi.ID
        JOIN tbtask t ON t.ID = ti.task_id
        JOIN tbbusinessunit bu ON t.businessunit_id = bu.ID
        JOIN tbreservedappointment ra ON t.master_id = ra.taskmaster_id
        JOIN tbuser usr ON usr.USERNAME = t.UPDATE_USER
        JOIN (
          SELECT ac.TASK_ID, ac.ACTIVITY_DT, ac.ACTIVITY_TYPE FROM TBTASKACTIVITY ac
          JOIN(
            SELECT max(id) id, TASK_ID
            FROM TBTASKACTIVITY
            WHERE ACTIVITY_TYPE = 150
            GROUP BY TASK_ID, ACTIVITY_TYPE
          )ac0 ON ac.id = ac0.id
        ) ac1 ON ac1.task_id = t.id
        JOIN TBTASKACTIVITY ac2 ON ac2.task_id = t.id 
        WHERE t.status = '200'
        AND bu.NAME <> 'BU_VirtualVendor'        --Exclude vendor for Test
        AND TRUNC(ra.starttime) = trunc(sysdate)-1 
        AND ac1.ACTIVITY_TYPE = 150
        AND ac2.ACTIVITY_TYPE = 200
        --=============
        UNION all
        --============== appointment history
        SELECT 
          t.master_id appoinmtnet_id, 
          thi.SALES_ID,           
          'Failed' AS Appointement_result,
          'Rescheduled' AS Fail_Reason, 
          thi.completion_text,
          thi.ODBCODE,
          tbh.starttime,
          tbh.endtime,
          thi.region,
          t.UPDATE_USER eng_name,
          usr.MOBILE eng_phone1,
          usr.phone eng_phone2,
          ac1.ACTIVITY_DT inWork,
          ac2.ACTIVITY_DT closed
        FROM   tbtaskinfo ti
        JOIN TBTHI_MO thi ON ti.ID = thi.ID
        JOIN tbtask t ON t.ID = ti.task_id
        JOIN tbappointmenthistory tbh ON tbh.taskmaster_id = t.master_id  
        JOIN tbuser usr ON usr.USERNAME = t.UPDATE_USER
        LEFT JOIN (
          SELECT ac.TASK_ID, ac.ACTIVITY_DT, ac.ACTIVITY_TYPE FROM TBTASKACTIVITY ac
          JOIN(
            SELECT max(id) id, TASK_ID
            FROM TBTASKACTIVITY
            WHERE ACTIVITY_TYPE = 150
            GROUP BY TASK_ID, ACTIVITY_TYPE
          )ac0 ON ac.id = ac0.id 
        )ac1 ON (ac1.task_id = t.id AND ac1.ACTIVITY_TYPE = 150)
        LEFT JOIN TBTASKACTIVITY ac2 ON (ac2.task_id = t.id AND ac2.ACTIVITY_TYPE = 200)
        WHERE TRUNC(tbh.starttime) = trunc(sysdate)-1 
        ;
    C1_R C1%ROWTYPE;

BEGIN

  open C1;
  fetch C1 into C1_R;
 
  IF C1%FOUND THEN

    F := UTL_FILE.FOPEN('APPOINTMENTS_STATISTICS','appointments_statistics_detailed_report.csv','w',32767);
    
    UTL_FILE.PUT(F,
      'Appointement ID'|| ';' || 'Sales Order#'|| ';' 
      || 'Appointement Result'|| ';' || 'Fail Reason' || ';'
      || 'Compleation Comments'|| ';' || 'ODB' || ';'
      || 'App. Start Time' || ';' || 'App. End Time'|| ';' || 'Region' || ';'
      || 'Technician ID' || ';' || 'Technician Phone1'|| ';' || 'Technician Phone2' || ';'
      || 'Start In Work datetime'|| ';' || 'End In Work datetime' );
    UTL_FILE.NEW_LINE(F);
    LOOP    
      UTL_FILE.PUT(F, 
        C1_R.appoinmtnet_id || ';' || C1_R.SALES_ID || ';'
        || C1_R.Appointement_result || ';' || C1_R.Fail_Reason || ';'
        || C1_R.completion_text || ';' || C1_R.ODBCODE || ';'
        || C1_R.starttime || ';' || C1_R.endtime || ';' || C1_R.region || ';'
        || C1_R.eng_name || ';' || C1_R.eng_phone1 || ';' || C1_R.eng_phone2 || ';' 
        || C1_R.inWork || ';' || C1_R.closed);
      UTL_FILE.NEW_LINE(F);   
      i:=i+1;
        
      fetch C1 into C1_R;
      EXIT WHEN C1%NOTFOUND;
    END LOOP;
    
    
    UTL_FILE.FCLOSE(F);
  
  end if;
  
  close C1; 
  
END;

END;