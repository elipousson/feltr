#' Read data from a Felt map URL
#'
#' Read data from a Felt map URL as a GeoJSON.
#'
#' @param url A Felt URL
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
                      type = "features") {
  check_felt_url(url)

  if (!is_geojson_fileext(url)) {
    url <- paste0(url, ".geojson")
  }

  req <- httr2::request(url)
  resp <- httr2::req_perform(req)

  if (type != "features") {
    return(httr2::resp_body_json(resp))
  }

  body <- httr2::resp_body_string(resp)
  data <- sf::read_sf(body, ...)
  data <- rlang::set_names(data, sub("felt-", "", names(data)))

  data
}
