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
                         data = NULL,
                         token = NULL,
                         ...,
                         perform = TRUE,
                         call = caller_env()) {
  req <- httr2::request(base_url)

  if (!is_null(endpoint) || !is_null(template)) {
    req <- req_felt_template(req, endpoint = endpoint, template = template, ...)
  }

  if (!is_null(data)) {
    req <- httr2::req_body_json(req, data = data)
  }

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
      err[["title"]]
    }
  )

  req <- httr2::req_user_agent(
    req,
    "rairtable (https://github.com/elipousson/feltr)"
  )

  if (!perform) {
    return(req)
  }

  httr2::req_perform(req, error_call = call)
}

#' @noRd
req_felt_template <- function(req,
                              endpoint = c(
                                "read profile", "read map", "create map",
                                "delete map", "list maps", "create layer",
                                "finish layer", "import url", "delete layer"
                              ),
                              template = NULL,
                              ...,
                              call = rlang::caller_env()) {
  if (!is_null(endpoint)) {
    endpoint <- rlang::arg_match(endpoint, error_call = call)
  }

  template <- template %||%
    switch(endpoint,
      "read profile" = "/user",
      "read map" = "/maps/{map_id}/elements",
      "create map" = "/maps",
      "delete map" = "DELETE /maps/{map_id}",
      "create layer" = "/maps/{map_id}/layers",
      "finish layer" = "/map/{map_id}/layers/{layer_id}/finish_upload",
      "import url" = "/maps/{map_id}/layers/url_import",
      "delete layer" = "/maps/{map_id}/layers/{layer_id}"
    )

  httr2::req_template(req, template = template, ...)
}
