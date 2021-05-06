#!/bin/bash
DBINST=$1
BUCKET=$2

gcloud -v 2>&1 /dev/null
if [ $? != 0 ]; then
  echo "gcloud is not present or not available in $PATH. Skipping ACL setup."
  exit 0
fi

if [[ -z "${DBINST}" || -z "${BUCKET}" ]]; then
  echo "One or more parameters were not provided. Usage:"
  echo "$0 DB_INSTANCE_NAME BACKUP_BUCKET_NAME"
  exit 1
fi

gsutil acl ch -u  $(gcloud sql instances describe ${DBINST} --format="value(serviceAccountEmailAddress)"):READER gs://${BUCKET}
gsutil acl ch -u  $(gcloud sql instances describe ${DBINST} --format="value(serviceAccountEmailAddress)"):WRITER gs://${BUCKET}
gsutil acl ch -r -u  $(gcloud sql instances describe ${DBINST} --format="value(serviceAccountEmailAddress)"):READER gs://${BUCKET}/ || true