
<!-- README.md is generated from README.Rmd. Please edit that file -->

# feltr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

The goal of feltr is to read maps from Felt as simple feature objects.

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

``` r
read_felt("https://felt.com/map/Site-Plan-Example-PGTipS2mT8CYBIVlyAm9BkD")
#> Simple feature collection with 28 features and 22 fields
#> Geometry type: GEOMETRY
#> Dimension:     XY
#> Bounding box:  xmin: -122.2756 ymin: 37.80923 xmax: -122.273 ymax: 37.81061
#> Geodetic CRS:  WGS 84
#> # A tibble: 28 × 23
#>    clipSource color   fillOpacity hasLongDescription icon  id    locked ordering
#>    <chr>      <chr>         <dbl> <lgl>              <chr> <chr> <lgl>     <dbl>
#>  1 <NA>       #C93535       NA    NA                 <NA>  2948… FALSE   1.67e15
#>  2 <NA>       #C93535       NA    NA                 <NA>  5c15… FALSE   1.67e15
#>  3 <NA>       #2674BA        0.44 NA                 <NA>  593d… FALSE   1.67e15
#>  4 <NA>       #2674BA        0.44 NA                 <NA>  16ce… FALSE   1.67e15
#>  5 <NA>       #C93535        0.29 NA                 <NA>  8526… FALSE   1.67e15
#>  6 <NA>       #C93535        0.29 NA                 <NA>  65eb… FALSE   1.67e15
#>  7 <NA>       #C93535       NA    NA                 <NA>  5d70… FALSE   1.67e15
#>  8 <NA>       #C93535       NA    NA                 <NA>  13f7… FALSE   1.67e15
#>  9 <NA>       #2674BA       NA    NA                 <NA>  704c… FALSE   1.67e15
#> 10 <NA>       #2674BA       NA    NA                 <NA>  c3f2… FALSE   1.67e15
#> # ℹ 18 more rows
#> # ℹ 15 more variables: rotation <dbl>, routeMode <chr>, scale <dbl>,
#> #   showArea <lgl>, showLength <lgl>, strokeOpacity <dbl>, strokeStyle <chr>,
#> #   strokeWidth <int>, text <chr>, textStyle <chr>, type <chr>,
#> #   widthScale <dbl>, zoom <dbl>, position <list>, geometry <POLYGON [°]>
```
