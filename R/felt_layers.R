#' Read layers from a Felt map, delete a layer, or create a new layer
#'
#' Read layers from a Felt map, delete a single layer, or create a new layer
#' from a URL or file. Note that reading layers does not return the layer data
#' only a list of the layers.
#'
#' @inheritParams read_felt_map
#' @inheritParams request_felt
#' @param layer Required. File path or a layer source URL, either a supported
#'   static file or a URL supported by Felt. See
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

    layer_name <- data[["attributes"]][["name"]]
  } else if (file.exists(layer)) {
    resp <- request_felt(
      endpoint = "create layer",
      map_id = map_id,
      data = list(
        file_names = list(basename(layer)),
        name = name
      ),
      token = token
    )

    data <- httr2::resp_body_json(resp)[["data"]]

    req <- httr2::req_body_multipart(
      httr2::request(base_url = data[["attributes"]][["url"]]),
      !!!data[["attributes"]][["presigned_attributes"]],
      file = curl::form_file(layer, name = basename(layer))
    )

    upload_resp <- httr2::req_perform(req)

    finish_resp <- request_felt(
      endpoint = "finish layer",
      map_id = map_id,
      layer_id = data[["attributes"]][["layer_id"]],
      data = list(
        filename = basename(layer)
      ),
      token = token
    )

    layer_name <- name %||% basename(layer)
  }

  map_url <- felt_map_url_build(map_id)

  cli_alert_success(
    "Layer {.val {layer_name}} created at {.url {map_url}}"
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
