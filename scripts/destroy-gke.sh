#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# JERNEY - GKE DEMO DESTROY SCRIPT
#
# IMPORTANT:
# - Deletes the GKE cluster
# - Deletes everything managed inside that cluster
# - GCP Load Balancer resources will be cleaned up with Ingress
# - PRESERVES the reserved global static IP
#
# Run from repo root:
#
#   ./scripts/destroy-gke.sh
#
# ============================================================

PROJECT_ID="project-6d23e38d-7a71-4133-9e3"
CLUSTER_NAME="jerney"
REGION="us-east1"
STATIC_IP_NAME="jerney-ingress-ip"

echo
echo "============================================================"
echo "          JERNEY GKE DESTROY"
echo "============================================================"
echo
echo "Project     : ${PROJECT_ID}"
echo "Cluster     : ${CLUSTER_NAME}"
echo "Region      : ${REGION}"
echo "Static IP   : ${STATIC_IP_NAME}"
echo
echo "⚠️ This will DELETE the GKE cluster and its workloads."
echo "✅ The reserved static IP will NOT be deleted."
echo

read -r -p "Type DELETE to continue: " CONFIRM

if [[ "${CONFIRM}" != "DELETE" ]]; then
    echo
    echo "Aborted."
    exit 0
fi

echo
echo "============================================================"
echo "Checking static IP"
echo "============================================================"
echo

if gcloud compute addresses describe "${STATIC_IP_NAME}" \
    --global \
    --project="${PROJECT_ID}" \
    >/dev/null 2>&1; then

    STATIC_IP="$(
        gcloud compute addresses describe "${STATIC_IP_NAME}" \
            --global \
            --project="${PROJECT_ID}" \
            --format="get(address)"
    )"

    echo "✅ Reserved static IP found:"
    echo
    echo "${STATIC_IP}"

else

    echo "⚠️ Static IP ${STATIC_IP_NAME} does not exist."

    STATIC_IP=""

fi

echo
echo "============================================================"
echo "Checking GKE cluster"
echo "============================================================"
echo

if ! gcloud container clusters describe "${CLUSTER_NAME}" \
    --region="${REGION}" \
    --project="${PROJECT_ID}" \
    >/dev/null 2>&1; then

    echo "GKE cluster does not exist."
    echo "Nothing to destroy."

else

    echo "GKE cluster found."
    echo
    gcloud container clusters describe "${CLUSTER_NAME}" \
        --region="${REGION}" \
        --project="${PROJECT_ID}" \
        --format="yaml(name,status,currentMasterVersion,currentNodeCount)"

    echo
    echo "============================================================"
    echo "Deleting GKE cluster"
    echo "============================================================"
    echo

    gcloud container clusters delete "${CLUSTER_NAME}" \
        --region="${REGION}" \
        --project="${PROJECT_ID}" \
        --quiet

    echo
    echo "✅ GKE cluster deleted."

fi

echo
echo "============================================================"
echo "Verifying cluster deletion"
echo "============================================================"
echo

if gcloud container clusters describe "${CLUSTER_NAME}" \
    --region="${REGION}" \
    --project="${PROJECT_ID}" \
    >/dev/null 2>&1; then

    echo "❌ Cluster still exists."
    exit 1

else

    echo "✅ Cluster ${CLUSTER_NAME} no longer exists."

fi

echo
echo "============================================================"
echo "Verifying static IP"
echo "============================================================"
echo

if [ -n "${STATIC_IP}" ]; then

    CURRENT_IP="$(
        gcloud compute addresses describe "${STATIC_IP_NAME}" \
            --global \
            --project="${PROJECT_ID}" \
            --format="get(address)"
    )"

    IP_STATUS="$(
        gcloud compute addresses describe "${STATIC_IP_NAME}" \
            --global \
            --project="${PROJECT_ID}" \
            --format="get(status)"
    )"

    echo "Static IP name : ${STATIC_IP_NAME}"
    echo "Static IP      : ${CURRENT_IP}"
    echo "Status         : ${IP_STATUS}"

    if [[ "${CURRENT_IP}" == "${STATIC_IP}" ]]; then
        echo
        echo "✅ Static IP preserved."
    else
        echo
        echo "❌ Static IP changed unexpectedly."
        exit 1
    fi

else

    echo "No static IP was found before destruction."

fi

echo
echo "============================================================"
echo "Checking remaining global forwarding rules"
echo "============================================================"
echo

gcloud compute forwarding-rules list \
    --global \
    --project="${PROJECT_ID}" \
    --format="table(name,IPAddress,target)" \
    || true

echo
echo "============================================================"
echo "              DESTROY COMPLETE"
echo "============================================================"
echo

echo "GKE cluster : DELETED"

if [ -n "${STATIC_IP}" ]; then
    echo "Static IP   : PRESERVED"
    echo "IP address  : ${STATIC_IP}"
fi

echo
echo "Next step:"
echo
echo "    ./scripts/deploy-gke.sh"
echo
echo "The deployment script should reuse:"
echo
echo "    ${STATIC_IP}"
echo
echo "============================================================"