#!/bin/bash
etcfile="./etc/mysql.conf"

masterdb_ip=`egrep mysql_masterdb_ip ${etcfile}`
masterdb_ip=`echo ${masterdb_ip##*=}|tr -d " "`

masterdb_port=`egrep mysql_masterdb_port ${etcfile}`
masterdb_port=`echo ${masterdb_port##*=}|tr -d " "`

app_dbname=`egrep app_dbname ${etcfile}`
app_dbname=`echo ${app_dbname##*=}|tr -d " "`

db_username=`egrep db_username ${etcfile}`
db_username=`echo ${db_username##*=}|tr -d " "`

db_password=`egrep db_password ${etcfile}`
db_password=`echo ${db_password##*=}|tr -d " "`

if [ -z ${masterdb_ip} ];then
    masterdb_ip="hdp998.jx"
fi

if [ -z ${masterdb_port} ];then
    masterdb_port="3366"
fi

if [ -z ${app_dbname} ];then
    app_dbname="app_dididache"
fi

if [ -z ${db_username} ];then
    db_username="app_r"
fi

if [ -z ${db_password} ];then
    db_password="app_r"
fi

echo "Connection to ${masterdb_ip}:${masterdb_port}?${app_dbname}&username=${db_username}&password=${db_password}"

v_currentDate=`date +%Y-%m-%d`
v_paramDate=$1
v_executeDate=""
if [ -z "$v_paramDate" ];then
	v_executeDate=`date --date="$v_currentDate-1 day" +%Y-%m-%d`
else
	flag=`echo $v_paramDate|grep -e '^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}$'`	
	if [ -z "$flag" ];then
		echo "date format is illege! please rewrite!eg:2013-12-12"
		exit 0
	else
		v_executeDate="$v_paramDate"
	fi
fi
echo executeDate:"$v_executeDate"

year=`date --date="$v_executeDate" +%Y`
month=`date --date="$v_executeDate" +%m`
day=`date --date="$v_executeDate" +%d`

mysql_exec()
{
        /home/xiaoju/mysql-client/bin/mysql -h${masterdb_ip} -u${db_username} -p${db_password} -P${masterdb_port} ${app_dbname} -e "$@"
}
# 检查最后一条记录的时间
title="Order max( CreateTime )"
carbon=lihan@diditaxi.com.cn
reciver=lihan@diditaxi.com.cn
sql="SELECT MAX( createTime ) AS Order_MaxCreateTime FROM \`Order\` WHERE createTime BETWEEN '${v_executeDate} 00:00:00' AND '${v_executeDate} 23:59:59';"
mysql_exec "$sql" | mutt -s "${title}" -c "${carbon}" "${reciver}"
#mysql_exec "$sql"
# add %Y-%m-%d %H:%i:%s
sqoop import -D mapred.job.name='order_sqoop_import' --connect "jdbc:mysql://${masterdb_ip}:${masterdb_port}/${app_dbname}?zeroDateTimeBehavior=convertToNull" --username ${db_username} --password ${db_password} --query "SELECT orderid,passengerid,token,driverId,STATUS,TYPE,lng,lat,replace(replace(replace(address,'\r',''),'\n',''),'|','') as address,replace(replace(replace(destination,'\r',''),'\n',''),'|','') as destination,DATE_FORMAT(setuptime,'%Y-%m-%d %H:%i:%s') AS setuptime,tip,EXP,waittime,callCount,distance,LENGTH,replace(replace(replace(verifyMessage,'\r',''),'\n',''),'|','') as verifyMessage,DATE_FORMAT(createTime,'%Y-%m-%d %H:%i:%s') AS createTime,DATE_FORMAT(striveTime,'%Y-%m-%d %H:%i:%s') AS striveTime,DATE_FORMAT(arriveTime,'%Y-%m-%d %H:%i:%s') AS arriveTime,DATE_FORMAT(aboardTime,'%Y-%m-%d %H:%i:%s') AS aboardTime,DATE_FORMAT(canceltime,'%Y-%m-%d %H:%i:%s') AS cancelTime,pCommentGread,replace(replace(replace(pCommentText,'\r',''),'\n',''),'|','') as pCommentText,DATE_FORMAT(pCommentTime,'%Y-%m-%d %H:%i:%s') AS pCommentTime,pCommentStatus,dCommentGread,replace(replace(replace(dcommenttext,'\r',''),'\n',''),'|','') as dcommenttext,DATE_FORMAT(dCommentTime,'%Y-%m-%d %H:%i:%s') AS dCommentTime,dCommentStatus,channel,AREA,VERSION,replace(replace(replace(remark,'\r',''),'\n',''),'|','') as remark,bonus,voicelength,voiceTime  FROM \`Order\` where createTime between '${v_executeDate} 00:00:00' and '${v_executeDate} 23:59:59' and \$CONDITIONS " --delete-target-dir --split-by orderid -m 1 --fields-terminated-by '\001' --null-string '' --null-non-string '' --as-textfile --target-dir /user/xiaoju/data/bi/mysql/order/${year}/${month}/${day}/
