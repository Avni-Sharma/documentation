#!/usr/bin/env bash

HTPASSWD_FILE="./htpass4"
USERNAME="consoledeveloper4"
USERPASS="developer"
HTPASSWD_SECRET="htpasswd4-consoledeveloper-secret"

OC_USERS_LIST="$(oc get users)"
if echo "${OC_USERS_LIST}" | grep -q "${USERNAME}"; then
    echo -e "\n\033[0;32m \xE2\x9C\x94 User consoledeveloper already exists \033[0m\n"
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
  - name: consoledeveloper4
    challenge: true
    login: true
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: ${HTPASSWD_SECRET}
EOF

oc create clusterrolebinding ${USERNAME}_role --clusterrole=self-provisioner --user=${USERNAME}
