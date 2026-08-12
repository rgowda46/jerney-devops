#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# JERNEY - GKE DEMO DEPLOYMENT
#
# Recreates the known-good GKE environment.
#
# Run from Cloud Shell:
#
#   cd ~/jerney-devops
#   git checkout gcp/gke
#   git pull origin gcp/gke
#   chmod +x scripts/deploy-gke.sh
#   ./scripts/deploy-gke.sh
#
# ============================================================

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

PROJECT_ID="project-6d23e38d-7a71-4133-9e3"
CLUSTER_NAME="jerney"
REGION="us-east1"

STATIC_IP_NAME="jerney-ingress-ip"

NAMESPACE="jerney"
DOMAIN="jerney.rohith-gowda.online"

# ------------------------------------------------------------
# Resolve repository paths
# ------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
K8S_DIR="${REPO_ROOT}/k8s/gke"

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

log() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

fail() {
    echo
    echo "❌ ERROR: $1"
    exit 1
}

cleanup_on_error() {
    echo
    echo "❌ Deployment failed."
    echo
    echo "Useful diagnostics:"
    echo
    echo "kubectl get pods -n ${NAMESPACE}"
    echo "kubectl get svc -n ${NAMESPACE}"
    echo "kubectl get ingress -n ${NAMESPACE}"
    echo "kubectl get managedcertificate -n ${NAMESPACE}"
    echo
}

trap cleanup_on_error ERR

# ------------------------------------------------------------
# Validate commands
# ------------------------------------------------------------

command -v gcloud >/dev/null 2>&1 \
    || fail "gcloud is not installed."

command -v kubectl >/dev/null 2>&1 \
    || fail "kubectl is not installed."

command -v curl >/dev/null 2>&1 \
    || fail "curl is not installed."

[ -d "${K8S_DIR}" ] \
    || fail "Kubernetes directory not found: ${K8S_DIR}"

# ------------------------------------------------------------
# Display configuration
# ------------------------------------------------------------

log "Jerney GKE Demo Deployment"

echo "Project       : ${PROJECT_ID}"
echo "Cluster       : ${CLUSTER_NAME}"
echo "Region        : ${REGION}"
echo "Static IP     : ${STATIC_IP_NAME}"
echo "Namespace     : ${NAMESPACE}"
echo "Domain        : ${DOMAIN}"
echo "K8s manifests : ${K8S_DIR}"

# ------------------------------------------------------------
# Configure GCP project
# ------------------------------------------------------------

log "Configuring GCP project"

gcloud config set project "${PROJECT_ID}"

# ------------------------------------------------------------
# Enable required APIs
# ------------------------------------------------------------

log "Enabling required Google Cloud APIs"

gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    --project="${PROJECT_ID}"

# ------------------------------------------------------------
# Reserve / reuse global static IP
# ------------------------------------------------------------

log "Checking global static IP"

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

    echo "Existing static IP: ${STATIC_IP}"

else

    echo "Creating global static IP..."

    gcloud compute addresses create "${STATIC_IP_NAME}" \
        --global \
        --ip-version=IPV4 \
        --project="${PROJECT_ID}"

    STATIC_IP="$(
        gcloud compute addresses describe "${STATIC_IP_NAME}" \
            --global \
            --project="${PROJECT_ID}" \
            --format="get(address)"
    )"

    echo "Created static IP: ${STATIC_IP}"

fi

# ------------------------------------------------------------
# Create GKE cluster using the EXACT known-good configuration
# ------------------------------------------------------------

log "Checking GKE cluster"

if gcloud container clusters describe "${CLUSTER_NAME}" \
    --region="${REGION}" \
    --project="${PROJECT_ID}" \
    >/dev/null 2>&1; then

    echo "GKE cluster already exists."
    echo "Skipping cluster creation."

else

    log "Creating GKE cluster"

    gcloud beta container \
        --project "${PROJECT_ID}" \
        clusters create "${CLUSTER_NAME}" \
        --region "${REGION}" \
        --no-enable-basic-auth \
        --cluster-version "1.35.6-gke.1258000" \
        --release-channel "regular" \
        --machine-type "e2-medium" \
        --image-type "COS_CONTAINERD" \
        --disk-type "pd-standard" \
        --disk-size "100" \
        --metadata "disable-legacy-endpoints=true" \
        --service-account "default" \
        --scopes "https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append" \
        --max-pods-per-node "110" \
        --num-nodes "1" \
        --logging "SYSTEM,WORKLOAD" \
        --monitoring "SYSTEM,STORAGE,HPA,POD,DAEMONSET,DEPLOYMENT,STATEFULSET,CADVISOR,KUBELET,DCGM,JOBSET" \
        --enable-ip-alias \
        --network "projects/${PROJECT_ID}/global/networks/default" \
        --subnetwork "projects/${PROJECT_ID}/regions/${REGION}/subnetworks/default" \
        --no-enable-intra-node-visibility \
        --default-max-pods-per-node "110" \
        --enable-ip-access \
        --security-posture="standard" \
        --workload-vulnerability-scanning=disabled \
        --no-enable-google-cloud-access \
        --addons "HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS,GcePersistentDiskCsiDriver" \
        --enable-autoupgrade \
        --enable-autorepair \
        --max-surge-upgrade "1" \
        --max-unavailable-upgrade "0" \
        --binauthz-evaluation-mode=DISABLED \
        --enable-managed-prometheus \
        --enable-shielded-nodes \
        --shielded-integrity-monitoring \
        --no-shielded-secure-boot \
        --node-locations "us-east1-d,us-east1-c,us-east1-b"

