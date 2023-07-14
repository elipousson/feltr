#' Get Felt layer styles or update a layer style
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Get one or more Felt layer styles or update a specified layer style. Warning,
#' updating a layer style without a list that can be converted to a valid Felt
#' Style Language (FSL) may get a layer into an *irreversible broken state*.
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
#' @rdname get_felt_style
#' @aliases felt_layer_styles
#' @return If layer_id is `NULL` and the map contains multiple styles or if
#'   layer_id is a character vector, the function returns a list with style
#'   elements named with the layer ID values. If layer_id is a string, the
#'   function returns a named list with a single Felt Style Language
#'   specification.
#' @export
get_felt_style <- function(map_id,
                           layer_id = NULL,
                           call = caller_env()) {
  layer_id <- layer_id %||%
    read_felt_layers(map_id, call = call)[["id"]]

  check_character(layer_id, call = call)

  if (is_string(layer_id)) {
    style <- req_get_felt_style(
      map_id = map_id,
      layer_id = layer_id,
      call = call
    )

    return(style)
  }

  styles <- lapply(
    layer_id,
    function(id) {
      req_get_felt_style(
        map_id = map_id,
        layer_id = id,
        call = call
      )
    }
  )

  set_names(styles, layer_id)
}

#' Helper function to use the get layer style API endpoint
#'
#' @noRd
req_get_felt_style <- function(map_id,
                               layer_id,
                               call = caller_env()) {
  resp <- request_felt(
    endpoint = "get layer style",
    map_id = map_id,
    layer_id = layer_id,
    call = call
  )

  style <- httr2::resp_body_json(resp)[["data"]]

  check_installed("RcppSimdJson")
  RcppSimdJson::fparse(style)
}

#' @rdname get_felt_style
#' @name update_felt_style
update_felt_style <- function(map_id,
                               style,
                               layer_id = NULL,
                               call = caller_env()) {
  layer_id <- layer_id %||%
    read_felt_layers(map_id, call = call)[["id"]]

  check_string(layer_id, allow_empty = FALSE, call = call)

  cli_ifnot(
    is_list(style) && all(has_name(style, c("datasets", "visualizations"))),
    "{.arg style} must be a list with names {.val datasets}
      and {.val visualizations}",
    .fn = cli::cli_abort,
    call = call
  )

  resp <- request_felt(
    endpoint = "update layer style",
    map_id = map_id,
    layer_id = layer_id,
    data = list("style" = style)
  )

  httr2::resp_body_json(resp)[["data"]]
}
