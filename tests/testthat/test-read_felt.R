test_that("read_felt works", {
  expect_s3_class(
    read_felt("https://felt.com/map/Site-Plan-Example-PGTipS2mT8CYBIVlyAm9BkD"),
    "sf"
  )
})
