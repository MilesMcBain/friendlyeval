% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/friendlyeval.R
\name{treat_strings_as_exprs}
\alias{treat_strings_as_exprs}
\title{treat_strings_as_exprs(arg)}
\usage{
treat_strings_as_exprs(arg)
}
\arguments{
\item{arg}{a vector of strings to be treated as expressions.}
}
\value{
something that will resolve to a list of expressions when prefixed with `!!!`
}
\description{
Treat the string values of a character vector as expressions in a dplyr function.
}
\details{
This will parse a vector of strings and treat them as a list of
expressions to be evaluated in the context of a dplyr function. This may be
convenient when building expressions to evaluate at run time.
}
\examples{
\dontrun{
summarise_uppr <- function(dat, ...){
  ## need to capture a character vector
  dots <- as.character(list(...))
  functions <- tolower(unlist(dots))
  summarise(dat, !!!treat_strings_as_exprs(functions))
}

summarise_uppr(mtcars, 'MEAN(mpg)', 'VAR(mpg)')
}
}
