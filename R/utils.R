# @staticimports pkg:isstatic
# is_url is_geojson_fileext

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
  safely <- safely %||% getOption("feltr.safely", TRUE)
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

  cli_abort(
    message = message,
    .envir = .envir,
    call = call
  )
}

#' Adapted from cliExtras::cli_menu()
#'
#' @noRd
cli_menu <- function(choices,
                     title = NULL,
                     message = "Enter your selection or press {.kbd 0} to exit.",
                     prompt = "Selection:",
                     exit = 0,
                     ind = FALSE,
                     id = NULL,
                     call = .envir,
                     .envir = parent.frame()) {
  check_character(choices)
  choices <- rlang::set_names(choices, seq_along(choices))
  title <- title %||% "Choices:"

  cli::cli({
    cli::cli_bullets(title, id = id, .envir = .envir)
    cli::cli_ol(choices, id = id)
    cli::cli_par()
  })

  choice <- cli_ask(prompt, message, .envir = .envir)

  while (TRUE) {
    if (identical(as.integer(choice), as.integer(exit))) {
      break
    }

    if (choice %in% seq_along(choices)) {
      if (ind) {
        return(choice)
      }

      return(choices[[choice]])
    }

    choice <- cli_ask(prompt = prompt, .envir = .envir)
  }
}

