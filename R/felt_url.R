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
                           message = "{.arg url} must be a valid Felt URL.",
                           ...,
                           call = caller_env()) {
  check_string(url, call = call)

  if (!is_url(url)) {
    message <- "{.arg url} must be a valid URL."
  }

  if (is_felt_url(url)) {
    return(invisible(url))
  }

  cli::cli_abort(
    message = message,
    call = call,
    ...
  )
}

#' Parse Felt Map ID from URL
#'
#' @noRd
felt_url_parse <- function(url, call = caller_env()) {
  check_felt_url(url, call = call)
  url_path <- httr2::url_parse(url)[["path"]]
  string_extract(url_path, "(?<=-)[[:alnum:]]+$")
}

#' Build Felt URL
#'
#' @noRd
felt_url_build <- function(..., base_url = "https://felt.com", path = "map") {
  paste0(c(base_url, path, ...), collapse = "/")
}
