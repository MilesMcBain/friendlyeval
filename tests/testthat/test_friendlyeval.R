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
      dplyr::mutate(dat, result = !!typed_as_name(arg)*2)
    }
    
    ## working call form:
    double_col(mtcars, cyl)
  },
  {
    double_col <- function(dat, arg){
      dplyr::mutate(dat, result = !!rlang::enquo(arg)*2)
    }
    
    ## working call form:
    double_col(mtcars, cyl)
  })
  
  
  expect_equal_({
    double_col <- function(dat, arg) {
      dplyr::mutate(dat, result = !!value_as_name(arg) * 2)
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
      dplyr::mutate(dat,!!typed_as_name_lhs(result) := !!typed_as_name(arg) * 2)
    }
    
    ## working call form:
    double_col(mtcars, cyl, cylx2)
    
    
  },
  {
    double_col <- function(dat, arg, result) {
      ## note usage of ':=' for lhs eval.
      dplyr::mutate(dat, !!rlang::ensym(result) := !!rlang::enquo(arg) * 2)
    }
    
    ## working call form:
    double_col(mtcars, cyl, cylx2)
  })
  
  expect_equal_({
    double_col <- function(dat, arg, result) {
      ## note usage of ':=' for lhs eval.
      dplyr::mutate(dat, !!value_as_name(result) := !!value_as_name(arg) * 2)
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
      groups <- typed_list_as_name_list(...)
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form
    reverse_dplyr::group_by(mtcars, gear, am)
  },
  {
    reverse_group_by <- function(dat, ...) {
      ## this expression is split out for readability, but it can be nested into below.
      groups <- rlang::enquos(...)
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form
    reverse_dplyr::group_by(mtcars, gear, am)
  })
  
  expect_equal_({
    reverse_group_by <- function(dat, columns) {
      groups <- value_list_as_name_list(columns)
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form:
    reverse_dplyr::group_by(mtcars, c('gear', 'am'))
    
  },
  {
    reverse_group_by <- function(dat, columns) {
      groups <- rlang::syms(columns)
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form:
    reverse_dplyr::group_by(mtcars, c('gear', 'am'))
  })
  
  expect_equal_({
    reverse_group_by <- function(dat, ...) {
      ## note the list() around ... to collect the arguments into a list.
      groups <- value_list_as_name_list(list(...))
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form:
    reverse_dplyr::group_by(mtcars, 'gear', 'am')
    
  },
  {
    reverse_group_by <- function(dat, ...) {
      ## note the list() around ... to collect the arguments into a list.
      groups <- rlang::syms(list(...))
      
      dplyr::group_by(dat, !!!rev(groups))
    }
    
    ## working call form:
    reverse_dplyr::group_by(mtcars, 'gear', 'am')
  })
  
  expect_equal_({
    select_these <- function(dat, ...) {
      dplyr::select(dat, !!!typed_list_as_name_list(...))
    }
    select_these(mtcars, cyl, wt)
    
  },
  {
    select_these <- function(dat, ...) {
      dplyr::select(dat, !!!rlang::enquos(...))
    }
    select_these(mtcars, cyl, wt)
  })
  
  expect_equal_({
    select_these3 <- function(dat, cols) {
      dplyr::select(dat, -c(!!!value_list_as_name_list(cols)))
    }
    select_these3(mtcars, c("cyl", "wt"))
  },
  {
    select_these3 <- function(dat, cols) {
      dplyr::select(dat, -c(!!!rlang::syms(cols)))
    }
    select_these3(mtcars, c("cyl", "wt"))
  })
  
})
