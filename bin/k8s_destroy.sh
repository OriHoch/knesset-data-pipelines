#!/usr/bin/env bash

source bin/k8s_connect.sh

if [ "${K8S_ENVIRONMENT}" != "staging" ]; then
    echo " > only staging environment is supported"
    exit 1
fi

echo " > deleting staging cluster"
read -p "Are you sure you want to continue? [y/N]: "
if [ "${REPLY}" == "y" ]; then
    gcloud container clusters delete $CLOUDSDK_CONTAINER_CLUSTER
fi

echo " > deleting staging persistent disks"
read -p "Are you sure you want to continue? [y/N]: "
if [ "${REPLY}" == "y" ]; then
    gcloud compute disks delete "knesset-data-pipelines-${K8S_ENVIRONMENT}-db"
    gcloud compute disks delete "knesset-data-pipelines-${K8S_ENVIRONMENT}-app"
fi

echo " > deleting devops/k8s/.env.${K8S_ENVIRONMENT}"
read -p "Are you sure you want to continue? [y/N]: "
if [ "${REPLY}" == "y" ]; then
    rm "devops/k8s/.env.${K8S_ENVIRONMENT}"
fi

echo " > done"
echo " > please review google console for any remaining billable services!"
