#!/bin/sh
clspath=".:${HADOOP_HOME}/etc/hadoop"

HADOOP_COMMON_DIR=${HADOOP_COMMON_DIR:-"share/hadoop/common"}
HADOOP_COMMON_LIB_JARS_DIR=${HADOOP_COMMON_LIB_JARS_DIR:-"share/hadoop/common/lib"}
for f in $HADOOP_HOME/$HADOOP_COMMON_DIR/*.jar; do
	clspath=${clspath}:$f;
done

for f in $HADOOP_HOME/$HADOOP_COMMON_LIB_JARS_DIR/*.jar; do
	clspath=${clspath}:$f;
done

HDFS_DIR=${HDFS_DIR:-"share/hadoop/hdfs"}
HDFS_LIB_JARS_DIR=${HDFS_LIB_JARS_DIR:-"share/hadoop/hdfs/lib"}
for f in $HADOOP_HOME/$HDFS_DIR/*.jar; do
	clspath=${clspath}:$f;
done

for f in $HADOOP_HOME/$HDFS_LIB_JARS_DIR/*.jar; do
	clspath=${clspath}:$f;
done

YARN_DIR=${YARN_DIR:-"share/hadoop/yarn"}
YARN_LIB_JARS_DIR=${YARN_LIB_JARS_DIR:-"share/hadoop/yarn/lib"}
for f in $HADOOP_HOME/$YARN_DIR/*.jar; do
	clspath=${clspath}:$f;
done

for f in $HADOOP_HOME/$YARN_LIB_JARS_DIR/*.jar; do
	clspath=${clspath}:$f;
done

MAPRED_DIR=${MAPRED_DIR:-"share/hadoop/mapreduce"}
MAPRED_LIB_JARS_DIR=${MAPRED_LIB_JARS_DIR:-"share/hadoop/mapreduce/lib"}
for f in $HADOOP_HOME/$MAPRED_DIR/*.jar; do
	clspath=${clspath}:$f;
done

for f in $HADOOP_HOME/$MAPRED_LIB_JARS_DIR/*.jar; do
	clspath=${clspath}:$f;
done

if [ $# -eq 0 ];then
    java -Xms1024m -Xmx1024m -XX:MaxPermSize=256m -classpath "${clspath}" org.apache.hadoop.mapred.HdpJobClient | sort
    exit
fi

if [[ $1 = "HdpJobClient.java" ]];then
    javac -d . -classpath "${clspath}" $1
    exit
fi

java -Xms1024m -Xmx1024m -XX:MaxPermSize=256m -classpath "${clspath}" org.apache.hadoop.mapred.HdpJobClient $1
