#' Get comments from a Felt map
#'
#' @inheritParams request_felt
#' @param simplifyVector Passed to [httr2::resp_body_json()], Default: `TRUE`
#' @param geometry If `TRUE`, return a `sf` object. Default: `TRUE`
#' @param crs Coordinated reference system to return (if geometry is TRUE), Default: `NULL`
#' @return A data frame or simple feature object with a list column of comments.
#' @details API documentation <https://feltmaps.notion.site/Felt-Public-API-reference-c01e0e6b0d954a678c608131b894e8e1#0d5e58ee84e0445d8484445a27be1d48>
#' @rdname get_felt_comments
#' @export
#' @importFrom httr2 resp_body_json
#' @importFrom sf st_point st_as_sf st_transform
get_felt_comments <- function(map_id,
                              simplifyVector = TRUE,
                              geometry = TRUE,
                              crs = NULL,
                              token = NULL) {

  resp <- request_felt(
    endpoint = "get comments",
    map_id = map_id,
    token = token
  )

  body <- httr2::resp_body_json(resp, simplifyVector = simplifyVector)

  if (!geometry) {
    return(body)
  }

  body[["location"]] <- lapply(body[["location"]], sf::st_point)

  comments <- sf::st_as_sf(
    body,
    crs = 4326
  )

  if (is_null(crs)) {
    return(comments)
  }

  sf::st_transform(comments, crs = crs)
}
