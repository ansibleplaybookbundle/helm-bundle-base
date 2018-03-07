#!/bin/bash

set -ex

# Work-Around
# The OpenShift's s2i (source to image) requires that no ENTRYPOINT exist
# for any of the s2i builder base images.  Our 's2i-apb' builder uses the
# apb-base as it's base image.  But since the apb-base defines its own
# entrypoint.sh, it is not compatible with the current source-to-image.
#
# The below work-around checks if the entrypoint was called within the
# s2i-apb's 'assemble' script process. If so, it skips the rest of the steps
# which are APB run-time specific.
#
# Details of the issue in the link below:
# https://github.com/openshift/source-to-image/issues/475
#
if [[ $@ == *"s2i/assemble"* ]]; then
  echo "---> Performing S2I build... Skipping server startup"
  exec "$@"
  exit $?
fi

ACTION=$1
if [[ $ACTION == provision ]]; then
    KUBECTL_COMMAND=create
    HELM_COMMAND=install
elif [[ $ACTION == deprovision ]]; then
    KUBECTL_COMMAND=delete
    HELM_COMMAND=delete
else
    echo First argument must be one of "provision" or "deprovision".
    exit 1
fi

shift
# Important variables
TARGET_NAMESPACE=$(echo $2 | jq -r .namespace)
REPO_URL=$(echo $2 | jq -r .repo)
REPO_NAME=$(echo $2 | jq -r .repo_name)
CHART=$(echo $2 | jq -r .chart)
NAME=$(echo $2 | jq -r .name)
TILLER=$(echo $2 | jq -r .tiller)
VALUES_FILE=$(mktemp --tmpdir= values.XXXX)
echo "$2" | jq -r .values | tee $VALUES_FILE
[ ${TILLER,,} == "true" ] && USE_TILLER=1 || USE_TILLER=0

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-apb}:x:$(id -u):0:${USER_NAME:-apb} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

### HELM
if [ $USE_TILLER ]; then
    # Create permissions for tiller in target namespace
    kubectl get serviceaccount --namespace=$TARGET_NAMESPACE tiller || \
        kubectl create serviceaccount --namespace=$TARGET_NAMESPACE tiller
    kubectl get rolebinding --namespace=$TARGET_NAMESPACE tiller || \
        kubectl create rolebinding tiller \
            --namespace=$TARGET_NAMESPACE \
            --clusterrole=edit \
            --serviceaccount=$TARGET_NAMESPACE:tiller

    # Start Tiller
    kubectl get deploy --namespace=$TARGET_NAMESPACE tiller-deploy || \
        helm init --service-account=tiller --tiller-namespace=$TARGET_NAMESPACE

    echo "Waiting for tiller"
    for i in {1..60}; do # timeout for 5 minutes
        TILLER_AVAILABLE=$(
            kubectl get deploy --namespace=$TARGET_NAMESPACE tiller-deploy \
            -o jsonpath='{.status.conditions[?(.type == "Available")].status}'
        )
       if [ ${TILLER_AVAILABLE,,} == "true" ]; then
          break
      fi
      sleep 5
    done
else
    echo "Initializing helm, client only"
    helm init --client-only
fi

helm repo add $REPO_NAME $REPO_URL

if [ $USE_TILLER ]; then
    helm $HELM_COMMAND $REPO_NAME/$CHART \
        --tiller-namespace=$TARGET_NAMESPACE \
        --name=$NAME \
        --values=$VALUES_FILE \
        --namespace=$TARGET_NAMESPACE
else
    helm fetch $REPO_NAME/$CHART --untar -d /opt/apb
    helm template --name=$NAME /opt/apb/$CHART | sed -n '/---/,$p' > /tmp/manifest
    echo "##########################"
    cat /tmp/manifest
    echo "##########################"
    kubectl $KUBECTL_COMMAND --namespace=$TARGET_NAMESPACE -f /tmp/manifest
fi

if [[ $ACTION == deprovision ]] && [ $USE_TILLER ]; then
    helm reset --tiller-namespace=$TARGET_NAMESPACE && REMOVE_TILLER=1 || REMOVE_TILLER=0
    if [ $REMOVE_TILLER ]; then
        kubectl delete serviceaccount --namespace=$TARGET_NAMESPACE tiller
        kubectl delete rolebinding --namespace=$TARGET_NAMESPACE tiller
    fi
fi
###

EXIT_CODE=$?

set +ex
rm -f /tmp/secrets
set -ex

exit $EXIT_CODE

