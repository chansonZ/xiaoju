#function description: 
#procedure name: P_DM_webapp
#creator:MARS
#created:
#!/bin/bash
#today date
V_DATE=$1
##
if [ -z ${V_DATE} ];then
        V_DATE=`date +%Y-%m-%d`
fi

#yesterday data partition
V_PARYEAR=`date --date="$V_DATE-1 day" +%Y`
V_PARMONTH=`date --date="$V_DATE-1 day" +%m`
V_PARDAY=`date --date="$V_DATE-1 day" +%d`
V_PARDAY2=`date --date="$V_DATE-2 day" +%d`
V_PARYESTERDAY=`date --date="$V_DATE-1 day" +%Y%m%d`
#today,yesterday,7 day  ago,30 days ago,2 days ago  date
V_TODAY=`date -d $V_DATE "+%Y-%m-%d"`
V_YESTERDAY=`date --date="$V_DATE-1 day" +%Y-%m-%d`
V_7DAYS=`date --date="$V_DATE-7 day" +%Y-%m-%d`
V_WEEK=`date --date="$V_DATE-7 day" +%Y-%m-%d`
V_THREEWEEKS=`date --date="$V_DATE-21 day" +%Y-%m-%d`
V_THREEMONTHS=`date --date="$V_DATE-90 day" +%Y-%m-%d`
V_SIXMONTHS=`date --date="$V_DATE-180 day" +%Y-%m-%d`
V_15DAYS=`date --date="$V_DATE-15 day" +%Y-%m-%d`
V_30DAYS=`date --date="$V_DATE-30 day" +%Y-%m-%d`
V_TWODAYS=`date --date="$V_DATE-2 day" +%Y-%m-%d`
#30 days ago, 2 days ago data partition 
V_PAR7DAYS=`date --date="$V_DATE-7 day" +%Y%m%d`
V_PAR15DAYS=`date --date="$V_DATE-15 day" +%Y%m%d`
V_PAR30DAYS=`date --date="$V_DATE-30 day" +%Y%m%d`
V_PAR2DAYS=`date --date="$V_DATE-2 day" +%Y%m%d`
/home/xiaoju/hive-0.10.0/bin/hive -e"use app;
set hive.optimize.cp=true;
set hive.map.aggr=true;
set hive.groupby.mapaggr.checkinterval = 100000;
set hive.exec.parallel=true;
INSERT OVERWRITE TABLE WECHAT_PASSENGER PARTITION(YEAR='$V_PARYEAR',MONTH='$V_PARMONTH',DAY='$V_PARDAY')
SELECT 0 STATID,
		'$V_YESTERDAY' STATDATE,
		TWEB.AREA,
		0 CHANNEL,
		TWEB.WEBAPP_CNT,TWEB.WEBAPP_SUCCCNT,
		(CASE WHEN TWEB.ALLCALL_SUCCCNT<>0 THEN ROUND(TWEB.WEBAPP_SUCCCNT/TWEB.ALLCALL_SUCCCNT,3) ELSE 0.00 END) WEBAPP_SUCCRATE,
		TWEB.WEBAPP_WECHAT_SUCCCNT WEBAPP_WECHAT_CNT,
		(CASE WHEN TWEB.ALLWECHAT_SUCC_CNT<>0 THEN ROUND(TWEB.WEBAPP_WECHAT_SUCCCNT/TWEB.ALLWECHAT_SUCC_CNT,3) ELSE 0.00 END) WEBAPP_WECHAT_RATE,
		TWEB.ALL_WEBAPP_T_SUCCCNT-TWEB.ALL_WEBAPP_B_SUCCCNT WEBAPP_WECHAT_NEWCNT,
		(CASE WHEN TWEB.WEBAPP_WECHAT_SUCCCNT<>0 THEN ROUND((TWEB.ALL_WEBAPP_T_SUCCCNT-TWEB.ALL_WEBAPP_B_SUCCCNT)/TWEB.WEBAPP_WECHAT_SUCCCNT,3) ELSE 0.00 END)	WEBAPP_WECHAT_NEWRATE,
		(CASE WHEN TNATIVE.NATIVE_CNT IS NOT NULL THEN TNATIVE.NATIVE_CNT ELSE CAST(0 AS BIGINT) END),
		(CASE WHEN TNATIVE.NATIVE_SUCCCNT IS NOT NULL THEN TNATIVE.NATIVE_SUCCCNT ELSE CAST(0 AS BIGINT) END),
		(CASE WHEN TWEB.ALLCALL_SUCCCNT<>0 AND TNATIVE.NATIVE_SUCCCNT IS NOT NULL
				THEN ROUND(TNATIVE.NATIVE_SUCCCNT/TWEB.ALLCALL_SUCCCNT,3) ELSE 0.00 END) NATIVE_SUCCRATE, 
		(CASE WHEN TNATIVE.NATIVE_WECHAT_SUCCCNT IS NOT NULL THEN TNATIVE.NATIVE_WECHAT_SUCCCNT ELSE CAST(0 AS BIGINT) END),
		(CASE WHEN TWEB.ALLWECHAT_SUCC_CNT<>0 THEN ROUND(TNATIVE.NATIVE_WECHAT_SUCCCNT/TWEB.ALLWECHAT_SUCC_CNT,3) ELSE 0.00 END) NATIVE_WECHAT_RATE,
		TNATIVE.NATIVE_WECHAT_T_CNT-TNATIVE.NATIVE_WECHAT_B_SUCCCNT NATIVE_WECHAT_NEWCNT,
		(CASE WHEN TNATIVE.NATIVE_WECHAT_SUCCCNT<>0 THEN ROUND((TNATIVE.NATIVE_WECHAT_T_CNT-TNATIVE.NATIVE_WECHAT_B_SUCCCNT)/TNATIVE.NATIVE_WECHAT_SUCCCNT,3) ELSE 0.00 END) NATIVE_WECHAT_NEWRATE,
		(TWEB.WEBAPP_WECHAT_SUCCCNT+TNATIVE.NATIVE_WECHAT_SUCCCNT)  WECHAT_CNT,
		(TWEB.ALL_WEBAPP_T_SUCCCNT-TWEB.ALL_WEBAPP_B_SUCCCNT+TNATIVE.NATIVE_WECHAT_T_CNT-TNATIVE.NATIVE_WECHAT_B_SUCCCNT)  WECHAT_NEWCNT,
		(CASE WHEN (TWEB.ALL_WEBAPP_T_SUCCCNT-TWEB.ALL_WEBAPP_B_SUCCCNT+TNATIVE.NATIVE_WECHAT_T_CNT-TNATIVE.NATIVE_WECHAT_B_SUCCCNT)<>0 THEN ROUND((TWEB.WEBAPP_WECHAT_SUCCCNT+TNATIVE.NATIVE_WECHAT_SUCCCNT)/(TWEB.ALL_WEBAPP_T_SUCCCNT-TWEB.ALL_WEBAPP_B_SUCCCNT+TNATIVE.NATIVE_WECHAT_T_CNT-TNATIVE.NATIVE_WECHAT_B_SUCCCNT),3) ELSE 0.00 END)	 WECHAT_NEWRATE,
		TWEB.ALL_WEBAPP_T_SUCCCNT WEBAPP_WECHAT_TOTALCNT,
		(CASE WHEN TNATIVE.NATIVE_WECHAT_T_CNT IS NOT NULL THEN TNATIVE.NATIVE_WECHAT_T_CNT ELSE CAST(0 AS BIGINT) END) NATIVE_WECHAT_TOTALCNT,
		(CASE WHEN TWEB.ALL_WEBAPP_T_SUCCCNT IS NOT NULL AND TNATIVE.NATIVE_WECHAT_T_CNT IS NOT NULL 
				THEN TWEB.ALL_WEBAPP_T_SUCCCNT+TNATIVE.NATIVE_WECHAT_T_CNT
			  WHEN TWEB.ALL_WEBAPP_T_SUCCCNT IS NOT NULL AND TNATIVE.NATIVE_WECHAT_T_CNT IS NULL 
				THEN TWEB.ALL_WEBAPP_T_SUCCCNT
		      WHEN TWEB.ALL_WEBAPP_T_SUCCCNT IS NULL AND TNATIVE.NATIVE_WECHAT_T_CNT IS NOT NULL 
				THEN TNATIVE.NATIVE_WECHAT_T_CNT
			ELSE CAST(0 AS BIGINT) END) WECHAT_TOTALCNT,		
		(CASE WHEN TVERSION.ALLCNT IS NOT NULL AND  TVERSION.BEFORECNT IS NOT NULL 
				THEN TVERSION.ALLCNT- TVERSION.BEFORECNT
			  WHEN TVERSION.ALLCNT IS NOT NULL AND  TVERSION.BEFORECNT IS  NULL
				THEN TVERSION.ALLCNT
			ELSE  CAST( 0 AS BIGINT) END)  NATIVE_UPDATECNT,
		(CASE WHEN TVERSION.ALLCNT IS NOT NULL THEN TVERSION.ALLCNT ELSE CAST(0 AS BIGINT) END) NATIVE_TOTAL_UPDATECNT,
		(CASE WHEN TWECHAT.TOTAL1 IS NOT NULL THEN TWECHAT.TOTAL1 ELSE CAST(0 AS BIGINT) END),
		(CASE WHEN TWECHAT.TOTAL2 IS NOT NULL THEN TWECHAT.TOTAL2 ELSE CAST(0 AS BIGINT) END),
		(CASE WHEN TWECHAT.TOTAL3 IS NOT NULL THEN TWECHAT.TOTAL3 ELSE 0.00 END) WEBCHAT_TWO_AVGCNT
   FROM 
