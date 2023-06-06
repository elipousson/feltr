# @staticimports pkg:isstatic
# is_url is_geojson_fileext

#' Check Felt URLs
#'
#' @param x,url Object to check.
#' @param message Message passed to [cli::cli_abort()] if url is not a Felt url.
#' @inheritParams rlang::args_error_context
#' @param ... Additional parameters passed to [cli::cli_abort()] if url is not a
#'   Felt url.
#' @export
is_felt_url <- function(x) {
  is_url(x) & grepl("felt.com", x)
}

#' @rdname is_felt_url
#' @name check_felt_url
#' @export
check_felt_url <- function(url,
                           message = "{.arg url} must be a Felt URL.",
                           ...,
                           call = caller_env()) {
  if (is_felt_url(url)) {
    return(invisible(url))
  }

  cli::cli_abort(
    message = message,
    call = call,
    ...
  )
}
