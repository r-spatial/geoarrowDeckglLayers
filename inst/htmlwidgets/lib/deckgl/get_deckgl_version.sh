#!/bin/sh

cat ../../../../../../rpckgdv_deps/rdeckglgeoarrowjs/node_modules/@deck.gl/core/package.json | jq -r '.version' > version.txt
