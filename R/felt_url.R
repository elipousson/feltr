#' Is a object a Felt URL?
#'
#' @param x Object to check.
#' @param allow_null If `TRUE`, [check_felt_url()] allows a `NULL` input without
#'   an error. Defaults to `FALSE`.
#' @inheritParams rlang::args_error_context
#' @export
is_felt_url <- function(x) {
  is_url(x) & grepl("felt.com", x)
}

#' @rdname is_felt_url
#' @name check_felt_url
#' @export
check_felt_url <- function(x,
                           allow_null = FALSE,
                           arg = caller_arg(x),
                           call = caller_env()) {
  check_url(x, allow_null = allow_null, arg = arg, call = call)

  if (is_felt_url(x) || allow_null) {
    return(invisible(NULL))
  }

  stop_input_type(
    x,
    what =  "a valid Felt URL",
    arg = arg,
    call = call
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
felt_map_url_build <- function(map_id = NULL, base_url = "https://felt.com", path = "map", call = caller_env()) {
  if (is_url(map_id)) {
    map_id <- felt_url_parse(map_id, call = call)
  }
  paste0(c(base_url, path, map_id), collapse = "/")
}

#' @noRd
check_url <- function(x,
                      allow_null = FALSE,
                      arg = caller_arg(x),
                      call = caller_env()) {
  if (allow_null && is_null(x)) {
    return(invisible(NULL))
  }

  if (is_url(x)) {
    return(invisible(NULL))
  }

  stop_input_type(
    x,
    what =  "a valid URL",
    arg = arg,
    call = call
  )
}
