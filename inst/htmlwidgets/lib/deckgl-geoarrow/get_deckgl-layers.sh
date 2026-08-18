#!/bin/sh

# BASEURL="https://cdn.jsdelivr.net/npm/@geoarrow/deck.gl-layers"

# get (latest) dep
# see https://stackoverflow.com/a/38795701/2555983 for --backups
# basically keeps the last one as backup
# wget --backups=1 ${BASEURL}/dist/dist.umd.min.js
# rm *.js.1

# get (latest) version
# curl -s ${BASEURL}'/package.json' | jq -r '.version' > version.txt