fi

# ------------------------------------------------------------
# Get Kubernetes credentials
# ------------------------------------------------------------

log "Getting GKE credentials"

gcloud container clusters get-credentials "${CLUSTER_NAME}" \
    --region="${REGION}" \
    --project="${PROJECT_ID}"

# ------------------------------------------------------------
# Verify nodes
# ------------------------------------------------------------

log "Checking GKE nodes"

kubectl get nodes

# ------------------------------------------------------------
# Namespace
# ------------------------------------------------------------

log "Applying namespace"

kubectl apply \
    -f "${K8S_DIR}/namespace.yaml"

# ------------------------------------------------------------
# Secret
# ------------------------------------------------------------

log "Applying database secret"

kubectl apply \
    -f "${K8S_DIR}/secrets.yaml"

# ------------------------------------------------------------
# PostgreSQL PVC
# ------------------------------------------------------------

log "Applying PostgreSQL persistent volume claim"

kubectl apply \
    -f "${K8S_DIR}/postgres-pvc.yaml"

# ------------------------------------------------------------
# PostgreSQL Service
# ------------------------------------------------------------

log "Applying PostgreSQL service"

kubectl apply \
    -f "${K8S_DIR}/postgres-service.yaml"

# ------------------------------------------------------------
# PostgreSQL Deployment
# ------------------------------------------------------------

log "Deploying PostgreSQL"

kubectl apply \
    -f "${K8S_DIR}/postgres-deployment.yaml"

# ------------------------------------------------------------
# Wait for PostgreSQL
# ------------------------------------------------------------

log "Waiting for PostgreSQL"

kubectl rollout status \
    deployment/jerney-db \
    -n "${NAMESPACE}" \
    --timeout=5m

# ------------------------------------------------------------
# PostgreSQL verification
# ------------------------------------------------------------

kubectl get pods \
    -n "${NAMESPACE}" \
    -l app.kubernetes.io/name=jerney-db \
    -o wide

kubectl get pvc \
    -n "${NAMESPACE}"

# ------------------------------------------------------------
# Network Policy
# ------------------------------------------------------------

if [ -f "${K8S_DIR}/network-policy.yaml" ]; then

    log "Applying network policies"

    kubectl apply \
        -f "${K8S_DIR}/network-policy.yaml"

fi

# ------------------------------------------------------------
# Backend Service
# ------------------------------------------------------------

log "Applying backend service"

kubectl apply \
    -f "${K8S_DIR}/backend-service.yaml"

# ------------------------------------------------------------
# Backend Deployment
# ------------------------------------------------------------

log "Deploying backend"

kubectl apply \
    -f "${K8S_DIR}/backend-deployment.yaml"

kubectl rollout status \
    deployment/jerney-backend \
    -n "${NAMESPACE}" \
    --timeout=5m

# ------------------------------------------------------------
# Frontend Service
# ------------------------------------------------------------

log "Applying frontend service"

kubectl apply \
    -f "${K8S_DIR}/frontend-service.yaml"

# ------------------------------------------------------------
# Frontend Deployment
# ------------------------------------------------------------

log "Deploying frontend"

kubectl apply \
    -f "${K8S_DIR}/frontend-deployment.yaml"

kubectl rollout status \
    deployment/jerney-frontend \
    -n "${NAMESPACE}" \
    --timeout=5m

# ------------------------------------------------------------
# Application status
# ------------------------------------------------------------

log "Application status"

kubectl get pods \
    -n "${NAMESPACE}" \
    -o wide

echo

kubectl get svc \
    -n "${NAMESPACE}"

echo

kubectl get endpoints \
    -n "${NAMESPACE}"

# ------------------------------------------------------------
# Managed Certificate
# ------------------------------------------------------------

if [ -f "${K8S_DIR}/managed-certificate.yaml" ]; then

    log "Applying Google Managed Certificate"

    kubectl apply \
        -f "${K8S_DIR}/managed-certificate.yaml"

fi

# ------------------------------------------------------------
# Ingress
# ------------------------------------------------------------

log "Applying GKE Ingress"

kubectl apply \
    -f "${K8S_DIR}/ingress.yaml"

# ------------------------------------------------------------
# Wait for GKE Load Balancer
# ------------------------------------------------------------

log "Waiting for GKE Global Load Balancer"

INGRESS_IP=""

for i in {1..60}; do

    INGRESS_IP="$(
        kubectl get ingress jerney-ingress \
            -n "${NAMESPACE}" \
            -o jsonpath='{.status.loadBalancer.ingress[0].ip}' \
            2>/dev/null || true
    )"

    if [ -n "${INGRESS_IP}" ]; then
        break
    fi

    echo "Waiting for Load Balancer... ${i}/60"
    sleep 10