(SELECT (CASE WHEN AREA IS NULL THEN 10000 ELSE CAST(AREA AS INT) END) AREA,
        WEBAPP_CNT,
        WEBAPP_SUCCCNT,
        ALLCALL_SUCCCNT,
		ALLWECHAT_SUCC_CNT,
        WEBAPP_WECHAT_SUCCCNT,
		ALL_WEBAPP_T_SUCCCNT,
		ALL_WEBAPP_B_SUCCCNT
  FROM (SELECT AREA,
			   COUNT(DISTINCT (CASE WHEN CREATETIME>='$V_YESTERDAY' AND CREATETIME <'$V_DATE' AND CHANNEL =1200 
						THEN A.PASSENGERID ELSE 0 END))-1 WEBAPP_CNT,
			   COUNT(DISTINCT (CASE WHEN CREATETIME>='$V_YESTERDAY' AND CREATETIME <'$V_DATE' AND CHANNEL=1200 AND SUCC_FLAG =1 
						THEN A.PASSENGERID ELSE 0 END))-1 WEBAPP_SUCCCNT,
				 COUNT(DISTINCT (CASE WHEN CREATETIME>='$V_YESTERDAY' AND CREATETIME <'$V_DATE' AND SUCC_FLAG =1 
						THEN A.PASSENGERID ELSE 0 END))-1 ALLCALL_SUCCCNT,
			   COUNT(DISTINCT (CASE WHEN B.ORDERID IS NOT NULL AND CREATETIME>='$V_YESTERDAY' AND CREATETIME <'$V_DATE' AND A.SUCC_FLAG =1 
						THEN A.PASSENGERID ELSE 0 END))-1 ALLWECHAT_SUCC_CNT,		
			   COUNT(DISTINCT (CASE WHEN B.ORDERID IS NOT NULL AND CREATETIME>='$V_YESTERDAY' AND CREATETIME <'$V_DATE' AND A.CHANNEL=1200 AND A.SUCC_FLAG =1 THEN A.PASSENGERID ELSE 0 END))-1 WEBAPP_WECHAT_SUCCCNT,
			   COUNT(DISTINCT (CASE WHEN B.ORDERID IS NOT NULL AND CREATETIME <'$V_DATE' AND A.CHANNEL=1200 AND A.SUCC_FLAG =1 THEN A.PASSENGERID ELSE 0 END))-1 ALL_WEBAPP_T_SUCCCNT,
			   COUNT(DISTINCT (CASE WHEN B.ORDERID IS NOT NULL AND CREATETIME <'$V_YESTERDAY' AND A.CHANNEL=1200 AND A.SUCC_FLAG =1 THEN A.PASSENGERID ELSE 0 END))-1 ALL_WEBAPP_B_SUCCCNT

		  FROM 
			   (SELECT ORDERID, 
			   		 AREA,
					   PASSENGERID,
					   CHANNEL,
					   CREATETIME,
					   (CASE WHEN STATUS >=1 AND STATUS<=4 AND DRIVERID >0 THEN 1 ELSE 0 END) SUCC_FLAG
				  FROM PDW.DW_ORDER
				) A
			LEFT OUTER JOIN
			(
			SELECT ORDERID,
				   STATUS
			  FROM PDW.WX_DIDI_TRANSACTION
			  WHERE TRANS_TYPE = 1 AND STATUS = 1
			) B
			ON(A.ORDERID=B.ORDERID)
			LEFT OUTER JOIN
			(
				SELECT PASSENGERID,COUNT(PASSENGERID) CNT 
               FROM PDW.WX_DIDI_TRANSACTION 
			   WHERE TRANS_TYPE = 1 AND STATUS=1 
			   AND YEAR='$V_PARYEAR' 
			   AND  MONTH='$V_PARMONTH'  
			   AND  DAY='$V_PARDAY'  
			   GROUP BY PASSENGERID
			) C
			ON A.PASSENGERID = C.PASSENGERID
			GROUP BY AREA
			GROUPING SETS(AREA,())
	    ) W
) TWEB
LEFT OUTER JOIN 
(
SELECT (CASE WHEN AREA IS NULL THEN 10000 ELSE CAST(AREA AS INT) END) AREA,
        NATIVE_CNT,
		NATIVE_SUCCCNT,
		NATIVE_WECHAT_SUCCCNT,
		NATIVE_WECHAT_T_CNT,
		NATIVE_WECHAT_B_SUCCCNT	
  FROM (SELECT AREA,
			   COUNT(DISTINCT (CASE WHEN B.CREATETIME>='$V_YESTERDAY' AND B.CREATETIME <'$V_DATE' 
							THEN B.PASSENGERID ELSE 0 END))-1 NATIVE_CNT,
			   COUNT(DISTINCT (CASE WHEN B.CREATETIME>='$V_YESTERDAY' AND B.CREATETIME <'$V_DATE' AND B.SUCC_FLAG = 1 
							THEN B.PASSENGERID ELSE 0 END))-1 NATIVE_SUCCCNT,	  
				 COUNT(DISTINCT (CASE WHEN B.CREATETIME>='$V_YESTERDAY' AND B.CREATETIME <'$V_DATE' AND B.SUCC_FLAG = 1 AND C.ORDERID IS NOT NULL
							THEN B.PASSENGERID ELSE 0 END))-1 NATIVE_WECHAT_SUCCCNT,	 
			   COUNT(DISTINCT (CASE WHEN B.CREATETIME <'$V_DATE' AND B.SUCC_FLAG = 1  AND C.ORDERID IS NOT NULL THEN B.PASSENGERID ELSE 0 END))-1 NATIVE_WECHAT_T_CNT,	
			   COUNT(DISTINCT (CASE WHEN B.CREATETIME <'$V_YESTERDAY' AND B.SUCC_FLAG = 1  AND C.ORDERID IS NOT NULL THEN B.PASSENGERID ELSE 0 END))-1 NATIVE_WECHAT_B_SUCCCNT	
			   
		  FROM (SELECT PID
				  FROM PDW.STAT_PASSENGER
				 WHERE YEAR='$V_PARYEAR'
				   AND MONTH='$V_PARMONTH'
				   AND DAY='$V_PARDAY'
				   AND APP_VERSION >='2.6'
				) A
				JOIN
			   (SELECT ORDERID,
					   AREA,
					   PASSENGERID,
					   CREATETIME,
					   (CASE WHEN STATUS >=1 AND STATUS<=4 AND DRIVERID >0 THEN 1 ELSE 0 END) SUCC_FLAG
				  FROM PDW.DW_ORDER
				)  B
				ON (A.PID= B.PASSENGERID)
				LEFT OUTER JOIN
				(
				SELECT ORDERID,
					   STATUS
				  FROM PDW.WX_DIDI_TRANSACTION
				  WHERE TRANS_TYPE = 1 AND STATUS = 1
				) C
				ON(B.ORDERID=C.ORDERID)
				GROUP BY AREA
				GROUPING SETS(AREA,())
			) W
) TNATIVE
ON (TWEB.AREA = TNATIVE.AREA )
LEFT OUTER JOIN 
(
SELECT W.AREA,W.NATIVE_UP_CNT ALLCNT,Q.NATIVE_UP_CNT	BEFORECNT
  FROM (
  			SELECT (CASE WHEN AREA IS NULL THEN 10000 ELSE CAST(AREA AS INT) END) AREA,
			   COUNT(*) NATIVE_UP_CNT
		  FROM (SELECT PID
				  FROM PDW.STAT_PASSENGER
				 WHERE YEAR='$V_PARYEAR'
				   AND MONTH='$V_PARMONTH'
				   AND DAY='$V_PARDAY'
				   AND APP_VERSION >='2.6'
				) A
				JOIN
			   (SELECT  AREA,
					   PID
				  FROM PDW.PASSENGER
				  WHERE YEAR='$V_PARYEAR'
				   AND MONTH='$V_PARMONTH'
				   AND DAY='$V_PARDAY'
				)  B
				ON (A.PID= B.PID)
				GROUP BY AREA
				GROUPING SETS(AREA,())
			) W
			LEFT OUTER JOIN
			(	
				 SELECT (CASE WHEN AREA IS NULL THEN 10000 ELSE CAST(AREA AS INT) END) AREA,
			   COUNT(*) NATIVE_UP_CNT
		  FROM (SELECT PID
				  FROM PDW.STAT_PASSENGER
				 WHERE CONCAT(YEAR,MONTH,DAY)='$V_PAR2DAYS'
				   AND APP_VERSION >='2.6'
				) A
				JOIN
			   (SELECT  AREA,
					   PID
				  FROM PDW.PASSENGER
				  WHERE CONCAT(YEAR,MONTH,DAY)='$V_PAR2DAYS'
				)  B
				ON (A.PID= B.PID)
				GROUP BY AREA
				GROUPING SETS(AREA,())
			) Q
			ON W.AREA = Q.AREA
) TVERSION

