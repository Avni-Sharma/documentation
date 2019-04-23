#!/bin/bash

HTPASSWD_FILE="./htpass"
USERNAME="consoledeveloper"
USERPASS="developer"
HTPASSWD_SECRET="htpasswd-consoledeveloper-secret"

OC_USERS_LIST="$(oc get users)"
if echo "${OC_USERS_LIST}" | grep -q "${USERNAME}"; then
    echo "User consoledeveloper already exists"
    exit;
fi
htpasswd -cb $HTPASSWD_FILE $USERNAME $USERPASS

oc get secret $HTPASSWD_SECRET -n openshift-config &> /dev/null

oc create secret generic ${HTPASSWD_SECRET} --from-file=htpasswd=${HTPASSWD_FILE} -n openshift-config

oc apply -f - <<EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: consoledeveloper
    challenge: true
    login: true
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: ${HTPASSWD_SECRET}
EOF

oc create clusterrolebinding ${USERNAME}_role --clusterrole=self-provisioner --user=${USERNAME}
