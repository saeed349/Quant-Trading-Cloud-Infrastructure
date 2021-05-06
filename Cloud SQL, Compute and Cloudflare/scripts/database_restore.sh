#!/bin/bash
DBINST=$1
DBNAME=$2
BUCKET=$3
LOCK="/tmp/.${DBINST}_restore"

gcloud -v 2>&1 > /dev/null
if [ $? != 0 ]; then
  echo "gcloud is not present or not available in $PATH. Skipping restore."
  exit 0
fi

if [[ -z "${DBINST}" || -z "${DBNAME}" || -z "${BUCKET}" ]]; then
  echo "One or more parameters were not provided. Usage:"
  echo "$0 DB_INSTANCE_NAME DB_NAME BUCKET_NAME"
  exit 1
elif [[ ! -z "${4}" ]]; then
  echo "Exactly 3 parameteres are required. Usage:"
  echo "$0 DB_INSTANCE_NAME DB_NAME BUCKET_NAME"
  exit 1
fi

while [[ -f ${LOCK}  ]]; do
  echo "Waiting for another restore to finish"
  sleep 3
done
> ${LOCK}
echo "Restoring ${DBINST}/${DBNAME} from ${BUCKET}"

echo "Y" | gcloud sql import sql ${DBINST} gs://${BUCKET}/${DBNAME}.sql.gz -d ${DBNAME} 2>${LOCK}
EXIT=$?

while [[ ${EXIT} != 0 ]]; do
  echo "Waiting to retry operation..."
  sleep 5
  echo "Y" | gcloud sql import sql ${DBINST} gs://${BUCKET}/${DBNAME}.sql.gz -d ${DBNAME} 2>${LOCK}
  EXIT=$?
done

sleep 5
rm -f ${LOCK}
exit ${EXIT}