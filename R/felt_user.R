#' Get the user information associated with the default (or supplied) token
#'
#' List the name, email address, and user ID for the Felt user associated with
#' the default (or supplied) token.
#'
#' @inheritParams request_felt
#' @export
felt_user <- function(token = NULL) {
  resp <-
    request_felt(
      endpoint = "read profile",
      token = token
    )

  body <- httr2::resp_body_json(resp)

  cli::cli_dl(c(rev(body[["data"]][["attributes"]]), body[["data"]]["id"]))
  invisible(body)
}
