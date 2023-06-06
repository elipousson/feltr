test_that("read_felt works", {
  url <- "https://felt.com/map/Site-Plan-Example-PGTipS2mT8CYBIVlyAm9BkD"

  expect_s3_class(
    read_felt(url),
    "sf"
  )

  expect_type(
    get_felt_data(url),
    "list"
  )
})
