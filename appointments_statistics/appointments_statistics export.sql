create or replace PROCEDURE appointments_statistics AS

BEGIN

DECLARE
    F UTL_FILE.FILE_TYPE;
    i integer;

    
    CURSOR C1
    IS 
SELECT a.Appointement_result,a.fail_reason,a.count total,(round ((a.count*100/b.sum),2)) /*|| ' %' */as Percentage FROM 
  (SELECT Appointement_result,Fail_Reason,  COUNT(1) count
  FROM (
  (SELECT
    '1' "Count",
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
  AND TRUNC(ra.starttime) = trunc(sysdate)-1
  AND ac1.ACTIVITY_TYPE = 150
  AND ac2.ACTIVITY_TYPE = 200
  )
  UNION all
  (                                                --appointment history
  SELECT
    '1' "Count",
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
  AND TRUNC(tbh.starttime) = trunc(sysdate)-1
  )
  )group by Appointement_result, Fail_Reason
  ORDER BY 1 DESC, 3 DESC) a,
  (SELECT count_,sum(1) Sum--, (Count(1) *100)/(select count (*) from  ) 
  FROM (
  (SELECT
    '1' count_,
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
  AND TRUNC(ra.starttime) = trunc(sysdate)-1
  AND ac1.ACTIVITY_TYPE = 150
  AND ac2.ACTIVITY_TYPE = 200
  )
  UNION all
  (                                                --appointment history
  SELECT
    '1' count_,
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
  AND TRUNC(tbh.starttime) = trunc(sysdate)-1
  )) group by count_ 
  ORDER BY 1 DESC) b;
  
    C1_R C1%ROWTYPE;

BEGIN

  open C1;
  fetch C1 into C1_R;
 
  IF C1%FOUND THEN

    F := UTL_FILE.FOPEN('APPOINTMENTS_STATISTICS','appointments_statistics_report.csv','w',32767);
    
    UTL_FILE.PUT(F,'Appointement Result'|| ';' || 'Fail Reason'|| ';' || 'Total'|| ';' || 'Percentage');
    
    UTL_FILE.NEW_LINE(F);
    LOOP    
      UTL_FILE.PUT(F, C1_R.Appointement_result || ';' || C1_R.fail_reason || ';' || C1_R.total || ';' || C1_R.Percentage);
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