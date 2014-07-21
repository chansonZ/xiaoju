#!/bin/bash

etcfile="etc/mysql.conf.gulfstream_pay1"

masterdb_ip=`egrep mysql_masterdb_ip ${etcfile}`
masterdb_ip=`echo ${masterdb_ip##*=}|tr -d " "`

masterdb_port=`egrep mysql_masterdb_port ${etcfile}`
masterdb_port=`echo ${masterdb_port##*=}|tr -d " "`

app_dbname=`egrep app_dbname ${etcfile}`
app_dbname=`echo ${app_dbname##*=}|tr -d " "`
app_dbname="didiaudit"

db_username=`egrep db_username ${etcfile}`
db_username=`echo ${db_username##*=}|tr -d " "`

db_password=`egrep db_password ${etcfile}`
db_password=`echo ${db_password##*=}|tr -d " "`

if [ $# -eq 0 ];then
    v_executeDate=`date -d "-1day" +%Y-%m-%d`
else
    echo $1 |grep -e '^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}$' >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo "date format illege! eg:2013-12-12"
        exit 1
    else
        v_executeDate=$1
    fi  
fi

source ../sqoopjobs-env.sh
SQOOP=${SQOOP:-"/data/xiaoju/sqoop-1.4.4_hadoop-0.23/bin/sqoop"}
GULFSTREAM_COMMON_PATH=${GULFSTREAM_COMMON_PATH:-"/user/xiaoju/data/bi/gulfstream/"}
GULFSTREAM_COMPRESS_OPTS=${GULFSTREAM_COMPRESS_OPTS:-"--as-textfile"}
SQOOP_COMMON_OPTS=${SQOOP_COMMON_OPTS:-""}

echo "Connection to ${masterdb_ip}:${masterdb_port}?${app_dbname}&username=${db_username}&password=${db_password}"
echo executeDate:"$v_executeDate"

y=`date -d "$v_executeDate" +%Y`
m=`date -d "$v_executeDate" +%m`
d=`date -d "$v_executeDate" +%d`

TABLE="audit_display_part"
QUERY="SELECT \
partid,\
auditid,\
issue_type,\
REPLACE(REPLACE(REPLACE(issue_desc,'\r',''),'\n',''),'||','') AS issue_desc,\
DATE_FORMAT(checked_time,'%Y-%m-%d %H:%i:%s') AS checked_time,\
is_checked,\
result,\
REPLACE(REPLACE(REPLACE(didibillid,'\r',''),'\n',''),'||','') AS didibillid,\
channel,\
REPLACE(REPLACE(REPLACE(channel_name,'\r',''),'\n',''),'||','') AS channel_name,\
REPLACE(REPLACE(REPLACE(partner_id,'\r',''),'\n',''),'||','') AS partner_id,\
billid,\
bill_type,\
REPLACE(REPLACE(REPLACE(userid,'\r',''),'\n',''),'||','') AS userid,\
user_type,\
REPLACE(REPLACE(REPLACE(user_name,'\r',''),'\n',''),'||','') AS user_name,\
REPLACE(REPLACE(REPLACE(user_phone,'\r',''),'\n',''),'||','') AS user_phone,\
DATE_FORMAT(create_time,'%Y-%m-%d %H:%i:%s') AS create_time,\
DATE_FORMAT(update_time,'%Y-%m-%d %H:%i:%s') AS update_time,\
DATE_FORMAT(_create_time,'%Y-%m-%d %H:%i:%s') AS _create_time,\
DATE_FORMAT(_modify_time,'%Y-%m-%d %H:%i:%s') AS _modify_time,\
_status \
FROM audit_display_part WHERE _create_time BETWEEN '$v_executeDate 00:00:00' AND '$v_executeDate 23:59:59' AND \$CONDITIONS"

if [ -z ${TABLE} ]; then
    echo $\{TABLE\} is NULL
    exit 1
fi

$SQOOP import -D mapred.job.name="${v_executeDate}.$(basename $0)" \
    --connect "jdbc:mysql://${masterdb_ip}:${masterdb_port}/${app_dbname}?zeroDateTimeBehavior=convertToNull" \
    --username ${db_username} --password ${db_password} --query "$QUERY" \
    -m 1 --fields-terminated-by '\001' --null-string '' --null-non-string '' \
    --delete-target-dir ${GULFSTREAM_COMPRESS_OPTS} ${SQOOP_COMMON_OPTS} \
    --target-dir "${GULFSTREAM_COMMON_PATH%%/}/${TABLE}/$y/$m/$d/"