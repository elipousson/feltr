#' Read, create, or delete a Felt map
#'
#' Read, create, or delete a Felt map from a URL or map ID.
#'
#' @param url A Felt map URL.
#' @param map_id A Felt map ID, optional if url is supplied.
#' @param ... Additional parameters passed to [sf::read_sf()].
#' @inheritParams request_felt
#' @return [read_felt_map()] returns a sf object, [create_felt_map()] invisibly
#'   returns a list of attributes for the created map, and [delete_felt_map()]
#'   does not return anything.
#' @rdname read_felt_map
#' @export
read_felt_map <- function(url,
                          map_id = NULL,
                          ...,
                          token = NULL) {
  resp <- request_felt(
    endpoint = "read map",
    map_id = map_id %||% parse_url_map_id(url),
    token = token
  )

  sf::read_sf(httr2::resp_body_string(resp), ...)
}

#' @name create_felt_map
#' @rdname read_felt_map
#' @inheritParams set_felt_map_data
#' @export
create_felt_map <- function(title = NULL,
                            description = NULL,
                            location = NULL,
                            zoom = NULL,
                            layer_urls = NULL,
                            basemap = c("default", "satellite"),
                            token = NULL) {
  resp <- request_felt(
    endpoint = "create map",
    token = token,
    data = set_felt_map_data(
      title = title,
      description = description,
      location = location,
      zoom = zoom,
      layer_urls = layer_urls,
      basemap = basemap
    )
  )

  data <- httr2::resp_body_json(resp)[["data"]]

  if (!is_null(data$attributes$title)) {
    cli_alert_success(
      "Created new Felt map {.val {data$attributes$title}}
      at {.url {data$attributes$url}}"
    )
  } else {
    cli_alert_success(
      "Created new Felt map at {.url {data$attributes$url}}"
    )
  }

  invisible(data)
}

#' Set up Felt map data
#'
#' Internal function for setting up map data for [create_felt_map()]
#'
#' @param title Map title
#' @param description Map description
#' @param location Location to center map, either a sf or sfc object or a length
#'   2 numeric vector in the form of `c("lon", "lat")`
#' @param zoom Zoom level number
#' @param basemap Basemap, string ("default" or "satellite") or a valid layer
#'   URL or color as hex code.
#' @param layer_urls Raster layer URLs
#' @keywords internal
#' @importFrom sf st_is st_point_on_surface st_coordinates st_union
#' @importFrom vctrs list_drop_empty
set_felt_map_data <- function(title = NULL,
                              description = NULL,
                              location = NULL,
                              zoom = NULL,
                              layer_urls = NULL,
                              basemap = c("default", "satellite"),
                              call = caller_env()) {
  check_string(title, allow_null = TRUE, call = call)
  check_string(description, allow_null = TRUE, call = call)

  if (!all(is_url(basemap)) && !all(grepl("^#", basemap))) {
    basemap <- arg_match(basemap, error_call = call)
  } else {
    check_string(basemap, allow_empty = FALSE, call = call)
  }

  if (inherits_any(location, c("sf", "sfc"))) {
    if (!all(sf::st_is(location, "POINT"))) {
      location <- suppressWarnings(sf::st_point_on_surface(location))
    }

    location <- sf::st_coordinates(sf::st_union(location))
  }

  check_number_decimal(location, allow_null = TRUE, call = call)

  lon <- location[[1]]
  lat <- location[[2]]

  check_number_decimal(zoom, allow_null = TRUE, call = call)
  check_character(layer_urls, allow_null = TRUE, call = call)

  vctrs::list_drop_empty(
    list(
      title = title,
      description = description,
      lat = lat,
      lon = lon,
      zoom = zoom
    )
  )
}

#' @name delete_felt_map
#' @rdname read_felt_map
#' @param safely If `TRUE` (default), check for user confirmation before
#'   deleting a Felt map. If `FALSE`, delete map without checking for
#'   confirmation.
#' @export
delete_felt_map <- function(url,
                            map_id = NULL,
                            safely = TRUE,
                            token = NULL) {
  map_data <- get_felt_data(url)

  safety_check(
    safely = safely,
    c(
      ">" = "Deleting Felt map {.val {map_data[['mapTitle']]}} at {.url {url}}"
    ),
    message = "Cancelled request to delete map."
  )

  request_felt(
    endpoint = "delete map",
    token = token,
    map_id = map_id %||% parse_url_map_id(url)
  )

  cli::cli_alert_success(
    "{.val {map_data[['mapTitle']]}} deleted."
  )
}
