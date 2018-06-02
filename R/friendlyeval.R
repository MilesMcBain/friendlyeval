##' Take what was input and treat it as a column name argument to a dplyr function.
##'
##' This is used inside a function to pass the literal text of what the caller
##' typed as an argument to a `dplyr` function. When using `dplyr` the text will
##' typically be destined for a column name argument. See examples for usage
##' scenarios.
##'
##' @title treat_input_as_col
##' @usage treat_input_as_col(arg)
##' @param arg the argument for which the literal input text is to be used
##'   as a column name.
##' @return Something that will resolve to a column named when prefixed with !!.
##' @examples
##' \dontrun{
##' select_this <- function(a_col){
##'  select(mtcars, !!treat_input as_col(a_col))
##' }
##' select_this(cyl)
##'
##' mean_this <- function(a_col){
##'  mutate(mtcars, result = mean(!!treat_input_as_col(a_col)))
##' }
##' mean_this(cyl)
##'
##' filter_same <- function(dat, x, y) {
##'  filter(dat, !!treat_input_as_col(x) == !!treat_input_as_col(y))
##' }
##' filter_same(mtcars, carb, gear)
##' }
##' @export
treat_input_as_col <- rlang::ensym


##' Take what was input and treat it as an expression argument to dplyr function.
##'
##' This is used inside a function to pass the literal text of what the caller
##' typed as an expression to a `dplyr` function. These might be
##' logical expressions passed to filter: `filter(dat, col == "example")`, or
##' functions of columns passed to mutate or summarise: `summarise(dat, mean(col))`.
##' 
##' @title treat_input_as_expr
##' @usage treat_input_as_expr(arg) 
##' @param arg the argument for which the literal input text is to be used as an
##'   expression.
##' @return
##' @export
treat_input_as_expr <- rlang::enquo


##' Take the literal text input for a comma separated list of arguments and treat it as list of column names in a dplyr function.
##'
##' The most common usage of this is to pass `...`, from your function directly through to dplyr functions as column names, as in the `select_these` example.
##'
##' This function must be prefixed with `!!!` to treat the output as a list.
##'
##' @title treat_inputs_as_cols
##' @usage treat_inputs_as_cols(...)
##' @param ... a comma separated list of arguments to be treated as column names.
##' @return something that will resolve to a list of column names when prefixed
##'   with `!!!`
##' @examples
##' \dontrun{
##' select_these <- function(dat, ...){
##'  select(dat, !!!treat_inputs_as_cols(...))
##' }
##' select_these(mtcars, cyl, wt)
##' }
##' @export
treat_inputs_as_cols <- function(...){
  eval.parent(rlang::ensyms(...))
}

##' Take the literal text input for a comma separated list of arguments and treat it as a list of expressions in a dplyr function.
##'
##' Common usage of this is to pass `...` from your function directly through to
##' dplyr functions as expressions. This could be a list of filtering
##' expressions for filter: `filter(dat, col1 == "example1", col2 ==
##' "example2")`, or a list of functions of columns to `mutate` or `summarise`:
##' `summarise(dat, mean(col1), var(col1))`
##'
##' This function must be prefixed with `!!!` to treat the output as a list.
##' 
##' @title treat_inputs_as_exprs 
##' @param ... a comma separated list of arguments to be treated as expressions.
##' @return something that will resolve to a list of expressions when prefixed with `!!!`
##' @export
treat_inputs_as_exprs <- function(...){
  eval.parent(rlang::enquos(...))
}

##' Take the a string value and use it as a column name in a
##' dplyr function.
##'
##' This is used to take the string value of a variable and use it
##' in place of a literal column name when calling a dplyr function. This
##' ability is useful when the name of the column to operate on is determined at
##' run-time from data.
##' 
##' @title treat_string_as_col
##' @usage treat_string_as_col(arg)
##' @param arg the argument that holds a value to be used as a column name.
##' @return something that will resolve to a column name when prefixed with `!!`.
##' @examples
##' \dontrun{
##' ## drop this run-time determined column.
##' b <- "cyl"
##'  select(mtcars, -!!treat_string_as_col(b))
##' 
##' ## function double a column
##' double_col <- function(dat, arg) {
##'   dplyr::mutate(dat, result = !!rlang::sym(arg) * 2)
##' }
##' double_col(mtcars, arg = 'cyl')
##'
##' }
##' @export
treat_string_as_col <- function(arg){
  rlang::sym(arg)
}

