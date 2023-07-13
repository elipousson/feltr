#' Read layers from a Felt map, delete a layer, or create a new layer from a URL
#'
#' Read layers from a Felt map, delete a single layer, or create a new layer
#' from a URL. Note that the layers do not include data.
#'
#' @inheritParams read_felt_map
#' @inheritParams request_felt
#' @param layer Required. Layer source URL, either a supported static file or a
#'   URL supported by Felt. See
#'   <https://feltmaps.notion.site/Upload-Anything-b26d739e80184127872faa923b55d232#3e37f06bc38c4971b435fbff2f4da6cb>
#' @param name Name for new map layer.
#' @examples
#'
#' create_felt_layer()
#'
#' @export
create_felt_layer <- function(map_id,
                              layer,
                              name = NULL,
                              token = NULL) {
  check_string(layer, allow_empty = FALSE)

  if (is_url(layer)) {
    resp <- request_felt(
      endpoint = "import url",
      data = list(
        layer_url = layer,
        name = name
      ),
      map_id = map_id,
      token = token
    )

    data <- httr2::resp_body_json(resp)[["data"]]
  } else if (file.exists(layer)) {
    cli_abort(
      c(
        "{.arg layer} must be a URL.",
        "Support for local files will be added in the future."
      )
    )

    resp <- request_felt(
      endpoint = "create layer",
      map_id = map_id,
      data = list(
        file_names = list(basename(layer)),
        name = name
      )
    )
  }

  map_url <- felt_map_url_build(map_id)

  cli_alert_success(
    "Layer {.val {data$attributes$name}} created at {.url {map_url}}"
  )

  invisible(data)
}

#' @name delete_felt_layer
#' @rdname create_felt_layer
#' @param layer_id Layer ID. Layer IDs for a map can be listed using
#'   [read_felt_layers()]
#' @export
delete_felt_layer <- function(map_id,
                              layer_id = NULL,
                              safely = TRUE,
                              token = NULL) {
  map_url <- felt_map_url_build(map_id)

  if (is_null(layer_id) && is_interactive()) {
    layers <- read_felt_layers(map_id = map_id, token = token)

    if (is_empty(layers)) {
      cli_abort(
        "Felt map supplied must have layers."
      )
    }

    layer_id <- cli_menu(
      choices = layers$attributes$name,
      title = c("*" = "Felt map layers:"),
      message = "{cli::symbol$tick} Enter your selection or
      press {.kbd 0} to exit.",
      prompt = "? Select a layer to delete:",
      exit = 0,
      ind = TRUE
    )

    if (is_null(layer_id)) {
      cli_abort("{.arg layer_id} is required.")
    }

    layer_id <- layers$id[[as.integer(layer_id)]]
  } else if (safely) {
    safety_check(
      "Do you want to delete layer {.val {layer_id}}
      from {.url {map_url}}?",
      message = "Canceled request to delete layer"
    )
  }

  check_string(layer_id, allow_empty = FALSE)

  request_felt(
    endpoint = "delete layer",
    map_id = map_id,
    layer_id = layer_id,
    token = token
  )

  cli_alert_success(
    "Layer {.val {layer_id}} deleted at {.url {map_url}}"
  )
}

#' @name read_felt_layers
#' @rdname create_felt_layer
#' @inheritParams httr2::resp_body_json
#' @export
read_felt_layers <- function(map_id,
                             simplifyVector = TRUE,
                             token = NULL,
                             call = caller_env()) {
  resp <- request_felt(
    endpoint = "read layers",
    map_id = map_id,
    token = token
  )

  layers <- httr2::resp_body_json(
    resp,
    simplifyVector = simplifyVector
  )[["data"]]

  if (is_empty(layers)) {
    cli::cli_alert_danger(
      "No layers found"
    )

    if (simplifyVector) {
      return(invisible(data.frame()))
    }
  }

  layers
}


#' Get Felt layer styles or update layer styles
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Get a Felt layer style or update a layer style. Warning, updating a layer
#' style without a list that can be converted to a valid Felt Style Language
#' (FSL) may get a layer into an *irreversible broken state*.
#'
#' @inheritParams request_felt
#' @param layer_id If `NULL` (default), all layers for the map are used.
#'   Multi-layer maps are not currently supported. Otherwise use a layer ID
#'   string. Use [read_felt_layers()] to list layers for an existing map.
#' @param style A named list that can be converted to a valid Felt Style
#'   Language string. If style is supplied with a datasets id value matching the
#'   layer datasets ids, this function updates an existing layer style. If style
#'   is `NULL` (default), read styles for supplied map and layer. See the
#'   [documentation on the Felt Style
#'   Language](https://feltmaps.notion.site/Felt-Style-Language-de08179cb8494d3d8bbf5fb970f03fd0)
#'   and the [API endpoint for updating layer
#'   styles](https://feltmaps.notion.site/Felt-Public-API-reference-c01e0e6b0d954a678c608131b894e8e1#722105ec74e7492cb934bf81338db8b5)
#'   for more information.
#' @rdname felt_layer_styles
#' @export
felt_layer_styles <- function(map_id,
                              layer_id = NULL,
                              style = NULL,
                              call = caller_env()) {
  layer_id <- layer_id %||%
    read_felt_layers(map_id, call = call)[["id"]]
  check_string(layer_id, allow_empty = FALSE, call = call)

  endpoint <- "get layer style"
  data <- NULL

  if (!is_null(style)) {
    endpoint <- "update layer style"

    cli_ifnot(
      is_list(style) && all(has_name(style, c("datasets", "visualizations"))),
      "{.arg style} must be a list with names {.val datasets}
      and {.val visualizations}",
      .fn = cli::cli_abort,
      call = call
    )

    data <- list("style" = style)
  }

  # FIXME: Create a vectorized version of this for multiple layer_id values
  resp <- request_felt(
    endpoint = endpoint,
    map_id = map_id,
    layer_id = layer_id,
    data = data
  )

  style <- httr2::resp_body_json(resp)[["data"]]

  check_installed("RcppSimdJson")
  RcppSimdJson::fparse(style)
}
