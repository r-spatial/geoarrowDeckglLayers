import * as deck from "@deck.gl/core";
import * as gaDeckLayers from "@geoarrow/deck.gl-geoarrow";
import * as Arrow from "apache-arrow";
import { MapboxOverlay } from "@deck.gl/mapbox";

Object.assign(window, {gaDeckLayers, Arrow, MapboxOverlay, deck});
