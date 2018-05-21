# friendlyeval
A friendly interface to tidyeval/`rlang` for the casual dplyr user.

This package provides an alternative auto-complete friendly interface to `rlang` that is more closely aligned with the task domain of a user 'programming with dplyr'. It implements most of the cases in the 'programming with dplyr' vignette.

The interface can convert itself to standard `rlang` with the help of an RStudio addin that replaces `friendlyeval` functions with their `rlang` equivalents. This will allow you to prototype in friendly, then subsequently automagically transform to `rlang`. Your friends won't know the difference.

# TODO
I aim to explain the use of `friendyeval` here in simple task-oriented language in under 900 words, meaning the average `dplyr` programmer should know how to use it in under 3 minutes. 

# Writing Functions that call `dplyr`

`dplyr` functions try to be user-friendly by saving you typing. They allow to one to write code like `mutate(data, col1 = abs(col2), col3 = col4*100)` instead of the more cumbersome base R style: `data$col =abs(data$col2); data$col3 = data$col4*100`.

This cost of this convenience is more work when we want to write functions that call `dplyr` since `dplyr` needs to be instructed not how to treat the arguments we pass it. For example this function does not work as we might expect:

```
double_col <- function(dat, arg){
  mutate(dat, arg*2)
}

double_col(mtcars, cyl)

# Error in mutate_impl(.data, dots) : 
#   Evaluation error: object 'cyl' not found.
```
Our `double_col` doesn't perform the same special argument handling as `dplyr`.

So we might try:

```
double_col(mtcars, arg = "cyl")

# Error in mutate_impl(.data, dots) : 
#  Evaluation error: non-numeric argument to binary operator.
```
That exhausts the options under normal evaluation rules! There are two ways to make `double_col` work:
1. Instruct `dplyr` to use the literal value of whatever expression was **typed** by your caller for the `arg` argument as a column **name**. So `double_col(mtcars, cyl)` would work.
2. Instruct `dplyr` to use the **value** bound to `arg` (`"cyl"`) as a column **name**, rather than treat it as a normal character vector. So `double_col(mtcars, arg = "cyl")` would work.

`friendlyeval` provides a set of functions and operators for issuing dplyr these kind of instructions about how to treat function arguments. It contains these 5 functions:
| function                | usage |
|-------------------------|-------|
| `typed_as_name`           | Use the expression that was typed by your function's caller as a `dplyr` column name.  |
| `typed_as_name_lhs`       | Use the expression that was typed by your function's caller as a `dplyr` column name on the left hand side of an internal assignment eg: `mutate(lhs_col = 1)`.  |
| `typed_list_as_name_list`  | Use a comma separated list of expressions typed by your function's caller as a comma separated list of `dplyr` column names |
| `value_as_name`           | Use the value your function argument takes as a `dplyr` column name |
| `value_list_as_name_list`  | Use a list of values as a list of `dplyr` column names  |
  
Which are used with these 3 operators:
 
  * `!!`
  * `!!!`
  * `:=`
  
## Operators

`!!` and `!!!` are signposts that tell `dplyr`: "Stop! This needs to be evaluated first to resolve to one or more column names". `!!` tells `dplyr` to expect a single column name, while `!!!` says to expect a list of column names. 

`:=` is used in place of `=` in the special case where we need to evaluate to resolve a column name on the left hand side of an `=` like in `mutate(!!typed_as_name_lhs(colname) = rownumber)`. Evaluating on the left hand side in this example is not legal R syntax, so instead we must write: `mutate(!!typed_as_name_lhs(colname) := rownumber)`
  
