#!/bin/bash
#

helm package ./charts/fwb-k8s-ctrl-2.0.1 -d docs/
helm repo index docs/ --url https://amerintlxperts.github.io/fortiweb-ingress/
git checkout gh-pages
git add docs/
git commit -m "Add or update Helm chart"
git push origin gh-pages
