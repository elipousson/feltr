% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/felt_data.R
\name{get_felt_data}
\alias{get_felt_data}
\title{Get Felt map data from the body of a map website}
\usage{
get_felt_data(map_id, token = NULL, call = caller_env())
}
\arguments{
\item{map_id}{A Felt map URL, map ID string, or a named list with a id and
type element. If map_id is a list, it must be equivalent to the output from
\code{\link[=get_felt_map]{get_felt_map()}} where the list includes a "id" string and a "type" string
with the value "map".}

\item{token}{Felt personal access token}

\item{call}{The execution environment of a currently
running function, e.g. \code{caller_env()}. The function will be
mentioned in error messages as the source of the error. See the
\code{call} argument of \code{\link[rlang:abort]{abort()}} for more information.}
}
\value{
A list of the parsed JSON found in the "felt-data" div of a Felt map
webpage.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

\code{\link[=get_felt_data]{get_felt_data()}} returns the parsed JSON included in the body of the HTML
for a Felt map website (which includes both features and other user and layer
metadata). This data can be used to supplement the Public API and may be
deprecated as the API develops.
}