ON (TNATIVE.AREA = TVERSION.AREA)

LEFT OUTER JOIN 
(
	SELECT  (CASE WHEN AREA IS NULL THEN 10000 ELSE CAST(AREA AS INT) END) AREA,
	  SUM(CASE WHEN  W.CNT = 1 THEN 1 ELSE 0  END) TOTAL1 , 
		SUM(CASE WHEN  W.CNT >= 2 THEN 1 ELSE 0 END) TOTAL2 ,
		(CASE WHEN SUM(CASE WHEN  W.CNT >= 2 THEN 1 ELSE 0 END) <>0 
				THEN ROUND(SUM(CASE WHEN  W.CNT >= 2 THEN W.CNT ELSE CAST(0 AS BIGINT) END)/SUM(CASE WHEN  W.CNT >= 2 THEN 1 ELSE 0 END),3) ELSE 0.00 END) TOTAL3
  FROM 
(
SELECT AREA,
	   PASSENGERID,
	   COUNT(DISTINCT A.ORDERID) CNT
 FROM
(
SELECT AREA,
	   PASSENGERID,
	   ORDERID
  FROM PDW.DW_ORDER
 WHERE YEAR='$V_PARYEAR'
   AND MONTH='$V_PARMONTH'
   AND DAY='$V_PARDAY'
   AND STATUS >=1
   AND STATUS <=4
   AND DRIVERID >0
) A
JOIN
(
SELECT ORDERID
  FROM PDW.WX_DIDI_TRANSACTION
 WHERE YEAR='$V_PARYEAR'
   AND MONTH='$V_PARMONTH'
   AND DAY='$V_PARDAY'
   AND STATUS = 1
 ) B
 ON(A.ORDERID=B.ORDERID)
 GROUP BY AREA,PASSENGERID
) W
GROUP BY AREA
GROUPING SETS (AREA,())
) TWECHAT
ON (TNATIVE.AREA = TWECHAT.AREA)
;"
/home/xiaoju/hadoop-1.0.4/bin/hadoop fs -touchz /user/xiaoju/data/bi/app/wechat_passenger/$V_PARYEAR/$V_PARMONTH/$V_PARDAY/_SUCCESS