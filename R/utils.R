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

#' Extract pattern from a length 1 string
#'
#' @param string Passed to x parameter of [regmatches()]
#' @inheritParams base::regexpr
#' @noRd
string_extract <- function(string, pattern, perl = TRUE) {
  if (is.na(string)) {
    return(NA_character_)
  }

  match <-
    regmatches(
      x = string,
      m = regexpr(
        pattern = pattern,
        text = string,
        perl = perl
      )
    )

  if (is_empty(match)) {
    return(NULL)
  }

  match
}


#' Check if user, confirm action before proceeding
#'
#' Adapted from rairtable package
#'
#' @param yes Character vector of acceptable "yes" response options.
#' @inheritParams cli_ask
#' @noRd
safety_check <- function(safely = NULL,
                         ...,
                         prompt = "Do you want to continue?",
                         yes = c("", "Y", "Yes", "Yup", "Yep", "Yeah"),
                         message = "Aborted. A yes is required to continue.",
                         .envir = parent.frame(),
                         call = rlang::caller_env()) {
  safely <- safely %||% getOption("rairtable.safely", TRUE)
  check_bool(safely, call = call)

  if (is_false(safely)) {
    return(invisible(NULL))
  }

  answer <- cli_ask(
    ...,
    prompt = paste0("?\u00a0", prompt, "\u00a0(Y/n)"),
    .envir = .envir
  )

  if (all(tolower(answer) %in% tolower(yes))) {
    return(invisible(NULL))
  }

  check_character(message, call = call)

  cli_abort(
    message = message,
    .envir = .envir,
    call = call
  )
}

#' Adapted from cliExtras::cli_ask()
#'
#' @noRd
cli_ask <- function(prompt = "?",
                    ...,
                    .envir = rlang::caller_env(),
                    call = .envir) {
  if (!rlang::is_interactive()) {
    cli_abort(
      "User interaction is required.",
      call = call
    )
  }

  if (!rlang::is_empty(rlang::list2(...))) {
    cli::cli_bullets(..., .envir = .envir)
  }
  readline(paste0(prompt, "\u00a0"))
}
