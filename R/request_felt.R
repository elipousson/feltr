#' Build and perform a request for the Felt API
#'
#' @inheritParams httr2::request
#' @inheritParams get_felt_token
#' @keywords internal
request_felt <- function(base_url = "https://felt.com/api/v1",
                         endpoint = NULL,
                         token = NULL,
                         ...,
                         perform = TRUE,
                         call = caller_env()) {
  req <- httr2::request(base_url)

  if (!is_null(endpoint)) {
    req <- req_felt_template(req, endpoint = endpoint, ...)
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
    })

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
                                "list maps", "create layer", "finish layer"
                              ),
                              template = NULL,
                              ...,
                              call = rlang::caller_env()) {
  endpoint <- rlang::arg_match(endpoint, error_call = call)

  template <- template %||%
    switch(endpoint,
      "read profile" = "/user",
      "read map" = "/maps/{map_id}/elements",
      "create map" = "/maps",
      "create layer" = "/maps/{map_id}/layers",
      "finish layer" = "/map/{map_id}/layers/{layer_id}/finish_upload"
    )

  httr2::req_template(req, template = template, ...)
}
