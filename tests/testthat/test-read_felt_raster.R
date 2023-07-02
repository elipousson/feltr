httptest2::with_mock_dir("read_felt_raster", {
  test_that("read_felt_raster works", {
    raster_image <-
      read_felt_raster(
        "https://felt.com/map/feltr-sample-map-read-felt-raster-oiinodTbT79BEueYdGp1aND",
        "https://tile.loc.gov/image-services/iiif/service:gmd:gmd370:g3700:g3700:ct003955/full/pct:12.5/0/default.jpg"
      )

    expect_s4_class(
      raster_image,
      "SpatRaster"
    )
  })
})
