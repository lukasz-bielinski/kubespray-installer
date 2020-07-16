#!/usr/bin/env bash

CUSTOM_FILE=custom.jsonnet
KUBE_PROMETHEUS_RELEASE=release-0.4

rm -rf kube-prometheus || exit
git clone https://github.com/coreos/kube-prometheus
cp $CUSTOM_FILE kube-prometheus/
cp alertmanager-config.yaml kube-prometheus/

cd kube-prometheus || exit
git checkout $KUBE_PROMETHEUS_RELEASE

docker run --rm -v "$(pwd)":"$(pwd)" --workdir "$(pwd)" quay.io/coreos/jsonnet-ci jb update
docker run --rm -v"$(pwd)":"$(pwd)" --workdir "$(pwd)" quay.io/coreos/jsonnet-ci ./build.sh $CUSTOM_FILE

#OLD
# my-kube-prometheus
# cd my-kube-prometheus
# jb init
# jb install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@release-0.4
#
# go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
# go get github.com/brancz/gojsontoyaml
#
# wget https://raw.githubusercontent.com/coreos/kube-prometheus/master/build.sh
#
# wget https://raw.githubusercontent.com/coreos/kube-prometheus/master/examples/prometheus-pvc.jsonnet
#
# ## BUILD
# ./build.sh prometheus-pvc.jsonnet
#