done

if [ -z "${INGRESS_IP}" ]; then

    echo
    echo "⚠️ Load Balancer IP is not available yet."
    echo "The controller may still be provisioning it."

else

    echo "Ingress IP: ${INGRESS_IP}"

fi

# ------------------------------------------------------------
# Verify static IP attachment
# ------------------------------------------------------------

if [ -n "${INGRESS_IP}" ]; then

    if [ "${INGRESS_IP}" = "${STATIC_IP}" ]; then

        echo "✔️ Ingress is using reserved static IP."

    else

        echo
        echo "⚠️ WARNING"
        echo "Reserved IP : ${STATIC_IP}"
        echo "Ingress IP  : ${INGRESS_IP}"
        echo
        echo "The Ingress IP does not match the reserved IP yet."

    fi

fi

# ------------------------------------------------------------
# Wait for Managed Certificate
#
# IMPORTANT:
# DNS must point DOMAIN -> STATIC_IP.
#
# Cloudflare:
# A
# jerney
# STATIC_IP
# Proxied
# ------------------------------------------------------------

log "Checking Google Managed Certificate"

CERT_STATUS="NotFound"

if kubectl get managedcertificate jerney-certificate \
    -n "${NAMESPACE}" \
    >/dev/null 2>&1; then

    for i in {1..30}; do

        CERT_STATUS="$(
            kubectl get managedcertificate jerney-certificate \
                -n "${NAMESPACE}" \
                -o jsonpath='{.status.certificateStatus}' \
                2>/dev/null || true
        )"

        echo "Certificate status: ${CERT_STATUS:-Provisioning}"

        if [ "${CERT_STATUS}" = "Active" ]; then
            break
        fi

        sleep 10

    done

fi

# ------------------------------------------------------------
# Final Kubernetes status
# ------------------------------------------------------------

log "Final Kubernetes status"

kubectl get pods \
    -n "${NAMESPACE}"

echo

kubectl get svc \
    -n "${NAMESPACE}"

echo

kubectl get ingress \
    -n "${NAMESPACE}"

echo

kubectl get managedcertificate \
    -n "${NAMESPACE}" \
    2>/dev/null || true

# ------------------------------------------------------------
# HTTPS test
# ------------------------------------------------------------

log "Testing public HTTPS endpoint"

HTTP_STATUS=""

HTTP_STATUS="$(
    curl \
        -L \
        -sS \
        -o /dev/null \
        -w "%{http_code}" \
        --connect-timeout 10 \
        --max-time 30 \
        "https://${DOMAIN}" \
        2>/dev/null || true
)"

if [ -z "${HTTP_STATUS}" ]; then
    HTTP_STATUS="FAILED"
fi

echo "HTTPS response: ${HTTP_STATUS}"

# ------------------------------------------------------------
# Final Terraform-style outputs
# ------------------------------------------------------------

echo
echo
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              JERNEY GKE DEPLOYMENT OUTPUTS                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo

echo "project_id       = ${PROJECT_ID}"
echo "cluster_name     = ${CLUSTER_NAME}"
echo "region           = ${REGION}"
echo "namespace        = ${NAMESPACE}"
echo "static_ip_name   = ${STATIC_IP_NAME}"
echo "static_ip        = ${STATIC_IP}"
echo "ingress_ip       = ${INGRESS_IP:-pending}"
echo "domain           = ${DOMAIN}"
echo "url              = https://${DOMAIN}"
echo "certificate      = ${CERT_STATUS}"
echo "https_status     = ${HTTP_STATUS}"

echo
echo "------------------------------------------------------------"
echo "CLOUDFLARE DNS"
echo "------------------------------------------------------------"
echo
echo "Type     : A"
echo "Name     : jerney"
echo "Target   : ${STATIC_IP}"
echo "Proxy    : ON (orange cloud)"
echo
echo "------------------------------------------------------------"
echo "GKE"
echo "------------------------------------------------------------"
echo
echo "kubectl context:"
kubectl config current-context

echo
echo "------------------------------------------------------------"
echo "DEMO URL"
echo "------------------------------------------------------------"
echo
echo "https://${DOMAIN}"
echo

if [ "${HTTP_STATUS}" = "200" ]; then

    echo "✅ JERNEY IS LIVE"
    echo

elif [ "${CERT_STATUS}" = "Provisioning" ]; then

    echo "⚠️ Infrastructure is deployed."
    echo "⚠️ Certificate is still provisioning."
    echo
    echo "Make sure Cloudflare DNS points:"
    echo
    echo "jerney.rohith-gowda.online -> ${STATIC_IP}"
    echo
    echo "Then wait for the Google Managed Certificate to become Active."

else

    echo "⚠️ Deployment completed, but HTTPS is not returning HTTP 200 yet."
    echo "Check the Ingress and certificate status."

fi

echo
echo "============================================================"
echo "Deployment script finished."
echo "============================================================"