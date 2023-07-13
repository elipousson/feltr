#' Read Felt map elements, create a Felt map from a URL, or delete a Felt map
#'
#' Read elements, create, or delete a Felt map from a URL or map ID.
#' [get_felt_map()] returns a list of map details and optionally (if `read =
#' TRUE`) adds the map elements and layer list as elements in the list.
#'
#' @inheritParams request_felt
#' @param ... Additional parameters passed to [sf::read_sf()].
#' @param crs Coordinate reference system. Passed to [sf::st_transform()] if
#'   supplied.
#' @return [read_felt_map()] returns a sf object, [create_felt_map()] invisibly
#'   returns a list of attributes for the created map, and [delete_felt_map()]
#'   does not return anything.
#' @rdname read_felt_map
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   map_data <- create_felt_map(title = "Example map")
#'
#'   url <- map_data$attributes$url
#'
#'   get_felt_map(url = url)
#'
#'   delete_felt_map(url = url)
#'
#'   read_felt_map("https://felt.com/map/Site-Plan-Example-PGTipS2mT8CYBIVlyAm9BkD")
#' }
#' }
#' @export
#' @importFrom sf read_sf st_transform
#' @importFrom httr2 resp_body_string
#' @importFrom cli cli_alert_danger
read_felt_map <- function(map_id,
                          ...,
                          crs = NULL,
                          token = NULL) {
  resp <- request_felt(
    endpoint = "read map",
    map_id = map_id,
    token = token
  )

  data <- sf::read_sf(httr2::resp_body_string(resp), ...)

  if (!is_null(crs)) {
    data <- sf::st_transform(data, crs = crs)
  }

  if (nrow(data) == 0) {
    cli::cli_alert_danger(
      "No elements found for Felt map at {.url {felt_map_url_build(map_id)}}"
    )
  }

  data
}

#' @name get_felt_map
#' @rdname read_felt_map
#' @param read If `TRUE`, add a sf object with the map data as an element and a
#'   list of Felt layers to the returned list of map attributes. Defaults to
#'   `FALSE`.
#' @inheritParams httr2::resp_body_json
#' @export
#' @importFrom httr2 resp_body_json
get_felt_map <- function(map_id,
                         ...,
                         read = FALSE,
                         simplifyVector = TRUE,
                         token = NULL,
                         call = caller_env()) {
  resp <- request_felt(
    endpoint = "get map",
    map_id = map_id,
    token = token,
    call = call
  )

  data <- httr2::resp_body_json(resp, simplifyVector = simplifyVector)[["data"]]

  if (read) {
    data[["elements"]] <- read_felt_map(map_id = map_id, ..., token = token)
    data[["layers"]] <- read_felt_layers(
      map_id = map_id,
      ...,
      simplifyVector = simplifyVector,
      token = token
    )
  }

  data
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
    data = set_felt_map_data(
      title = title,
      description = description,
      location = location,
      zoom = zoom,
      layer_urls = layer_urls,
      basemap = basemap
    ),
    token = token
  )

  data <- httr2::resp_body_json(resp)[["data"]]

  map_url <- data[["attributes"]][["url"]]
  map_title <- data[["attributes"]][["title"]]

  cli_alert_success(
    "Created new Felt map {.val {map_title}} at {.url {map_url}}"
  )

  invisible(data)
}

