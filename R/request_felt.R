#' Build and perform a request for the Felt API
#'
#' An internal function to help build and perform a request for the Felt API.
#'
#' @inheritParams httr2::request
#' @inheritParams httr2::req_method
#' @inheritParams get_felt_token
#' @param perform If `TRUE` (default), perform the request with
#'   [httr2::req_perform()]. If `FALSE`, return the request object.
#' @keywords internal
#' @importFrom httr2 request req_method req_auth_bearer_token req_error
#'   req_user_agent req_perform
request_felt <- function(base_url = "https://felt.com/api/v1",
                         endpoint = NULL,
                         template = NULL,
                         ...,
                         data = NULL,
                         token = NULL,
                         perform = TRUE,
                         call = caller_env()) {
  req <- httr2::request(base_url)

  if (!is_null(endpoint) || !is_null(template)) {
    req <- req_felt_template(req, endpoint = endpoint, template = template, ...)
  } else {
    req <- httr2::req_url_query(req, ...)
  }

  if (!is_null(data)) {
    if (is_list(data)) {
      data <- vctrs::list_drop_empty(data)
    }

    req <- httr2::req_body_json(req, data = data)
  }

  req <- req_felt_auth(req, token, call)

  if (!perform) {
    return(req)
  }

  httr2::req_perform(req, error_call = call)
}

#' @param map_id A Felt map URL or map ID.
#' @rdname request_felt
#' @name req_felt_template
req_felt_template <- function(req,
                              endpoint = c(
                                "read profile", "create map", "get map",  "read map",
                                "delete map", "get comments", "read layers",
                                "create layer", "update layer", "finish layer",
                                "import url", "delete layer", "get layer style",
                                "update layer style"
                              ),
                              template = NULL,
                              map_id = NULL,
                              ...,
                              call = rlang::caller_env()) {
  if (!is_null(endpoint)) {
    endpoint <- rlang::arg_match(endpoint, error_call = call)
  }

  if (!is_null(map_id)) {
    map_id <- set_map_id(map_id, call = call)
  }

  template <- template %||%
    switch(endpoint,
      "read profile" = "/user",
      "create map" = "/maps",
      "get map" = "/maps/{map_id}",
      "read map" = "/maps/{map_id}/elements",
      "delete map" = "DELETE /maps/{map_id}",
      "get comments" = "/maps/{map_id}/comments/export",
      "read layers" = "/maps/{map_id}/layers",
      "create layer" = "/maps/{map_id}/layers",
      "update layer" = "PATCH /maps/{map_id}/layers/{layer_id}",
      "finish layer" = "/maps/{map_id}/layers/{layer_id}/finish_upload",
      "import url" = "/maps/{map_id}/layers/url_import",
      "delete layer" = "DELETE /maps/{map_id}/layers/{layer_id}",
      "get layer style" = "/maps/{map_id}/layers/{layer_id}/style",
      "update layer style" = "PATCH /maps/{map_id}/layers/{layer_id}/style"
    )

  httr2::req_template(req, template = template, map_id = map_id, ...)
}


#' @noRd
req_felt_auth <- function(req, token, call) {
  req <- httr2::req_auth_bearer_token(
    req,
    token = get_felt_token(
      token,
      call = call
    )
  )

  req <- httr2::req_error(
    req,
    body = function(err) {
      msg <- err[["title"]]

      if (has_name(err, "detail")) {
        msg <- c(msg, "!" = err[["detail"]])
      }

      msg
    }
  )

  httr2::req_user_agent(
    req,
    "feltr (https://github.com/elipousson/feltr)"
  )
}

#' Set map ID
#'
#' @noRd
set_map_id <- function(map_id, call = caller_env()) {
  if (is_url(map_id)) {
    return(felt_url_parse(map_id, call = call))
  }

  check_string(map_id, allow_empty = FALSE, call = call)

  map_id
}

#' @noRd
#' @importFrom httr2 req_url_query
req_url_exec_query <- function(req, params, ..., .env = caller_env()) {
  exec(httr2::req_url_query, req, !!!params, ..., .env = .env)
}
