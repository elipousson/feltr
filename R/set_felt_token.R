#' Set or get a Felt API personal access token
#'
#' An API personal access token is required to use [read_felt()]. See
#' <https://feltmaps.notion.site/Felt-Public-API-reference-PUBLIC-c01e0e6b0d954a678c608131b894e8e1>
#' for instructions on how to get a token.
#'
#' @param token Felt personal access token
#' @inheritParams settoken::set_envvar_token
#' @export
#' @importFrom settoken set_envvar_token
set_felt_token <- function(token = NULL,
                           install = FALSE,
                           overwrite = FALSE,
                           default = "FELT_ACCESS_TOKEN") {
  settoken::set_envvar_token(
    token,
    install,
    overwrite,
    default = default
  )
}

#' @rdname set_felt_token
#' @name get_felt_token
#' @export
#' @importFrom settoken get_envvar_token
get_felt_token <- function(token = NULL,
                           default = "FELT_ACCESS_TOKEN",
                           call = caller_env()) {
  settoken::get_envvar_token(
    token,
    default,
    call = call
  )
}
