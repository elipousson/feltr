#' Read data from a Felt map
#'
#' Read simple features from a Felt map or get data embedded in the website of a
#' Felt map. [get_felt_data()] returns the parsed JSON included in the body of a
#' Felt map website (which includes both features and other user and layer
#' metadata).
#'
#' @param url A Felt map URL.
#' @param ... Additional parameters passed to [sf::read_sf()].
#' @param crs Coordinate reference system to return. Defaults to 3857.
#' @inheritParams request_felt
#' @param rename If `TRUE` (default), strip the prefix text "felt-" from all
#'   column names.
#' @param name_repair Passed to repair parameter of [vctrs::vec_as_names()].
#'   Defaults to "check_unique".
#' @inheritParams rlang::args_error_context
#' @returns A simple feature data frame or a list of the parsed JSON found
#'   in the "felt-data" div of a Felt map webpage.
#' @seealso [sf::read_sf()]
#' @rdname read_felt
#' @export
#' @importFrom sf read_sf
#' @importFrom rlang set_names
read_felt <- function(url,
                      ...,
                      crs = 3857,
                      token = NULL,
                      rename = TRUE,
                      name_repair = "check_unique") {
  resp <- request_felt(
    endpoint = "read map",
    token = token,
    map_id = get_felt_data(url)[["mapId"]]
    )

  features <- sf::read_sf(httr2::resp_body_string(resp), ...)
  features <- sf::st_transform(features, crs)

  if (!rename) {
    return(features)
  }

  rlang::set_names(
    features,
    vctrs::vec_as_names(
      sub("felt-", "", names(features)),
      repair = name_repair
      )
    )
}

#' @rdname read_felt
#' @name get_felt_data
#' @export
get_felt_data <- function(url, call = caller_env()) {
  url <- felt_url_build(url, type = "data", call = call)

  resp <- req_felt(url, call = call)

  resp_body_felt_data(resp)
}

#' @noRd
felt_url_build <- function(url, type = "features", call = caller_env()) {
  check_string(url, call = call)

  url <- gsub("\\?.*$|/$", "", url)

  base_url <- "https://felt.com/map/"

  if (!is_url(url)) {
    url <- paste0(base_url, url)
  }

  check_felt_url(url, call = call)

  if (type != "features") {
    return(url)
  }

  if (is_geojson_fileext(url)) {
    return(url)
  }

  paste0(url, ".geojson")
}

#' @noRd
req_felt <- function(base_url = "https://felt.com/api/v1",
                     call = caller_env()) {
  req <- httr2::request(base_url)
  req <- httr2::req_user_agent(
    req,
    "rairtable (https://github.com/elipousson/feltr)"
    )
  httr2::req_perform(req, error_call = call)
}

#' @noRd
resp_body_felt_data <- function(resp) {
  rlang::check_installed(c("xml2", "jsonlite"))
  body <- httr2::resp_body_html(resp)
  # FIXME: Comments are stored in threads and users but they aren't coming through this way
  # The divs containing comments use the role = "thread" attribute - extracting these divs from the XML may be another way to get access to the information
  part <- xml2::xml_children(xml2::xml_find_first(body, "//div"))[1]
  part <- xml2::xml_contents(part)
  json <- jsonlite::parse_json(as.character(part))
  json[["mapbox_api_token"]] <- NULL
  json
}
