#' Use rasterpic to create a `SpatRaster` object from a Felt map
#'
#' Read an image feature from Felt and use the [rasterpic::rasterpic_img()]
#' function and a corresponding image URL or file path to create a `SpatRaster`
#' object based on the feature geometry.
#'
#' @param x If x is a Felt map URL, it is passed to [read_felt()] to create a
#'   data.frame of features with a "type" and "text" columns. If x is a
#'   data.frame, it is expected to be a data.frame created by reading a Felt map
#'   with [read_felt()] but could be a sf object with a type column that
#'   includes the value "Image" and (if images is named) a text column with
#'   matching text.
#' @param images A vector of image file paths or URLs with a "png", "jpeg/jpg",
#'   or "tiff/tif" file extension. images must be ordered to match the order of
#'   "Image" type features in the input data.frame x or have names that match
#'   the text column for x. If images is named, any "Image" features in x with
#'   text that does not match the names for images are excluded from the
#'   returned list.
#' @inheritParams read_felt
#' @returns If images is length 1, a `SpatRaster` object is returned. Otherwise,
#'   the function returns a list of `SpatRaster` objects of the same length as
#'   images.
#' @export
#' @importFrom sf st_transform
read_felt_raster <- function(x,
                             images,
                             ...,
                             crs = 3857) {
  check_required(x)
  check_required(images)

  if (is_url(x)) {
    x <- read_felt(x, type = "features", crs = crs)
  }

  stopifnot(is.data.frame(x) && all(has_name(x, "type")))

  x <- x[x[["type"]] == "Image", ]

  if (is_named(images)) {
    x <- x[x[["text"]] %in% names(images), ]
    stopifnot(nrow(x) > 0)
  }

  stopifnot(rlang::has_length(images, nrow(x)))

  check_installed("rasterpic")

  raster_images <- lapply(
    seq_len(nrow(x)),
    function(i) {
      if (is_named(images)) {
        img <- images[names(images) == x[i, ][["text"]]][[1]]
      } else {
        img <- images[[i]]
      }

      rasterpic::rasterpic_img(
        x[i, ],
        img
      )
    }
  )

  if (rlang::has_length(raster_images, 1)) {
    return(raster_images[[1]])
  }

  raster_images
}
