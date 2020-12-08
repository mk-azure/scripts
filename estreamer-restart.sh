#!/bin/bash
#
# Script for estreamer workaround
#
LOGFILE=/apps/splunk-forwarder/splunk/etc/apps/TA-eStreamer/bin/encore/estreamer.log
PIDFILE=/apps/splunk-forwarder/splunk/etc/apps/TA-eStreamer/data/10.20.178.27-8302_proc.pid
PS_STRING=estreamer
SPLUNK_CMD=/apps/splunk-forwarder/splunk/bin/splunk
TS_LOG=/apps/splunk-forwarder/splunk/etc/apps/TA-eStreamer/ts.log

touch ${TS_LOG}
LAST_ERR_TS="$(cat ${TS_LOG})"
LATEST_ERR_TS="$(grep 'ERROR.*PID file already exists' ${LOGFILE} | tail -1 | awk '{print $1,$2}')"

if [ "$LATEST_ERR_TS" == "$LAST_ERR_TS" ]
then
    echo "No error noticed in current script execution"
else
  echo ${LATEST_ERR_TS} > ${TS_LOG}
  rm -f ${PIDFILE}
  ps -ef | grep -i ${PS_STRING} | grep -v grep | xargs kill
  ps -ef | grep -i ${PS_STRING} | grep -v grep | while read pid; do kill -9 ${pid} > /dev/null 2>&1; done
  ${SPLUNK_CMD} restart
fi 
