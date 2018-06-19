#!/bin/bash

set -ex

ACTION=$1
shift

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-apb}:x:$(id -u):0:${USER_NAME:-apb} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

if [[ $ACTION == provision ]]; then
    KUBECTL_COMMAND=create
elif [[ $ACTION == deprovision ]]; then
    KUBECTL_COMMAND=delete
elif [[ $ACTION == update ]]; then
    KUBECTL_COMMAND=apply
else
    echo "Action ($ACTION) not in [ provision, deprovision, update ]."
    exit 1
fi

export TARGET_NAMESPACE=$(echo $2 | jq -r .namespace)
export INSTANCE_ID=$(echo $2 | jq -r ._apb_service_instance_id)
export REPO_URL=$(echo $2 | jq -r .repo)
export REPO_NAME="chartrepo"
export CHART=$(echo $2 | jq -r .chart)
export CHART_NAME="/opt/chart.tgz"
export VERSION=$(echo $2 | jq -r .version)
export NAME="helm-${INSTANCE_ID::8}"
export VALUES_FILE=$(mktemp --tmpdir= values.XXXX)
echo "$2" | jq -r .values | tee $VALUES_FILE

### HELM
helm init --client-only

if [[ -n "$REPO_URL" && -n "$CHART" && -n "$VERSION" ]]; then
    CHART_NAME="/opt/apb/$CHART-$VERSION.tgz"
    helm repo add $REPO_NAME $REPO_URL
    helm fetch $REPO_NAME/$CHART --version=$VERSION -d /opt/apb
fi

if helm version --tiller-namespace $TARGET_NAMESPACE; then
    echo Using tiller
    if [[ $ACTION == provision ]]; then
        echo Provisioning
        helm install --debug --name $NAME -f $VALUES_FILE --namespace $TARGET_NAMESPACE --tiller-namespace $TARGET_NAMESPACE $CHART_NAME
    fi
    if [[ $ACTION == deprovision ]]; then
        echo Deprovisioning
        helm delete --debug --tiller-namespace $TARGET_NAMESPACE $NAME
    fi
    if [[ $ACTION == update ]]; then
        helm upgrade --debug --tiller-namespace $TARGET_NAMESPACE $NAME $CHART_NAME
    fi
else
    echo Using helm template and kubectl create
    helm template --debug --name $NAME -f $VALUES_FILE $CHART_NAME | sed -n '/---/,$p' > /tmp/manifest
    echo "##########################"
    cat /tmp/manifest
    echo "##########################"
    kubectl $KUBECTL_COMMAND -n $TARGET_NAMESPACE -f /tmp/manifest
fi

###

EXIT_CODE=$?

set +ex
rm -f /tmp/secrets
set -ex

exit $EXIT_CODE

