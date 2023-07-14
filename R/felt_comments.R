#' Get comments from a Felt map
#'
#' Get comments from a Felt map as a data frame or simple feature object. The
#' results include a comment_url column based on the comment ID value.
#'
#' @inheritParams request_felt
#' @param flatten If `TRUE` (default) and comments do not include replies,
#'   flatten the structure of the results so each row contains a comment and a
#'   location. If `FALSE`, comments are included in a list column of data
#'   frames.
#' @param geometry If `TRUE` (default), return a `sf` object. If `FALSE`, return
#'   a data frame.
#' @param crs Coordinate reference system to return (if geometry is `TRUE`),
#'   Default: `NULL`
#' @param simplifyVector Passed to [httr2::resp_body_json()], Default: `TRUE`
#' @return A data frame or simple feature object (with a list column of comments
#'   if flatten is `FALSE`).
#' @details See [Felt API
#'   documentation](https://feltmaps.notion.site/Felt-Public-API-reference-c01e0e6b0d954a678c608131b894e8e1#0d5e58ee84e0445d8484445a27be1d48)
#'   on the endpoint for exporting comments.
#' @rdname get_felt_comments
#' @export
#' @importFrom httr2 resp_body_json
#' @importFrom sf st_point st_as_sf st_transform
get_felt_comments <- function(map_id,
                              flatten = TRUE,
                              geometry = TRUE,
                              crs = NULL,
                              simplifyVector = TRUE,
                              token = NULL) {
  resp <- request_felt(
    endpoint = "get comments",
    map_id = map_id,
    token = token
  )

  body <- httr2::resp_body_json(resp, simplifyVector = simplifyVector)

  comment_rows <- vapply(body[["comments"]], nrow, NA_integer_)

  if (flatten && all(comment_rows == 1)) {
    comments <- body[["comments"]]
    body[["comments"]] <- NULL
    body[["id"]] <- NULL
    body <- cbind(body, list_rbind(comments))
  }

  map_url <- felt_map_url_build(map_id)
  body[["comment_url"]] <- paste0(map_url, "?comment=", body[["id"]])

  if (!geometry) {
    return(body)
  }

  body[["location"]] <- lapply(
    body[["location"]],
    function(x) {
      sf::st_point(rev(x))
    }
  )

  body <- sf::st_as_sf(
    body,
    crs = 4326
  )

  if (is_null(crs)) {
    return(body)
  }

  sf::st_transform(body, crs = crs)
}
