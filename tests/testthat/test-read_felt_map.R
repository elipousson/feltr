httptest2::with_mock_dir("read_felt_map", {
  test_that("read_felt_map works", {
    url <- "https://felt.com/map/Site-Plan-Example-PGTipS2mT8CYBIVlyAm9BkD"

    expect_s3_class(
      read_felt_map(url),
      "sf"
    )

    expect_type(
      get_felt_map(url),
      "list"
    )
  })
})
