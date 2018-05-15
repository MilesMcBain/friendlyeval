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
##' @title typed_as_name_lhs
##' @param a_name
##' @return Something that will resolve to a column name when prefixed with `!!`
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

##' Take what was typed for a comma separated list of parameters and pass it to
##' a another function as a comma separated list of column names
##'
##' This is used to pass the literal text the user typed for a list of function
##' parameters and pass it to a dplyr function expecting a list of column names.
##' The most common usage of this is to pass `...`, as in the example provided.
##'
##' This function must be prefixed with `!!!` to declare the output is a list.
##'
##' @title typed_list_as_name_list
##' @param a_list list of column names.
##' @return something that will resolve to a list of column names when prefixed
##'   with `!!!`
##' @examples
##' select_these <- function(dat, ...){
##'  select(dat, !!!typed_list_as_name_list(...))
##' }
##' select_these(mtcars, cyl, wt)
##' @export
typed_list_as_name_list <- rlang::enquos

##' Take the value of a character argument and use it as a column name in a
##' dplyr expression.
##'
##' This is used to take the character value of a function argument and use it
##' in place of a literal column name when calling a dplyr function. This
##' ability is useful when the name of the column to operate on is determined at
##' run-time.
##' @title value_as_name 
##' @param a_value 
##' @return something that will resolve to a column name when prefixed with `!!`.
##' @examples
##' b <- "cyl"
##' mtcars %>%
##'  select(-!!value_as_name(b))
##' @export
value_as_name <- rlang::sym

##' Take a list of characters or character vectors and use the values as column
##' names.
##'
##' This is used to take the character values of a list or vector supplied as a
##' function argument and use them as a comma separated list of column names in
##' a dplyr function. The most common usage would be to used on the values of a
##' single argument, as in the `select_these2` example, however it can also be
##' used with ... to transform all ... values to column names - see
##' `select_these3` example.
##' 
##' @title value_list_as_name_list 
##' @param a_value 
##' @return something that will resolve to a comma separated list of column
##'   names when prefixed with `!!!`.
##' @examples
##' select_these2 <- function(dat, cols){
##'   select(dat, !!!value_list_as_name_list(cols))
##' }
##' select_these2(mtcars, cols = c("cyl", "wt"))
##'
##' select_these3 <- function(dat, ...){
##'  dots <- list(...)
##'  select(dat, !!!value_list_as_name_list(dots))
##' }
##' select_these3(mtcars, "cyl", "wt")
##' 
##' select_not_these <- function(dat, cols){
##'   select(dat, -c(!!!value_list_as_name_list(cols)))
##' }
##' select_not_these(mtcars, cols = c("cyl", "wt"))
##' @export
value_list_as_name_list <- rlang::syms