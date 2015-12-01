-- =================
-- test the following query (use PROFILE_ID = 1 for non_vip)
-- =================

SELECT TRUNC(c.start_dt) AS "Date",
  sp.name Partition,
  (
  CASE
    WHEN (r.name IS NULL)
    THEN ('No-Region')
    ELSE (r.name)
  END)                             AS Region,
  COUNT(           *)              AS engineers,
  ROUND((SUM(end_dt - start_dt)*24)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 21)/100)) AS hours, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+12/24
    AND c.end_dt      < TRUNC(sysdate)+16/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+12/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+12/24
        AND c.end_dt    < TRUNC(sysdate)+16/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+12/24
            AND c.end_dt   <= TRUNC(sysdate)+16/24
            THEN ((TRUNC(sysdate)           +16/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+12/24
                AND c.end_dt    >= TRUNC(sysdate)+16/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 21)/100)) AS slot_12_16, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+16/24
    AND c.end_dt      < TRUNC(sysdate)+20/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+16/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+16/24
        AND c.end_dt    < TRUNC(sysdate)+20/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+16/24
            AND c.end_dt   <= TRUNC(sysdate)+20/24
            THEN ((TRUNC(sysdate)           +20/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+16/24
                AND c.end_dt    >= TRUNC(sysdate)+20/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 21)/100)) AS slot_16_20, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+20/24
    AND c.end_dt      < TRUNC(sysdate)+24/24
    AND c.end_dt      > TRUNC(sysdate)+20/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+20/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+20/24
        AND c.end_dt    < TRUNC(sysdate)+24/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+20/24
            AND c.end_dt   <= TRUNC(sysdate)+24/24
            THEN ((TRUNC(sysdate)           +24/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+20/24
                AND c.end_dt    >= TRUNC(sysdate)+24/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 21)/100)) AS slot_20_24 -- mutibalying by the capacity limit for VIP (non-VIP)
FROM tbcalendar c
JOIN tbschedulerpartition sp ON sp.id = c.schedpartition_id
LEFT JOIN tbregion r ON c.workregion_id      = r.id
WHERE TRUNC(c.start_dt) = TRUNC(sysdate)
AND c.start_dt         <> c.end_dt
GROUP BY TRUNC(c.start_dt),
  sp.name,
  r.name
ORDER BY 2,3 ASC; 

-- =================
-- if it's ok create the tables 
-- =================

CREATE TABLE "MLOGMOBILY"."STS_CAPACITY_VIP" 
 (	"Date" DATE, 
"Partition" VARCHAR2(64 BYTE), 
"Region" VARCHAR2(64 BYTE), 
"No. Team" NUMBER, 
"Tot. Hours" NUMBER, 
"Cal_Slot_1" NUMBER, 
"Cal_Slot_2" NUMBER, 
"Cal_Slot_3" NUMBER
 ) SEGMENT CREATION IMMEDIATE 
PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
NOCOMPRESS LOGGING
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;


  CREATE TABLE "MLOGMOBILY"."STS_APPOINTMENTS_VIP" 
   (	"Date" DATE, 
	"Partition" VARCHAR2(64 BYTE), 
	"Region" VARCHAR2(64 BYTE), 
	"No. Appointments" NUMBER, 
	"Tot. Hours" NUMBER, 
	"App_Slot_1" NUMBER, 
	"App_Slot_2" NUMBER, 
	"App_Slot_3" NUMBER
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;



  CREATE TABLE "MLOGMOBILY"."STS_CAPACITY_LIMIT_VIP" 
   (	"Date" DATE, 
	"Partition" VARCHAR2(64 BYTE), 
	"Region" VARCHAR2(64 BYTE), 
	"Capacity_Limit" NUMBER, 
	"Tot. Hours" NUMBER, 
	"Cap_Slot_1" NUMBER, 
	"Cap_Slot_2" NUMBER, 
	"Cap_Slot_3" NUMBER
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;


-- =================
-- then the proceedures
-- =================

create or replace procedure store_calendar_vip
as
begin
-- Load the Today Calendar within the table STS_CAPACITY

insert into STS_CAPACITY_VIP
-- Take morning snapshot

SELECT TRUNC(c.start_dt) AS "Date",
  sp.name Partition,
  (
  CASE
    WHEN (r.name IS NULL)
    THEN ('No-Region')
    ELSE (r.name)
  END)                             AS Region,
  COUNT(           *)              AS engineers,
  ROUND((SUM(end_dt - start_dt)*24)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 21)/100)) AS hours, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+12/24
    AND c.end_dt      < TRUNC(sysdate)+16/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+12/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+12/24
        AND c.end_dt    < TRUNC(sysdate)+16/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+12/24
            AND c.end_dt   <= TRUNC(sysdate)+16/24
            THEN ((TRUNC(sysdate)           +16/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+12/24
                AND c.end_dt    >= TRUNC(sysdate)+16/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 21)/100)) AS slot_12_16, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+16/24
    AND c.end_dt      < TRUNC(sysdate)+20/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+16/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+16/24
        AND c.end_dt    < TRUNC(sysdate)+20/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+16/24
            AND c.end_dt   <= TRUNC(sysdate)+20/24
            THEN ((TRUNC(sysdate)           +20/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+16/24
                AND c.end_dt    >= TRUNC(sysdate)+20/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 21)/100)) AS slot_16_20, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+20/24
    AND c.end_dt      < TRUNC(sysdate)+24/24
    AND c.end_dt      > TRUNC(sysdate)+20/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+20/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+20/24
        AND c.end_dt    < TRUNC(sysdate)+24/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+20/24
            AND c.end_dt   <= TRUNC(sysdate)+24/24
            THEN ((TRUNC(sysdate)           +24/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+20/24
                AND c.end_dt    >= TRUNC(sysdate)+24/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 21)/100)) AS slot_20_24 -- mutibalying by the capacity limit for VIP (non-VIP)
FROM tbcalendar c
JOIN tbschedulerpartition sp ON sp.id = c.schedpartition_id
LEFT JOIN tbregion r ON c.workregion_id      = r.id
WHERE TRUNC(c.start_dt) = TRUNC(sysdate)
AND c.start_dt         <> c.end_dt
GROUP BY TRUNC(c.start_dt),
  sp.name,
  r.name
ORDER BY 2,3 ASC;


commit;

exception
WHEN NO_DATA_FOUND THEN RAISE;      
      
end;

-- =====================================================================================================

create or replace procedure store_calendar
as
begin
-- Load the Today Calendar within the table STS_CAPACITY

insert into STS_CAPACITY
-- Take morning snapshot

SELECT TRUNC(c.start_dt) AS "Date",
  sp.name Partition,
  (
  CASE
    WHEN (r.name IS NULL)
    THEN ('No-Region')
    ELSE (r.name)
  END)                             AS Region,
  COUNT(           *)              AS engineers,
  ROUND((SUM(end_dt - start_dt)*24)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 1)/100)) AS hours, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+12/24
    AND c.end_dt      < TRUNC(sysdate)+16/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+12/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+12/24
        AND c.end_dt    < TRUNC(sysdate)+16/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+12/24
            AND c.end_dt   <= TRUNC(sysdate)+16/24
            THEN ((TRUNC(sysdate)           +16/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+12/24
                AND c.end_dt    >= TRUNC(sysdate)+16/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 1)/100)) AS slot_12_16, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+16/24
    AND c.end_dt      < TRUNC(sysdate)+20/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+16/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+16/24
        AND c.end_dt    < TRUNC(sysdate)+20/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+16/24
            AND c.end_dt   <= TRUNC(sysdate)+20/24
            THEN ((TRUNC(sysdate)           +20/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+16/24
                AND c.end_dt    >= TRUNC(sysdate)+20/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 1)/100)) AS slot_16_20, -- mutibalying by the capacity limit for VIP (non-VIP)
  ROUND(SUM(
  CASE
    WHEN (c.start_dt <= TRUNC(sysdate)+20/24
    AND c.end_dt      < TRUNC(sysdate)+24/24
    AND c.end_dt      > TRUNC(sysdate)+20/24)
    THEN (c.end_dt                    - (TRUNC(sysdate)+20/24))*24
    ELSE (
      CASE
        WHEN c.start_dt > TRUNC(sysdate)+20/24
        AND c.end_dt    < TRUNC(sysdate)+24/24
        THEN (c.end_dt                  - c.start_dt)*24
        ELSE (
          CASE
            WHEN c.start_dt > TRUNC(sysdate)+20/24
            AND c.end_dt   <= TRUNC(sysdate)+24/24
            THEN ((TRUNC(sysdate)           +24/24) - c.start_dt)*24
            ELSE (
              CASE
                WHEN c.start_dt <= TRUNC(sysdate)+20/24
                AND c.end_dt    >= TRUNC(sysdate)+24/24
                THEN 4
                ELSE 0
              END)
          END)
      END)
  END)*((SELECT CAPACITYLIMIT FROM TBPROFILECAPACITYITEM WHERE PROFILE_ID = 1)/100)) AS slot_20_24 -- mutibalying by the capacity limit for VIP (non-VIP)
