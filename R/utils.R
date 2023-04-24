# @staticimports pkg:isstatic
# is_url is_geojson_fileext

#' Check Felt URLs
#'
#' @keywords internal
#' @export
is_felt_url <- function(x) {
  is_url(x) & grepl("felt.com", x)
}

#' @rdname is_felt_url
#' @name check_felt_url
#' @keywords internal
#' @export
check_felt_url <- function(url,
                           message = "{.arg url} must be a Felt URL.",
                           call = caller_env(),
                           ...) {
  if (is_felt_url(url)) {
    return(invisible(url))
  }

  cli::cli_abort(
    message = message,
    call = call,
    ...
  )
}
