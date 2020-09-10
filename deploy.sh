#!/usr/bin/env bash

set -e

echo "Run test"

php -l index.php

php -S localhost:8080 index.php &

sleep 2

curl localhost:8080

kill %1

echo "Build docker image"

docker build -t bashofmann/hello-world:${COMMIT_HASH} .

echo "Push docker image"

docker push bashofmann/hello-world:${COMMIT_HASH}

echo "Test helm chart"

helm lint helm/hello-world

# helm plugin install https://github.com/instrumenta/helm-kubeval

helm kubeval helm/hello-world --strict

echo "Diff to Kubernetes"

#  helm plugin install https://github.com/databus23/helm-diff

helm diff upgrade hello-world helm/hello-world/ --namespace hello-world -f helm/values-prod.yaml --set image.tag=${COMMIT_HASH}

echo "Deployment to Kubernetes"

# helm template hello-world helm/hello-world/ -f helm/values-prod.yaml

helm upgrade --install hello-world helm/hello-world/ --namespace hello-world --create-namespace -f helm/values-prod.yaml --set image.tag=${COMMIT_HASH}