FROM tbcalendar c
JOIN tbschedulerpartition sp ON sp.id = c.schedpartition_id
LEFT JOIN tbregion r ON c.workregion_id      = r.id
WHERE TRUNC(c.start_dt) = TRUNC(sysdate)
AND c.start_dt         <> c.end_dt
GROUP BY TRUNC(c.start_dt),
  sp.name,
  r.name
ORDER BY 2,3 ASC;


commit;

exception
WHEN NO_DATA_FOUND THEN RAISE;      
      
end;

-- =====================================================================================================

create or replace procedure store_apppointments
as
begin
-- Load the Today Calendar within the table STS_CAPACITY

insert into STS_APPOINTMENTS
SELECT TRUNC(ra.starttime) DATETIME,
  bu.name vendor,
  r.name region,
  COUNT(                *) appointments,
  ROUND(SUM((ra.duration+60)/60)) hours,
  ROUND(SUM(
  CASE
    WHEN ra.starttime = TRUNC(sysdate)+12/24
    THEN (ra.duration                 +60)/60
    ELSE 0
  END)) slot_12_16,
  ROUND(SUM(
  CASE
    WHEN ra.starttime = TRUNC(sysdate)+16/24
    THEN (ra.duration                 +60)/60
    ELSE 0
  END)) slot_16_20,
  ROUND(SUM(
  CASE
    WHEN ra.starttime = TRUNC(sysdate)+20/24
    THEN (ra.duration                 +60)/60
    ELSE 0
  END)) slot_20_24
FROM tbreservedappointment ra
JOIN tbbusinessunit bu
ON ra.businessunit_id = bu.id
JOIN tbregionlocation gl
ON ra.zipcity_id = gl.zipcity_id
JOIN tbregion r
ON gl.region_id = r.id
LEFT JOIN TBTHI_MO mo
ON ra.EXTERNALTASKID      = mo.WO_ID
WHERE TRUNC(ra.starttime) = TRUNC(sysdate)
AND (mo.vip IS NULL OR mo.VIP = 0)  -- Non VIP customers 
GROUP BY bu.name,
  TRUNC(ra.starttime),
  r.name
ORDER BY 2,
  3;
  

commit;

exception
WHEN NO_DATA_FOUND THEN RAISE;      
      
end;

-- =====================================================================================================

create or replace procedure store_apppointments_VIP
as
begin
-- Load the Today Calendar within the table STS_CAPACITY

insert into STS_APPOINTMENTS_VIP
SELECT TRUNC(ra.starttime) DATETIME,
  bu.name vendor,
  r.name region,
  COUNT(                *) appointments,
  ROUND(SUM((ra.duration+60)/60)) hours,
  ROUND(SUM(
  CASE
    WHEN ra.starttime = TRUNC(sysdate)+12/24
    THEN (ra.duration                 +60)/60
    ELSE 0
  END)) slot_12_16,
  ROUND(SUM(
  CASE
    WHEN ra.starttime = TRUNC(sysdate)+16/24
    THEN (ra.duration                 +60)/60
    ELSE 0
  END)) slot_16_20,
  ROUND(SUM(
  CASE
    WHEN ra.starttime = TRUNC(sysdate)+20/24
    THEN (ra.duration                 +60)/60
    ELSE 0
  END)) slot_20_24
