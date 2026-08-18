#!/bin/sh

cat ../../../../../../rpckgdv_deps/rdeckglgeoarrowjs/node_modules/@geoarrow/deck.gl-geoarrow/package.json | jq -r '.version' > version.txt
