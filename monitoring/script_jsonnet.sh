#!/usr/bin/env bash

CUSTOM_FILE=custom.jsonnet
KUBE_PROMETHEUS_RELEASE=release-0.4
CUSTOM_RULE=rules.yaml
CUSTOM_ALERTMANAGERCONFIG=alertmanager-config.yaml

kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --namespace="monitoring" --dry-run -oyaml >additional-scrape-configs.yaml

rm -rf kube-prometheus || exit
git clone https://github.com/coreos/kube-prometheus
cp $CUSTOM_FILE kube-prometheus/
cp $CUSTOM_RULE kube-prometheus/
cp $CUSTOM_ALERTMANAGERCONFIG kube-prometheus/

cd kube-prometheus || exit
git checkout $KUBE_PROMETHEUS_RELEASE

go get -u -v github.com/brancz/gojsontoyaml
cat $CUSTOM_RULE | gojsontoyaml -yamltojson >$CUSTOM_RULE.json

docker run --rm -v "$(pwd)":"$(pwd)" --workdir "$(pwd)" quay.io/coreos/jsonnet-ci jb update
docker run --rm -v"$(pwd)":"$(pwd)" --workdir "$(pwd)" quay.io/coreos/jsonnet-ci ./build.sh custom.jsonnet

cp ../additional-scrape-configs.yaml manifests/
cp ../psp-monitoring.yaml manifests/

sed -i '/^  storage:.*/i\  additionalScrapeConfigs:\n    name: additional-scrape-configs\n    key: prometheus-additional.yaml' manifests/prometheus-prometheus.yaml

rm -f manifests/alertmanager-config.yaml
rm -f manifests/alertmanager-name.yaml
rm -f manifests/alertmanager-replicas.yaml

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
