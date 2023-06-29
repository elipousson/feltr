
<!-- README.md is generated from README.Rmd. Please edit that file -->

# feltr <a href="https://elipousson.github.io/feltr/"><img src="man/figures/logo.png" align="right" height="124" alt="feltr website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Codecov test
coverage](https://codecov.io/gh/elipousson/feltr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/elipousson/feltr?branch=main)
<!-- badges: end -->

The goal of feltr is to read maps from Felt as simple feature or
`SpatRaster` objects.

## Installation

You can install the development version of feltr like so:

``` r
pak::pkg_install("elipousson/feltr")
```

## Example

``` r
library(feltr)
## basic example code
```

You can use `read_felt()` to create an sf object with features from a
map URL.

``` r
site_plan <- read_felt("https://felt.com/map/Site-Plan-Example-PGTipS2mT8CYBIVlyAm9BkD")

plot(site_plan)
#> Warning: plotting the first 9 out of 22 attributes; use max.plot = 22 to plot
#> all
```

<img src="man/figures/README-read-1.png" width="100%" />

You can also use `read_felt_raster()` (a wrapper for
`rasterpic::rasterpic_img()`) to create a `SpatRaster` object from a
“Image” type feature in Felt.

``` r
image_map <- read_felt_raster(
  "https://felt.com/map/feltr-sample-map-read-felt-raster-oiinodTbT79BEueYdGp1aND",
  "https://tile.loc.gov/image-services/iiif/service:gmd:gmd370:g3700:g3700:ct003955/full/pct:12.5/0/default.jpg"
)

image_map
#> class       : SpatRaster 
#> dimensions  : 655, 764, 3  (nrow, ncol, nlyr)
#> resolution  : 6439.813, 6439.813  (x, y)
#> extent      : -12209153, -7289135, 2474851, 6692929  (xmin, xmax, ymin, ymax)
#> coord. ref. : WGS 84 / Pseudo-Mercator (EPSG:3857) 
#> source      : filebe827f397dd1.jpg 
#> colors RGB  : 1, 2, 3 
#> names       : filebe827f397dd1_1, filebe827f397dd1_2, filebe827f397dd1_3
```
