#' Read data from a Felt map URL
#'
#' Read data from a Felt map URL as a GeoJSON.
#'
#' @param url A Felt map URL.
#' @param type Type of data to return, "features" (default) or "data". If type
#'   is "data", the function returns the parsed JSON included in the body of the
#'   map page (which includes both features and other user and layer metadata).
#' @param ... Additional parameters passed to [sf::read_sf()].
#' @param crs Coordinate reference system to return. Defaults to 3857.
#' @param rename If `TRUE` (default), strip the prefix text "felt-" from all
#'   column names.
#' @return A simple feature data.frame.
#' @seealso [sf::read_sf()]
#' @rdname read_felt
#' @returns A sf object if type is "features" or a list of the parsed JSON found
#'   in the "felt-data" div if type is "data".
#' @export
#' @importFrom sf read_sf
#' @importFrom rlang set_names
read_felt <- function(url,
                      type = "features",
                      ...,
                      crs = 3857,
                      rename = TRUE) {
  url <- felt_url_build(url, type)
  type <- match.arg(type, c("features", "data"))

  if (type != "features") {
    resp <- req_felt(url)
    return(resp_body_felt_data(resp))
  }

  features <- sf::read_sf(paste0("/vsicurl/", url), ...)
  features <- sf::st_transform(features, crs)

  if (!rename) {
    return(features)
  }

  rlang::set_names(features, sub("felt-", "", names(features)))
}

#' @noRd
felt_url_build <- function(url, type = "features", call = caller_env()) {
  check_required(url, call = call)

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
  rlang::check_installed("httr2")
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
