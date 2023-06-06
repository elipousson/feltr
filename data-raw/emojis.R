## code to prepare `emojis` dataset goes here
library(tidyverse)

# url <- "https://cdn.jsdelivr.net/npm/emoji-picker-element-data@1.3.0/en/emojibase/data.json"
# data <- jsonlite::read_json(url, TRUE)
# data <- left_join(data, emojis, by = c("annotation" = "name"))

url <- "https://raw.githubusercontent.com/missive/emoji-mart/main/packages/emoji-mart-data/sets/5/native.json"

data <- jsonlite::read_json(url, simplifyVector = TRUE)

emojis <- dplyr::bind_rows(
  map(
    data$emojis,
    ~ data.frame(
      id = .x$id,
      name = .x$name,
      version = .x$version
    )
  )
) #|> View()

emojis$keywords <- map(seq_along(data$emojis), ~ data$emojis[[.x]]$keyword)

aliases <- data$aliases |> enframe()

aliases <- rename(aliases, id = value, alias = name)
aliases$id <- as.character(aliases$id)

emojis <- emojis |>
  left_join(aliases)

emojis_reference <- emojis

usethis::use_data(emojis_reference, overwrite = TRUE)