FROM tbreservedappointment ra
JOIN tbbusinessunit bu
ON ra.businessunit_id = bu.id
JOIN tbregionlocation gl
ON ra.zipcity_id = gl.zipcity_id
JOIN tbregion r
ON gl.region_id = r.id
LEFT JOIN TBTHI_MO mo
ON ra.EXTERNALTASKID      = mo.WO_ID
WHERE TRUNC(ra.starttime) = TRUNC(sysdate)
AND mo.VIP = 1  -- VIP customers 
GROUP BY bu.name,
  TRUNC(ra.starttime),
  r.name
ORDER BY 2,
  3;
  

commit;

exception
WHEN NO_DATA_FOUND THEN RAISE;      
      
end;

-- =====================================================================================================

create or replace procedure store_capacity_limit
as
begin
-- Load the capacity limit in according to the system limit and the capacity (STS_CAPACITY)

insert into STS_CAPACITY_LIMIT
-- Take morning snapshot

select 
c."Date", 
c."Partition", 
c."Region", 
spp.paramvalue as capacity_limit, 
to_number (spp.paramvalue)/100*to_number(c."Tot. Hours") as Tot_Cap_H, 
to_number (spp.paramvalue)/100*to_number(c."Cal_Slot_1") as Cap_Slot_1, 
to_number (spp.paramvalue)/100*to_number(c."Cal_Slot_2") as Cap_Slot_2, 
to_number (spp.paramvalue)/100*to_number(c."Cal_Slot_3") as Cap_Slot_3
from sts_capacity c, tbschedulerpartition sp, tbschedpartparameter spp
where sp.name= c."Partition" and sp.id = spp.partition_id and spp.paramname = 'SYSTEM_LIMIT';


commit;

exception
WHEN NO_DATA_FOUND THEN RAISE;      
      
end;

-- =====================================================================================================

CREATE OR REPLACE PROCEDURE store_capacity_limit_vip
AS
BEGIN
  -- Load the capacity limit in according to the system limit and the capacity (STS_CAPACITY)
  INSERT
  INTO STS_CAPACITY_LIMIT_VIP
  -- Take morning snapshot
  SELECT c."Date",
    c."Partition",
    c."Region",
    spp.paramvalue                                           AS capacity_limit,
    to_number (spp.paramvalue)/100*to_number(c."Tot. Hours") AS Tot_Cap_H,
    to_number (spp.paramvalue)/100*to_number(c."Cal_Slot_1") AS Cap_Slot_1,
    to_number (spp.paramvalue)/100*to_number(c."Cal_Slot_2") AS Cap_Slot_2,
    to_number (spp.paramvalue)/100*to_number(c."Cal_Slot_3") AS Cap_Slot_3
  FROM STS_CAPACITY_VIP c,
    tbschedulerpartition sp,
    tbschedpartparameter spp
  WHERE sp.name     = c."Partition"
  AND sp.id         = spp.partition_id
  AND spp.paramname = 'SYSTEM_LIMIT';
  COMMIT;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RAISE;
END;

-- =====================================================================================================
-- FINAL QUERY in mRic report
-- =====================================================================================================

SELECT partition,
  region,
  Cal_Date,
  num_team,
  Cal_Tot_h,
  cal_slot_1,
  cal_slot_2,
  cal_slot_3,
  cap_lim,
  Cap_Tot_h,
  cap_slot_1,
  cap_slot_2,
  cap_slot_3,
  App_Date,
  num_Appointments,
  App_Tot_h,
  app_slot_1,
  app_slot_2,
  app_slot_3,
  ROUND((App_Tot_h/Cap_Tot_h),2) Utilization