##' Take a list/vector of strings and use the values as column
##' names.
##'
##' This is used to take the character values of a list or vector and use them
##' as a comma separated list of column names in a dplyr function. The most
##' common usage would be applied yo the values of a single argument, as in the
##' `select_these2` example, however it can also be used with ... to transform
##' all ... values to column names - see `select_these3` example.
##'
##' @title treat_strings_as_cols
##' @usage treat_strings_as_cols(arg)
##' @param arg the argument that holds a list of values to be used as column names.
##' @return something that will resolve to a comma separated list of column
##'   names when prefixed with `!!!`.
##' @examples
##' \dontrun{
##' select_these2 <- function(dat, cols){
##'   select(dat, !!!treat_strings_as_cols(cols))
##' }
##' select_these2(mtcars, cols = c("cyl", "wt"))
##'
##' select_these3 <- function(dat, ...){
##'  dots <- list(...)
##'  select(dat, !!!treat_strings_as_cols(dots))
##' }
##' select_these3(mtcars, "cyl", "wt")
##'
##' select_not_these <- function(dat, cols){
##'   select(dat, -c(!!!treat_strings_as_cols(cols)))
##' }
##' select_not_these(mtcars, cols = c("cyl", "wt"))
##'
##' }
##' @export
treat_strings_as_cols <- function(arg){
  rlang::syms(arg)
}


##' Treat the string value of a variable as an expression in a dplyr function.
##' 
##' This will parse a string and treat it as an expression to be evaluated
##' in the context of a dplyr function call. This may be convenient when
##' building expressions to evaluate at run-time.
##'
##' @title treat_string_as_expr(arg)
##' @usage treat_string_as_expr(arg)
##' @param arg a string to be treated as an expression.
##' @return something that will resolve to an expression when prefixed with `!!`
##' @examples
##' \dontrun{
##' 
##' ## processing operations from other notation 
##' calc_result <- function(dat, operation){
##'   operation <- gsub('x', '*', operation)
##'   mutate(dat, result = !!treat_string_as_expr(operation))
##' }
##' 
##' calc_result(mtcars, "mpg x hp")
##' }
##' 
##' @export
treat_string_as_expr <- rlang::parse_expr

##' Treat the string values of a list or character as expressions in a dplyr function.
##'
##' This will parse a list or vector of strings and treat them as a list of
##' expressions to be evaluated in the context of a dplyr function. This may be
##' convenient when building expressions to evaluate at run time.
##'
##' Note that the current version of `rlang::parse_exprs` does not support
##' list/vector arguments, resulting a convoluted looking transformation from
##' `friendlyeval`. This is fixed in the dev version of `rlang` and will allow a
##' more sane looking conversion in the future.
##' 
##' @title treat_strings_as_exprs(arg)
##' @param arg a list or vector of strings to be treated as expressions.
##' @return something that will resolve to a list of expressions when prefixed with `!!!`
##' @examples
##' \dontrun{
##' summarise_uppr <- function(dat, ...){
##'   dots <- list(...)
##'   functions <- tolower(unlist(dots))
##'   summarise(dat, !!!treat_strings_as_exprs(functions))
##' }
##'
##' summarise_uppr(mtcars, 'MEAN(mpg)', 'VAR(mpg)')
##' }
##' @export
treat_strings_as_exprs <- function(arg){
  (function(x){rlang::parse_exprs(textConnection(unlist(x)))})(arg)
}

treat_strings_as_exprs(c('mean(mpg)','var(mpg)'))
