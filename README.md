# friendlyeval

[![Travis-CI Build Status](https://api.travis-ci.org/MilesMcBain/friendlyeval.svg?branch=master)](https://travis-ci.org/MilesMcBain/friendlyeval) [![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) 


A friendly interface to tidyeval/`rlang` for the casual dplyr user.

This package provides an alternative auto-complete friendly interface to `rlang` that is more closely aligned with the task domain of a user 'programming with dplyr'. It implements most of the cases in the 'programming with dplyr' vignette.

The interface can convert itself to standard `rlang` with the help of an RStudio addin that replaces `friendlyeval` functions with their `rlang` equivalents. This will allow you to prototype in friendly, then subsequently automagically transform to `rlang`. Your friends won't know the difference.

# Writing Functions that call `dplyr`

`dplyr` functions try to be user-friendly by saving you typing. They allow to one to write code like `mutate(data, col1 = abs(col2), col3 = col4*100)` instead of the more cumbersome base R style: `data$col =abs(data$col2); data$col3 = data$col4*100`.

This cost of this convenience is more work when we want to write functions that call `dplyr` since `dplyr` needs to be instructed how to treat the arguments we pass it. For example this function does not work as we might expect:

```
double_col <- function(dat, arg){
  mutate(dat, result = arg*2)
}

double_col(mtcars, cyl)

# Error in mutate_impl(.data, dots) : 
#   Evaluation error: object 'cyl' not found.
```
Our `double_col` doesn't perform the same special argument handling as `dplyr`.

So we might try:

```
double_col(mtcars, arg = 'cyl')

# Error in mutate_impl(.data, dots) : 
#  Evaluation error: non-numeric argument to binary operator.
```
Those were our only options under normal evaluation rules! There are two ways to make `double_col` work:
1. Instruct `dplyr` to evaluate the literal **input** provided by your caller for the `arg` argument as a **column name**. So `double_col(mtcars, cyl)` would work.
2. Instruct `dplyr` to evaluate the **value** bound to `arg` - "cyl" - as a **column name**, rather than treat it as a normal character vector. So `double_col(mtcars, arg = "cyl")` would work.

`friendlyeval` provides a set of functions and operators for issuing dplyr these kind of instructions about how to evaluate function arguments. 

## Functions

There are four types of things arguments can be evaluated as:
* column names e.g. in `select(mtcars, mpg)`, `mpg` is a column name.
* expressions e.g. in `filter(mtcars, cyl <= 6)`, `cyl <= 6` is an expression.
* lists of column names e.g. in `select(mtcars, mpg, cyl)`, `mpg, cyl` is list of column names 
* lists of expressions. e.g. `filter(mtcars, hp >= mean(hp), wt > 3)`, `hp >= mean(hp), wt > 3` is a list of expressions.

The package contains these 8 functions:
 
 function | usage 
 --- | --- 
 `eval_input_as_col` | Use the text that was input by your function's caller as a `dplyr` column name.
 `eval_inputs_as_cols` | Use a comma separated list of arguments input by your function's caller as a comma separated list of `dplyr` column names.
`eval_input_as_expr` | Use the text that was input by your function's caller as an expression eg: in `filter(dat, col1 == 0)`, `col1 == 0` is an expression involving col1.
`eval_inputs_as_exprs` | Use a comma separated list of expressions input by your function's caller as a list of expressions.
 `eval_value_as_col` | Use the value your function argument takes as a `dplyr` column name.
 `eval_values_as_cols` | Use a list of values as a list of `dplyr` column names.
 `eval_value_as_expr` | Use the value your function argument takes as an expression involving a `dplyr` column name. 
 `eval_values_as_exprs` | Use a list of values as a list of expressions involving `dplyr` column names.
 
    
## Operators

The functions are used with these 3 operators:
 
  * `!!`
  * `!!!`
  * `:=`

`!!` and `!!!` are signposts that tell `dplyr`: *"Stop! This needs to be
evaluated to resolve to one or more column names or expressions"*. 

`!!` tells `dplyr` to expect
a single column name or expression, while `!!!` says to expect a list of column names or expressions.

`:=` is used in place of `=` in the special case where we need to evaluate to
resolve a column name on the left hand side of an `=` like in
`mutate(!!eval_input_as_col(colname) = rownumber)`. Evaluating on the left hand
side in this example is not legal R syntax, so instead we must write:
`mutate(!!eval_input_as_col(colname) := rownumber)`
  
## Usage Examples

### Making `double_col` work
Using what was typed, `dplyr` style:

```
double_col <- function(dat, arg){
  mutate(dat, result = !!eval_input_as_col(arg)*2)
}

## working call form:
double_col(mtcars, cyl)
```

Using supplied value:

```
double_col <- function(dat, arg){
  mutate(dat, result = !!eval_value_as_col(arg)*2)
}

## working call form:
double_col(mtcars, arg = 'cyl')
```

### Supplying column names to be assigned to (lhs variant)
A more useful version of `double_col` allows the name of the result column to be set. Here's using what was typed, `dplyr` style:

```
double_col <- function(dat, arg, result){
  ## note usage of ':=' for lhs eval. 
  mutate(dat, !!eval_input_as_col(result) := !!eval_input_as_col(arg)*2)
}

## working call form:
double_col(mtcars, cyl, cylx2) 
```
And using supplied values:

```
double_col <- function(dat, arg, result){
  ## note usage of ':=' for lhs eval. 
  mutate(dat, !!eval_value_as_col(result) := !!eval_value_as_col(arg)*2)
}

## working call form:
double_col(mtcars, arg = 'cyl',  result = 'cylx2')

```

### Working with argument lists containing column names
When wrapping `group_by` it's likely you'll want to pass a list of column names. Here's how that is done using what was typed, `dplyr` style:

```
reverse_group_by <- function(dat, ...){
  ## this expression is split out for readability, but it can be nested into below.
  groups <- eval_inputs_as_cols(...)

  group_by(dat, !!!rev(groups))
}

## working call form
reverse_group_by(mtcars, gear, am)

```

and using a list of values:
```
reverse_group_by <- function(dat, columns){
  groups <- eval_values_as_cols(columns)

  group_by(dat, !!!rev(groups))
}

## working call form:
reverse_group_by(mtcars, c('gear', 'am'))
```

or using the values of `...`:
```
reverse_group_by <- function(dat, ...){
  ## note the list() around ... to collect the arguments into a list.
  groups <- eval_values_as_cols(list(...)) 

  group_by(dat, !!!rev(groups))
}

## working call form:
reverse_group_by(mtcars, 'gear', 'am')
```

### Passing expressions involving columns
Using the `_expr` functions, you can pass expressions involving column names to `dplyr` functions like `filter`, `mutate` and `summarise`.

For a simple case involving a single expression consider a more general version of the `double_col` function from above, called `double_anything`, that can take expressions involving columns:

``` 
double_anything <- function(dat, arg){
  mutate(dat, result = !!eval_input_as_expr(arg))
}

## working call form:
double_anything(mtcars, cyl*am)

##     mpg cyl  disp  hp drat    wt  qsec vs am gear carb result
## 1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4      6
## 2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4      6
## 3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1      4
## 4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1      0
## 5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2      0
```

A common usage pattern is to take a list of expressions. Consider the `filter_louly` function that reports the number of rows filtered:

```
filter_loudly(mtcars, cyl >= 6, am == 1) 

## Filtered out 27 rows.
##   mpg cyl disp  hp drat    wt  qsec vs am gear carb
## 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## 3 15.8   8  351 264 4.22 3.170 14.50  0  1    5    4
## 4 19.7   6  145 175 3.62 2.770 15.50  0  1    5    6
## 5 15.0   8  301 335 3.54 3.570 14.60  0  1    5    8 
```
You can implement this function using filtering expressions as input by the caller, `dplyr` style:

```
filter_loudly <- function(x, ...){
  in_rows <- nrow(x)
  out <- filter(x, !!!eval_inputs_as_exprs(...))
  out_rows <- nrow(out)
  message("Filtered out ",in_rows-out_rows," rows.")
  return(out)
}

## working call form:
## filter_loudly(mtcars, cyl >= 6, am == 1) 
```

Or using a list/vector of values, parsed as expressions:

```
filter_loudly <- function(x, filter_expressions){
  ## if accepting list arguments, should check all are character
  stopifnot(purrr::every(filter_expressions, is.character))
  
  in_rows <- nrow(x)
  out <- filter(x, !!!eval_values_as_exprs(filter_expressions))
  out_rows <- nrow(out)
  message("Filtered out ",in_rows-out_rows," rows.")
  return(out)
}

## working call form:
## filter_loudly(mtcars, list('cyl >= 6', 1))
```

Or capturing the values of `...`, parsed as expressions:
```
filter_loudly <- function(x, ...){
  dots <- list(...)
  ## if accepting list arguments, should check all are character
  stopifnot(purrr::every(dots, is.character))
  
  in_rows <- nrow(x)
  out <- filter(x, !!!eval_values_as_exprs(dots))
  out_rows <- nrow(out)
  message("Filtered out ",in_rows-out_rows," rows.")
  return(out) 
}

## working call form:
## filter_loudly(mtcars, 'cyl >= 6', 'am == 1')
```
 
## Expressions vs columns
It may have occurred to you that there are cases where a column name is a valid
expression and vice versa. This is true, and it means in some situations you
could switch the `_col` and the `_expr` versions of functions and things would
continue to work. E.g. `input_as_expr` in place of `input_as_col`. Using the
`col` version where appropriate invokes checks that assert what was passed can be
interpreted as a simple column name. This is useful in situations where
expressions are not permitted like in `select` or on the left hand side of the
internal assignment in `mutate`: i.e. `mutate(lhs_col = some_expr)`.
