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
select_not <- function(dat, arg){
  select(dat, -arg)
}

select_not(mtcats, cyl)
```
`arg` is being interpreted as the name of a column which does not exist. To make this work we can instruct dplyr not to treat 'arg' as a literal column name, but instead as a variable that holds a column name.

`friendlyeval` provides a set of functions and operators for issuing dplyr instructions about how to treat function arguments. It contains these 5 functions:
  
  * `typed_as_name`
  * `typed_as_name_lhs`
  * `typed_list_as_name_list`
  * `value_as_name`
  * `value_list_as_name_list`
  
Which are used with these 3 operators:
 
  * `!!`
  * `!!!`
  * `:=`

## Naming Scheme

The naming scheme is intended to help you identify the function that matches your scenario, `thing1_as_thing2` means use `thing1` from your function's argument(s) and have a dplyr function use it as a `thing2`. The definitions are:

  * `typed` refers to what was typed by the caller of your function in the corresponding argument position. This might be a simple column name like `mpg` or an expression like `mpg*100`.
  * `value` refers to the value of the bound to your function argument.
  * `name` refers to a data frame column name in a `dplyr` function call.
  * `typed_list` is what was typed by the caller of your function for a list of arguments, almost certainly captured by you in `...`
  * `value_list` is a list of argument values supplied by the caller to your function either as separate parameters captured by your function in `...` or as a single list parameter.
  * `name_list` is a comma-separated list of data frame column names in a `dplyr` function call, for example in: `select(dat, colname1, colname2)`, the `name_list` is `colname1, colname2`.
  * `lhs` is an abbreviation for the left hand side of an assignment e.g `colname1` is on the left hand side in `mutate(colname1 = row_number())`
  
Returning to the `select_not()` example above, we need `dplyr` to use the value of `arg` as the name of a column in `dat`. So the `friendlyeval` function needed is `value_as_name`.

## Operators

`!!` and `!!!` are signposts that tell `dplyr`: "Stop. This needs to be evaluated first to resolve to one or more column names". `!!` tells `dplyr` to expect a single column name, while `!!!` says to expect a list of column names. 

`:=` is used in place of `=` in the special case where we need to evaluate to resolve a column name on the left hand side of an `=` like in `mutate(!!typed_as_name_lhs(colname) = rownumber)`. Evaluating on the left hand side in this example is not legal R syntax, so instead we must write: `mutate(!!typed_as_name_lhs(colname) := rownumber)`
  