#' Set up Felt map data
#'
#' Internal function to prepare input parameters for [create_felt_map()]
#'
#' @param title Map title
#' @param description Map description
#' @param location Location to center map, either a sf, sfc, or bbox object or a
#'   length 2 numeric vector in the form of `c("lon", "lat")`. To pass
#'   coordinates in lat/lon order, set the `feltr.latlon` option to `TRUE`
#'   (option defaults to `FALSE`). If location is `NULL` (default), map is
#'   centered on Oakland, California.
#' @param zoom Zoom level number
#' @param basemap Basemap, string ("default" or "satellite"), a valid layer URL,
#'   a color name, or a color hex code.
#' @param layer_urls A character vector or list of raster layer URLs.
#' @keywords internal
#' @importFrom sf st_is st_point_on_surface st_coordinates st_union
#' @importFrom vctrs list_drop_empty
set_felt_map_data <- function(title = NULL,
                              description = NULL,
                              location = NULL,
                              zoom = NULL,
                              layer_urls = NULL,
                              basemap = c("default", "satellite"),
                              allow_null = TRUE,
                              call = caller_env()) {
  check_string(title, allow_null = allow_null, call = call)
  check_string(description, allow_null = allow_null, call = call)

  basemap <- set_felt_map_basemap(
    basemap,
    allow_null = allow_null,
    call = call
  )

  location <- set_felt_map_location(
    location,
    allow_null = allow_null,
    call = call
  )

  lon <- location[[1]]
  lat <- location[[2]]

  check_number_decimal(zoom, allow_null = allow_null, call = call)

  if ((is_null(layer_urls) && !allow_null) || !all(is_url(layer_urls))) {
    cli_abort(
      "{.arg layer_urls} must be a vector of raster URLs,
      not {.obj_simple_type {layer_urls}}.",
      call = call
    )
  }

  vctrs::list_drop_empty(
    list(
      title = title,
      description = description,
      basemap = basemap,
      layer_urls = layer_urls,
      lat = lat,
      lon = lon,
      zoom = zoom
    )
  )
}


#' Set location parameter for set_felt_map_basemap
#'
#' @noRd
#' @importFrom grDevices colors rgb col2rgb
set_felt_map_basemap <- function(basemap = c("default", "satellite"),
                                 allow_null = TRUE,
                                 call = caller_env()) {
  if (allow_null && is_null(basemap)) {
    return(basemap)
  }

  if (all(basemap %in% c("default", "satellite"))) {
    return(arg_match(basemap, error_call = call))
  }

  check_string(basemap, allow_empty = FALSE, call = call)

  if (is_url(basemap)) {
    # TODO: Add validation for the URL
    return(basemap)
  }

  if (basemap %in% grDevices::colors()) {
    basemap <- grDevices::rgb(
      t(grDevices::col2rgb(basemap)),
      maxColorValue = 255
    )

    basemap <- tolower(basemap)
  }

  if (!grepl("^#[[:alnum:]]+$", basemap, perl = TRUE)) {
    cli_abort(
      "{.arg basemap} must be a color name, color hex code, basemap URL,
      or the string {.val default} or {.val satellite}",
      call = call
    )
  }

  basemap
}

#' Set location parameter for set_felt_map_data
#'
#' @noRd
set_felt_map_location <- function(location,
                                  allow_null = TRUE,
                                  call = caller_env()) {
  if (allow_null && is_null(location)) {
    return(list(NULL, NULL))
  }

  if (is.numeric(location) && is_true(getOption("feltr.latlon", FALSE))) {
    location <- rev(location)
  }

  if (inherits_any(location, c("sf", "sfc", "bbox"))) {
    if (inherits(location, "bbox")) {
      location <- sf::st_as_sfc(location)
    }

    if (!all(sf::st_is(location, "POINT"))) {
      location <- suppressWarnings(sf::st_point_on_surface(location))
    }

    location <- sf::st_coordinates(sf::st_union(location))
  }

  if (has_length(location, 2) && is.numeric(location)) {
    return(location)
  }

  cli_abort(
    "{.arg location} must be `NULL`, a sf, sfc, or bbox object,
      or a coordinate pair, not {.obj_type_simple {location}}.",
    call = call
  )
}

#' @name delete_felt_map
#' @rdname read_felt_map
#' @param safely If `TRUE` (default), check for user confirmation before
#'   deleting a Felt map. If `FALSE`, delete map without checking.
#' @export
delete_felt_map <- function(map_id,
                            safely = TRUE,
                            token = NULL) {
  map_url <- felt_map_url_build(map_id)
  map_data <- get_felt_map(map_id)
  map_title <- map_data[["attributes"]][["title"]]

  safety_check(
    safely = safely,
    c(
      ">" = "Deleting Felt map {.val {map_title}} at {.url {map_url}}"
    ),
    message = "Canceled request to delete map."
  )

  request_felt(
    endpoint = "delete map",
    map_id = map_id,
    token = token
  )

  cli_alert_success(
    "{.val {map_title}} deleted."
  )
}
