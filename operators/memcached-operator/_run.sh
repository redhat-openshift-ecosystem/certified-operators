#!/bin/bash

oc new-project memcached-operator
                                                                                                                                                0.0s
docker login -u=ogaye -p=ZTejas99! quay.io

export IMG=quay.io/ogaye/memcached-operator:latest
export BUNDLE_IMG=quay.io/ogaye/memcached-operator-bundle:latest

 make docker-build IMG=$IMG
 make docker-push IMG=$IMG

 make bundle
 make bundle-build BUNDLE_IMG=$BUNDLE_IMG
 docker push $BUNDLE_IMG

#operator-sdk olm status --olm-namespace=openshift-operator-lifecycle-manager

oc create secret docker-registry reg --docker-username=ogaye --docker-password=ZTejas99! --docker-server=quay.io/ogaye

oc patch serviceaccount default -p '{"imagePullSecrets":[{"name":"reg"}]}'

operator-sdk run bundle $BUNDLE_IMG -n memcached-operator --pull-secret-name=reg