test_that("is_felt_url works", {
  url <- "https://felt.com/map/Site-Plan-Example-PGTipS2mT8CYBIVlyAm9BkD"
  expect_true(is_felt_url(url))
  expect_false(is_felt_url("https://cran.r-project.org/"))
  expect_identical(check_felt_url(url), url)
  expect_error(check_felt_url("https://cran.r-project.org/"))
})
