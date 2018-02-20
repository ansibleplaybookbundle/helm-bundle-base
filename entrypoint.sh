#!/bin/bash

set -x

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
    OC_COMMAND=create
elif [[ $ACTION == deprovision ]]; then
    OC_COMMAND=delete
else
    echo First argument must be one of "provision" or "deprovision".
    exit 1
fi

shift
TARGET_NAMESPACE=$(echo $2 | jq -r .namespace)
INSTANCE_ID=$(echo $2 | jq -r ._apb_service_instance_id)
CREDS="/var/tmp/bind-creds"

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-apb}:x:$(id -u):0:${USER_NAME:-apb} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

### HELM

helm template --debug --name $INSTANCE_ID /opt/chart.tgz --set securityContext.enabled=False | sed -n '/---/,$p' > /tmp/manifest
echo "##########################"
cat /tmp/manifest
echo "##########################"
oc $OC_COMMAND -n $TARGET_NAMESPACE -f /tmp/manifest

###

EXIT_CODE=$?

set +ex
rm -f /tmp/secrets
set -ex

exit $EXIT_CODE

