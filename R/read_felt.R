#' Read data from a Felt map URL
#'
#' Read data from a Felt map URL as a GeoJSON.
#'
#' @param url A Felt URL
#' @param type Type of data to return. Defaults to "features".
#' @param rename If `TRUE` (default), strip the prefix text "felt-" from all
#'   column names.
#' @param ... Additional parameters passed to [sf::read_sf()]
#' @return A simple feature data.frame.
#' @seealso [sf::read_sf()]
#' @rdname read_felt
#' @export
#' @importFrom httr2 request req_perform resp_body_json resp_body_string
#' @importFrom sf read_sf
#' @importFrom rlang set_names
read_felt <- function(url,
                      ...,
                      type = "features",
                      rename = TRUE) {
  url <- felt_url_build(url, type)
  resp <- req_felt(url)
  type <- match.arg(type, c("features", "data"))

  if (type != "features") {
    return(resp_body_felt_data(resp))
  }

  body <- httr2::resp_body_string(resp)
  data <- sf::read_sf(body, ...)

  if (!rename) {
    return(data)
  }

  rlang::set_names(data, sub("felt-", "", names(data)))
}

#' @noRd
felt_url_build <- function(url, type = "features") {
  url <- gsub("\\?.*$|/$", "", url)

  base_url <- "https://felt.com/map/"

  if (!is_url(url)) {
    url <- paste0(base_url, url)
  }

  check_felt_url(url)

  if (type != "features") {
    return(url)
  }

  if (is_geojson_fileext(url)) {
    return(url)
  }

  paste0(url, ".geojson")
}

#' @noRd
req_felt <- function(url) {
  req <- httr2::request(url)
  req <- httr2::req_user_agent(req,
    "rairtable (https://github.com/elipousson/feltr)")
  httr2::req_perform(req)
}

#' @noRd
resp_body_felt_data <- function(resp) {
  rlang::check_installed(c("xml2", "jsonlite"))
  body <- httr2::resp_body_html(resp)
  part <- xml2::xml_children(xml2::xml_find_first(body, "//div"))[1]
  part <- xml2::xml_contents(part)
  json <- jsonlite::parse_json(as.character(part))
  json[["mapbox_api_token"]] <- NULL
  json
}
