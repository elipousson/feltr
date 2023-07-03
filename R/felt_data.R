#' Get Felt map data from the body of the map website
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' [get_felt_data()] returns the parsed JSON included in the body of the HTML
#' for a Felt map website (which includes both features and other user and layer
#' metadata). This data can be used to supplement the Public API.
#'
#' @inheritParams read_felt_map
#' @export
get_felt_data <- function(url = NULL,
                          map_id = NULL,
                          token = NULL,
                          call = caller_env()) {
  map_id <- map_id %||% felt_url_parse(url, call = call)

  map_url <- felt_url_build(url)

  req <- req_felt_auth(httr2::request(map_url), token = token, call = call)

  resp <- httr2::req_perform(req)

  resp_body_felt_data_div(resp)
}

#' @noRd
resp_body_felt_data_div <- function(resp) {
  rlang::check_installed(c("xml2", "jsonlite"))
  body <- httr2::resp_body_html(resp)

  # FIXME: Comments are stored in threads and users but they aren't coming
  # through this way The divs containing comments use the role = "thread"
  # attribute - extracting these divs from the XML may be another way to get
  # access to the information
  part <- xml2::xml_children(xml2::xml_find_first(body, "//div"))[1]
  part <- xml2::xml_contents(part)

  json <- jsonlite::parse_json(as.character(part))
  json[["mapbox_api_token"]] <- NULL

  json
}
