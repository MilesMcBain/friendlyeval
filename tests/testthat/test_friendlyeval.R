context("check friendlyeval equivalent rlang")

test_that("friendlyeval is equivalent to rlang functions", {
  
  # This wrapper is required to test tidyeval in this way.
  # See https://github.com/r-lib/testthat/issues/655
  expect_equal_ <- function(object, expected, ...) {
    force(object)
    force(expected)
    expect_equal(object, expected, ...)
  }
  
  expect_equal_({
    
    double_col <- function(dat, arg){
      dplyr::mutate(dat, result = !!treat_input_as_col(arg)*2)
    }
    
    ## working call form:
    double_col(mtcars, cyl)
  },
  {
    double_col <- function(dat, arg){
      dplyr::mutate(dat, result = !!rlang::ensym(arg)*2)
    }
    
    ## working call form:
    double_col(mtcars, cyl)
  })
  
  
  expect_equal_({
    double_col <- function(dat, arg) {
      dplyr::mutate(dat, result = !!treat_string_as_col(arg) * 2)
    }
    
    ## working call form:
    double_col(mtcars, arg = 'cyl')
    
  },
  {
    double_col <- function(dat, arg) {
      dplyr::mutate(dat, result = !!rlang::sym(arg) * 2)
    }
    
    ## working call form:
    double_col(mtcars, arg = 'cyl')
  })
  
  expect_equal_({
    double_col <- function(dat, arg, result) {
      ## note usage of ':=' for lhs eval.
      dplyr::mutate(dat,!!treat_input_as_col(result) := !!treat_input_as_col(arg) * 2)
    }
    
    ## working call form:
    double_col(mtcars, cyl, cylx2)
    
    
  },
  {
    double_col <- function(dat, arg, result) {
      ## note usage of ':=' for lhs eval.
      dplyr::mutate(dat,!!rlang::ensym(result) := !!rlang::ensym(arg) * 2)
    }
    
    ## working call form:
    double_col(mtcars, cyl, cylx2)
  })
  
  expect_equal_({
    double_col <- function(dat, arg, result) {
      ## note usage of ':=' for lhs eval.
      dplyr::mutate(dat, !!treat_string_as_col(result) := !!treat_string_as_col(arg) * 2)
    }
    
    ## working call form:
    double_col(mtcars, arg = 'cyl',  result = 'cylx2')
    
  },
  {
    double_col <- function(dat, arg, result) {
      ## note usage of ':=' for lhs eval.
      dplyr::mutate(dat, !!rlang::sym(result) := !!rlang::sym(arg) * 2)
    }
    
    ## working call form:
    double_col(mtcars, arg = 'cyl',  result = 'cylx2')
  })
  
  expect_equal_({
    reverse_group_by <- function(dat, ...) {
      ## this expression is split out for readability, but it can be nested into below.
      groups <- treat_inputs_as_cols(...)
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form
    reverse_group_by(mtcars, gear, am)
  },
  {
    reverse_group_by <- function(dat, ...) {
      ## this expression is split out for readability, but it can be nested into below.
      groups <- rlang::ensyms(...)
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form
    reverse_group_by(mtcars, gear, am)
  })
  
  expect_equal_({
    reverse_group_by <- function(dat, columns) {
      groups <- treat_strings_as_cols(columns)
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form:
    reverse_group_by(mtcars, c('gear', 'am'))
    
  },
  {
    reverse_group_by <- function(dat, columns) {
      groups <- rlang::syms(columns)
      
      dplyr::group_by(dat, !!!rev(groups))
    }    
    ## working call form:
    reverse_group_by(mtcars, c('gear', 'am'))
  })
  
  expect_equal_({
    reverse_group_by <- function(dat, ...) {
      ## note the list() around ... to collect the arguments into a list.
      groups <- treat_strings_as_cols(list(...))
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form:
    reverse_group_by(mtcars, 'gear', 'am')
    
  },
  {
    reverse_group_by <- function(dat, ...) {
      ## note the list() around ... to collect the arguments into a list.
      groups <- rlang::syms(list(...))
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    ## working call form:
    reverse_group_by(mtcars, 'gear', 'am')
  })
  
  expect_equal_({
    select_these <- function(dat, ...) {
      dplyr::select(dat, !!!treat_inputs_as_cols(...))
    }
    select_these(mtcars, cyl, wt)
    
  },
  {
    select_these <- function(dat, ...) {
      dplyr::select(dat, !!!rlang::ensyms(...))
    }
    select_these(mtcars, cyl, wt)
  })
  
  expect_equal_({
    select_these3 <- function(dat, cols) {
      dplyr::select(dat, -c(!!!treat_strings_as_cols(cols)))
    }
    select_these3(mtcars, c("cyl", "wt"))
  },
  {
    select_these3 <- function(dat, cols) {
      dplyr::select(dat, -c(!!!rlang::syms(cols)))
    }
    select_these3(mtcars, c("cyl", "wt"))  })
  
  expect_equal_({

    filter_same <- function(dat, x, y) {
      dplyr::filter(dat, !!treat_input_as_col(x) == !!treat_input_as_col(y))
    }

    filter_same(mtcars, carb, gear)
  },
  {
    filter_same <- function(dat, x, y) {
      dplyr::filter(dat, !!rlang::ensym(x) == !!rlang::ensym(y))
    }
    
    filter_same(mtcars, carb, gear)
  })
  
  expect_equal_({
    
    ## processing operations from other notation
    calc_result <- function(dat, operation){
      operation <- gsub('x', '*', operation)
      dplyr::mutate(dat, result = !!treat_string_as_expr(operation))
    }

    calc_result(mtcars, "mpg x hp")
    
  },
  {
    ## processing operations from other notation
    calc_result <- function(dat, operation){
      operation <- gsub('x', '*', operation)
      dplyr::mutate(dat, result = !!rlang::parse_expr(operation))
    }

    calc_result(mtcars, "mpg x hp")
    
  })
  
  expect_equal_({
    
    summarise_uppr <- function(dat, ...){
      ## need to capture a character vector
      dots <- as.character(list(...))
      functions <- tolower(unlist(dots))
      dplyr::summarise(dat, !!!treat_strings_as_exprs(functions))
    }

    summarise_uppr(mtcars, 'MEAN(mpg)', 'VAR(mpg)')
  },
  {
    summarise_uppr <- function(dat, ...){
      ## need to capture a character vector
      dots <- as.character(list(...))
      functions <- tolower(unlist(dots))
      dplyr::summarise(dat, !!!(function(x){rlang::parse_exprs(textConnection(x))})(functions))
    }

    summarise_uppr(mtcars, 'MEAN(mpg)', 'VAR(mpg)')
  })
  
})
