##' Take what was typed and use it as a column name.
##'
##' This is used inside a function to pass the literal text of what the user typed as an argument to another function. When using dplyr the text will typically be destined will typically be destined for a column name argument. See the select example which passes the literal text given for `a_col` - "cyl" as the argument to `select`.
##' 
##' @title 
##' @param a_value 
##' @return 
##' @examples
##' select_this <- function(a_col){
##'  select(mtcars, !!typed_as_name(a_col))
##' }
##' select_this(cyl)
##' @export
typed_as_name <- rlang::enquo

##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##' @title 
##' @param a_value 
##' @return
##' @examples
##' b <- "cyl"
##' mtcars %>%
##'  select(-!!value_as_name(b))
##' @export
value_as_name <- function(a_value){
  rlang::sym(a_value)
}
