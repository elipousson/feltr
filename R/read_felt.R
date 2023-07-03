#' Read data from a Felt map
#'
#' `r lifecycle::badge('superseded')`
#'
#' Read simple features from a Felt map or get data embedded in the website of a
#' Felt map. Superseded by [read_felt_map()].
#'
#' @inheritParams read_felt_map
#' @param crs Coordinate reference system to return. Defaults to 3857.
#' @param rename If `TRUE` (default), strip the prefix text "felt-" from all
#'   column names.
#' @param name_repair Passed to repair parameter of [vctrs::vec_as_names()].
#'   Defaults to "check_unique".
#' @inheritParams rlang::args_error_context
#' @returns A simple feature data frame or a list of the parsed JSON found
#'   in the "felt-data" div of a Felt map webpage.
#' @seealso [sf::read_sf()]
#' @rdname read_felt
#' @export
#' @importFrom sf read_sf
#' @importFrom rlang set_names
read_felt <- function(url,
                      map_id = NULL,
                      ...,
                      crs = 3857,
                      token = NULL,
                      rename = TRUE,
                      name_repair = "check_unique") {
  features <- read_felt_map(
    url = url,
    map_id = map_id,
    crs = crs,
    token = token
  )

  if (!rename) {
    return(features)
  }

  rlang::set_names(
    features,
    vctrs::vec_as_names(
      sub("felt-", "", names(features)),
      repair = name_repair
    )
  )
}
