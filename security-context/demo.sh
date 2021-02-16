#! /usr/bin/env bash

source ./demo-magic.sh

clear

pe 'bat pod.yaml'

kubectl delete pod --all

pe 'kubectl create -f pod.yaml'

p 'Now exec to pod and check user id and create file'

pe 'bat security-context.yaml'

kubectl delete pod --all

pe 'kubectl create -f security-context.yaml'

p 'Now exec to pod and check user id and create file'

pe 'bat security-context-non-root.yaml'

kubectl delete pod --all

pe 'kubectl create -f security-context-non-root.yaml'

p 'Now exec to pod and check sysctl kernel.hostname=somevalue'

pe 'bat pod.yaml'

kubectl delete pod --all

pe 'kubectl create -f pod.yaml'

p 'Now exec to pod and check sysctl kernel.hostname=somevalue'

pe 'bat security-context-privileged.yaml'

kubectl delete pod --all

pe 'kubectl create -f security-context-privileged.yaml'

p 'Now exec to pod and check sysctl kernel.hostname=somevalue'

pe 'bat security-context-PrivilegeEscalation.yaml'

kubectl delete pod --all

pe 'kubectl create -f security-context-PrivilegeEscalation.yaml'
