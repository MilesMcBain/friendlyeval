##' Take what was typed and use it as a column name argument in a dplyr
##' function.
##'
##' This is used inside a function to pass the literal text of what the user
##' typed as an argument to another function. When using dplyr the text will
##' typically be destined for a column name argument. See examples for usage
##' scenarios.
##' 
##' @title typed_as_name
##' @param a_name the argument for which the user typed text that is to be used
##'   as a column name.
##' @return Something that will resolve to a column named when prefixed with !!.
##' @examples
##' select_this <- function(a_col){
##'  select(mtcars, !!typed_as_name(a_col))
##' }
##' select_this(cyl)
##'
##' mutate_this <- function(a_col){
##'  mutate(mtcars, result = mean(!!typed_as_name(a_col)))
##' }
##' mutate_this(cyl)
##' 
##' @export
typed_as_name <- rlang::enquo


##' Take what was typed and use it as a column name argument in dplyr on the
##' left hand side of an equality. 
##'
##' This is used inside a function to pass the literal text of what the user
##' typed as a function argument to another function. This function applies in
##' the special case that the text is intended to be used on the left hand side
##' of an an equality. For example to replace `my_col` in `mutate(my_col = pi)`.
##' In this case the call must be rewritten as
##' `mutate(!!typed_as_name_lhs(my_col) := pi)`. Note the usage of `:=`. This is
##' an additional requirement when using !! on the left hand side of an
##' equality.
##' @title 
##' @param arg 
##' @return 
##' @examples
##'
##' my_mutate1 <- function(dat, col_name){
##'
##' mutate(dat,
##'       !!typed_as_name_lhs(colname) := 1
##'       )
##' }
##'
##' mtcars %>%
##'   my_mutate1(cyl)
##' @export
typed_as_name_lhs <- function(arg){
  quo_name(eval.parent(enquo(arg)))
}


##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##' @title  
##' @param a_value 
##' @return
##' @examples
##' @export
typed_list_as_name_list <- rlang::enquos

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
value_as_name <- rlang::sym

##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##' @title  
##' @param a_value 
##' @return
##' @examples
##' @export
value_list_as_name_list <- rlang::syms