FROM
  (SELECT *
  FROM
    (SELECT partition,
      region,
      Cal_Date,
      num_team,
      Cal_Tot_h,
      cal_slot_1,
      cal_slot_2,
      cal_slot_3,
      cap_lim,
      Cap_Tot_h,
      cap_slot_1,
      cap_slot_2,
      cap_slot_3,
      App_Date,
      num_Appointments,
      App_Tot_h,
      app_slot_1,
      app_slot_2,
      app_slot_3
    FROM
      (SELECT c."Partition"               AS partition,
        c."Region"                        AS region,
        c."Date"                          AS Cal_Date,
        c."No. Team"                      AS num_team,
        c."Tot. Hours"                    AS Cal_Tot_h,
        c."Cal_Slot_1"                    AS cal_slot_1,
        c."Cal_Slot_2"                    AS cal_slot_2,
        c."Cal_Slot_3"                    AS cal_slot_3,
        to_number(l."Capacity_Limit")/100 AS cap_lim,
        l."Tot. Hours"                    AS Cap_Tot_h,
        l."Cap_Slot_1"                    AS cap_slot_1,
        l."Cap_Slot_2"                    AS cap_slot_2,
        l."Cap_Slot_3"                    AS cap_slot_3,
        a."Date"                          AS App_Date,
        a."No. Appointments"              AS num_Appointments,
        a."Tot. Hours"                    AS App_Tot_h,
        a."App_Slot_1"                    AS app_slot_1,
        a."App_Slot_2"                    AS app_slot_2,
        a."App_Slot_3"                    AS app_slot_3
      FROM sts_capacity_vip c,
        sts_appointments_vip a,
        sts_capacity_limit_vip l
      WHERE TRUNC(c."Date" (+)) = TRUNC(a."Date")
      AND c."Partition" (+)     = SUBSTR(a."Partition",4,3)
      AND c."Region" (+)        = a."Region"
      AND TRUNC(c."Date" (+)) BETWEEN TRUNC(sysdate-20) AND TRUNC(sysdate)
      AND TRUNC(a."Date") BETWEEN TRUNC(sysdate    -20) AND TRUNC(sysdate)
      AND TRUNC(c."Date") = TRUNC(l."Date")
      AND c."Partition"   = l."Partition"
      AND c."Region"      = l."Region"
      AND c."Partition"  IN
        (SELECT SUBSTR(name, 4) FROM TBBUSINESSUNIT WHERE bo_id=1
        )
      UNION
      SELECT c."Partition"                AS partition,
        c."Region"                        AS region,
        c."Date"                          AS Cal_Date,
        c."No. Team"                      AS num_team,
        c."Tot. Hours"                    AS Cal_Tot_h,
        c."Cal_Slot_1"                    AS cal_slot_1,
        c."Cal_Slot_2"                    AS cal_slot_2,
        c."Cal_Slot_3"                    AS cal_slot_3,
        to_number(l."Capacity_Limit")/100 AS cap_lim,
        l."Tot. Hours"                    AS Cap_Tot_h,
        l."Cap_Slot_1"                    AS cap_slot_1,
        l."Cap_Slot_2"                    AS cap_slot_2,
        l."Cap_Slot_3"                    AS cap_slot_3,
        a."Date"                          AS App_Date,
        a."No. Appointments"              AS num_Appointments,
        a."Tot. Hours"                    AS App_Tot_h,
        a."App_Slot_1"                    AS app_slot_1,
        a."App_Slot_2"                    AS app_slot_2,
        a."App_Slot_3"                    AS app_slot_3
      FROM sts_capacity_vip c,
        sts_appointments_vip a,
        sts_capacity_limit_vip l
      WHERE TRUNC(c."Date") = TRUNC(a."Date" (+))
      AND c."Partition"     = SUBSTR(a."Partition" (+),4,3)
      AND c."Region"        = a."Region" (+)
      AND TRUNC(c."Date") BETWEEN TRUNC(sysdate   -20) AND TRUNC(sysdate)
      AND TRUNC(a."Date"(+)) BETWEEN TRUNC(sysdate-20) AND TRUNC(sysdate)
      AND TRUNC(c."Date") = TRUNC(l."Date")
      AND c."Partition"   = l."Partition"
      AND c."Region"      = l."Region"
      AND c."Partition"  IN
        (SELECT SUBSTR(name, 4) FROM TBBUSINESSUNIT WHERE bo_id=1
        )
      )
    WHERE
      -- partition like :pVendor and
      partition NOT LIKE '%VirtualVendor%'
    AND partition NOT LIKE '%Vendor%'
    -- and region like :pRegion
    UNION
    SELECT Partition,
      Region,
      "Date" Cal_Date,
      engineers AS num_team,
      Cal_Tot_h,
      cal_slot_1,
      cal_slot_2,
      cal_slot_3,
      capacity_limit AS cap_lim,
      Cap_Tot_h,
      cap_slot_1,
      cap_slot_2,
      cap_slot_3,
      DATETIME App_Date,
      appointments AS num_Appointments,
      hours1       AS App_Tot_h,
      slot_12_16   AS app_slot_1,
      slot_16_20   AS app_slot_2,
      slot_20_24   AS app_slot_3
    FROM
      (SELECT Partition,
        Region,
        "Date",
        engineers,
        Cal_Tot_h,
        cal_slot_1,
        cal_slot_2,
        cal_slot_3,
        capacity_limit,
        Cap_Tot_h,
        cap_slot_1,
        cap_slot_2,
        cap_slot_3,
        DATETIME,
        appointments,
        hours1,
        slot_12_16,
        slot_16_20,
        slot_20_24
      FROM
        (SELECT TRUNC(c.start_dt) AS "Date",
          sp.name Partition,
          (
          CASE
            WHEN (r.name IS NULL)
            THEN ('No-Region')
            ELSE (r.name)
          END)                             AS Region,
          COUNT(           *)              AS engineers,
          ROUND(SUM(end_dt - start_dt)*24) AS Cal_Tot_h,
          ROUND(SUM(
          CASE
            WHEN (c.start_dt <= TRUNC(c.start_dt)+12/24
            AND c.end_dt     >= TRUNC(c.start_dt)+16/24)
            THEN 4
            ELSE (
              CASE
                WHEN c.start_dt < TRUNC(c.start_dt)+12/24
                AND c.end_dt    > TRUNC(c.start_dt)+12/24
                AND c.end_dt    < TRUNC(c.start_dt)+16/24
                THEN (c.end_dt                     - TRUNC(c.start_dt)+12/24) * 24
                ELSE (
                  CASE
                    WHEN c.start_dt > TRUNC(c.start_dt)+12/24
                    AND c.end_dt    < TRUNC(c.start_dt)+16/24
                    THEN (end_dt                       - start_dt)*24
                    ELSE (
                      CASE
                        WHEN c.start_dt > TRUNC(c.start_dt)+12/24
                        AND c.start_dt  < TRUNC(c.start_dt)+16/24
                        AND c.end_dt    > TRUNC(c.start_dt)+16/24
                        THEN (TRUNC(c.start_dt)            +16/24 - c.start_dt)*24
                        ELSE 0
                      END )
                  END)
              END)
          END)) AS cal_slot_1,
          ROUND(SUM(
          CASE
            WHEN (c.start_dt <= TRUNC(c.start_dt)+16/24
            AND c.end_dt     >= TRUNC(c.start_dt)+20/24)
            THEN 4
            ELSE (
              CASE
                WHEN c.start_dt < TRUNC(c.start_dt)+16/24
                AND c.end_dt    > TRUNC(c.start_dt)+16/24
                AND c.end_dt    < TRUNC(c.start_dt)+20/24
                THEN (c.end_dt                     - TRUNC(c.start_dt)+16/24) * 24
                ELSE (
                  CASE
                    WHEN c.start_dt > TRUNC(c.start_dt)+16/24
                    AND c.end_dt    < TRUNC(c.start_dt)+20/24
                    THEN (end_dt                       - start_dt)*24
                    ELSE (
                      CASE
                        WHEN c.start_dt > TRUNC(c.start_dt)+16/24
                        AND c.start_dt  < TRUNC(c.start_dt)+20/24
                        AND c.end_dt    > TRUNC(c.start_dt)+20/24
                        THEN (TRUNC(c.start_dt)            +20/24 - c.start_dt)*24
                        ELSE 0
                      END )
                  END)
              END)
          END)) AS cal_slot_2,
          ROUND(SUM(
          CASE
            WHEN (c.start_dt <= TRUNC(c.start_dt)+20/24
            AND c.end_dt     >= TRUNC(c.start_dt)+24/24)
            THEN 4
            ELSE (
              CASE
                WHEN c.start_dt < TRUNC(c.start_dt)+20/24
                AND c.end_dt    > TRUNC(c.start_dt)+20/24
                AND c.end_dt    < TRUNC(c.start_dt)+24/24
                THEN (c.end_dt                     - TRUNC(c.start_dt)+20/24) * 24
                ELSE (
                  CASE
                    WHEN c.start_dt > TRUNC(c.start_dt)+20/24
                    AND c.end_dt    < TRUNC(c.start_dt)+24/24
                    THEN (end_dt                       - start_dt)*24
                    ELSE (
                      CASE
                        WHEN c.start_dt > TRUNC(c.start_dt)+20/24
                        AND c.start_dt  < TRUNC(c.start_dt)+24/24
                        AND c.end_dt    > TRUNC(c.start_dt)+24/24
                        THEN (TRUNC(c.start_dt)            +24/24 - c.start_dt)*24
                        ELSE 0
                      END )
                  END)
              END)
          END))                                                                   AS cal_slot_3,
          to_number(spp.paramvalue)/100                                           AS capacity_limit,
          ROUND(SUM(end_dt         - start_dt)*24*to_number (spp.paramvalue)/100) AS Cap_Tot_h,
          ROUND(SUM(
          CASE
            WHEN (c.start_dt <= TRUNC(c.start_dt)+12/24
            AND c.end_dt     >= TRUNC(c.start_dt)+16/24)
            THEN 4
            ELSE (
              CASE
                WHEN c.start_dt < TRUNC(c.start_dt)+12/24
                AND c.end_dt    > TRUNC(c.start_dt)+12/24
                AND c.end_dt    < TRUNC(c.start_dt)+16/24
                THEN (c.end_dt                     - TRUNC(c.start_dt)+12/24) * 24
                ELSE (
                  CASE
                    WHEN c.start_dt > TRUNC(c.start_dt)+12/24
                    AND c.end_dt    < TRUNC(c.start_dt)+16/24
                    THEN (end_dt                       - start_dt)*24
                    ELSE (
                      CASE
                        WHEN c.start_dt > TRUNC(c.start_dt)+12/24
                        AND c.start_dt  < TRUNC(c.start_dt)+16/24
                        AND c.end_dt    > TRUNC(c.start_dt)+16/24
                        THEN (TRUNC(c.start_dt)            +16/24 - c.start_dt)*24
                        ELSE 0
                      END )
                  END)
              END)
          END)*to_number (spp.paramvalue)/100) AS cap_slot_1,
          ROUND(SUM(
          CASE
            WHEN (c.start_dt <= TRUNC(c.start_dt)+16/24
            AND c.end_dt     >= TRUNC(c.start_dt)+20/24)
            THEN 4
            ELSE (
              CASE
                WHEN c.start_dt < TRUNC(c.start_dt)+16/24
                AND c.end_dt    > TRUNC(c.start_dt)+16/24
                AND c.end_dt    < TRUNC(c.start_dt)+20/24
                THEN (c.end_dt                     - TRUNC(c.start_dt)+16/24) * 24
                ELSE (
                  CASE
                    WHEN c.start_dt > TRUNC(c.start_dt)+16/24
                    AND c.end_dt    < TRUNC(c.start_dt)+20/24
                    THEN (end_dt                       - start_dt)*24
                    ELSE (
                      CASE
                        WHEN c.start_dt > TRUNC(c.start_dt)+16/24
                        AND c.start_dt  < TRUNC(c.start_dt)+20/24
                        AND c.end_dt    > TRUNC(c.start_dt)+20/24
                        THEN (TRUNC(c.start_dt)            +20/24 - c.start_dt)*24
                        ELSE 0
                      END )
                  END)
              END)
          END)*to_number (spp.paramvalue)/100) AS cap_slot_2,
          ROUND(SUM(
          CASE
            WHEN (c.start_dt <= TRUNC(c.start_dt)+20/24
            AND c.end_dt     >= TRUNC(c.start_dt)+24/24)
            THEN 4
            ELSE (
              CASE
                WHEN c.start_dt < TRUNC(c.start_dt)+20/24
                AND c.end_dt    > TRUNC(c.start_dt)+20/24
                AND c.end_dt    < TRUNC(c.start_dt)+24/24
                THEN (c.end_dt                     - TRUNC(c.start_dt)+20/24) * 24
                ELSE (
                  CASE
                    WHEN c.start_dt > TRUNC(c.start_dt)+20/24
                    AND c.end_dt    < TRUNC(c.start_dt)+24/24
                    THEN (end_dt                       - start_dt)*24
                    ELSE (
                      CASE
                        WHEN c.start_dt > TRUNC(c.start_dt)+20/24
                        AND c.start_dt  < TRUNC(c.start_dt)+24/24
                        AND c.end_dt    > TRUNC(c.start_dt)+24/24
                        THEN (TRUNC(c.start_dt)            +24/24 - c.start_dt)*24
                        ELSE 0
                      END )
                  END)
              END)
          END)*to_number (spp.paramvalue)/100) AS cap_slot_3
        FROM tbcalendar c
        JOIN tbschedulerpartition sp
        ON sp.id           = c.schedpartition_id
        AND ORGANIZATION_ID=1
        JOIN tbregion r
        ON c.workregion_id = r.id
        JOIN tbschedpartparameter spp
        ON sp.id = spp.partition_id
        WHERE TRUNC(c.start_dt) BETWEEN TRUNC(sysdate+1) AND TRUNC(sysdate)
        AND c.start_dt   <> c.end_dt
        AND spp.paramname = 'SYSTEM_LIMIT'
        GROUP BY TRUNC(c.start_dt),
          sp.name,
          r.name,
          spp.paramvalue
        )
      JOIN
        (SELECT DATETIME,
          vendor,
          region1,
          appointments,
          hours1,
          slot_12_16,
          slot_16_20,
          slot_20_24
        FROM
          (SELECT TRUNC(ra.starttime) DATETIME,
            bu.name vendor,
            reg.name region1,
            COUNT(                *) appointments,
            ROUND(SUM((ra.duration+60)/60)) hours1,
            ROUND(SUM(
            CASE
              WHEN ra.starttime = TRUNC(ra.starttime)+12/24
              THEN (ra.duration                      +60)/60
              ELSE 0
            END)) slot_12_16,
            ROUND(SUM(
            CASE
              WHEN ra.starttime = TRUNC(ra.starttime)+16/24
              THEN (ra.duration                      +60)/60
              ELSE 0
            END)) slot_16_20,
            ROUND(SUM(
            CASE
              WHEN ra.starttime = TRUNC(ra.starttime)+20/24
              THEN (ra.duration                      +60)/60
              ELSE 0
            END)) slot_20_24
          FROM tbreservedappointment ra
          JOIN tbbusinessunit bu
          ON ra.businessunit_id = bu.id
          AND bu.BO_ID          =1 --to execlude b2b vendors
          JOIN tbregionlocation gl
          ON ra.zipcity_id = gl.zipcity_id
          JOIN tbregion reg
          ON gl.region_id = reg.id
          WHERE TRUNC(ra.starttime) BETWEEN
            CASE
              WHEN TRUNC(sysdate-20)>TRUNC(sysdate)
              THEN TRUNC(sysdate-20)
              ELSE TRUNC(sysdate+1)
            END
          AND TRUNC(sysdate)
          GROUP BY bu.name,
            TRUNC(ra.starttime),
            reg.name
          )
        ) ON DATETIME = "Date"
      WHERE Partition = SUBSTR(vendor,4,3)
      AND Region      = region1
      )
    WHERE
      -- partition like :pVendor and
      partition LIKE 'BU_%'
    AND partition NOT LIKE '%VirtualVendor%'
    AND partition NOT LIKE '%Vendor%'
      -- and region like :pRegion
    )
  ORDER BY 3,14 ASC
  );



-- =====================================================================================================
-- mRic report
-- =====================================================================================================

