#' Get Felt map data from the body of a map website
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' [get_felt_data()] returns the parsed JSON included in the body of the HTML
#' for a Felt map website (which includes both features and other user and layer
#' metadata). This data can be used to supplement the Public API and may be
#' deprecated as the API develops.
#'
#' @inheritParams read_felt_map
#' @returns A list of the parsed JSON found in the "felt-data" div of a Felt map
#'   webpage.
#' @export
get_felt_data <- function(map_id,
                          token = NULL,
                          call = caller_env()) {
  map_id <- set_map_id(map_id, call = call)

  map_url <- felt_map_url_build(map_id, call = call)

  req <- req_felt_auth(httr2::request(map_url), token = token, call = call)

  resp <- httr2::req_perform(req, error_call = call)

  resp_body_felt_data_div(resp)
}

#' @noRd
resp_body_felt_data_div <- function(resp) {
  rlang::check_installed(c("xml2", "RcppSimdJson"))
  body <- httr2::resp_body_html(resp)

  # FIXME: Comments are stored in threads and users but they aren't coming
  # through this way The divs containing comments use the role = "thread"
  # attribute - extracting these divs from the XML may be another way to get
  # access to the information
  part <- xml2::xml_children(xml2::xml_find_first(body, "//div"))[1]
  part <- xml2::xml_contents(part)

  json <- RcppSimdJson::fparse(as.character(part))
  json[["mapbox_api_token"]] <- NULL

  json
}
