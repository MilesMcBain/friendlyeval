
#### Testing
library(dplyr)

mutate_this <- function(a_col){
 mutate(mtcars, result = mean(!!typed_as_name(a_col)))
}

mutate_this(cyl)


my_mutate1 <- function(dat, col_name){
  
  mutate(dat,
         !!typed_as_name_lhs(col_name) := 1
         )
}

mtcars %>%
  my_mutate1(cyl1) %>%
  head()

my_mutate2 <- function(dat, col_name){
  
  mutate(dat,
         !!col_name := 1
         )
}


mtcars %>%
  my_mutate2("cyl")

my_mutate <- function(df, expr) {
  expr <- enquo(expr)
  mean_name <- paste0("mean_", quo_name(expr))
  sum_name <- paste0("sum_", quo_name(expr))
  
  mutate(df, 
         !!mean_name := mean(!!expr), 
         !!sum_name := sum(!!expr)
         )
}

my_mutate(mtcars, cyl)

double_col <- function(dat, arg, result){
  ## note usage of ':=' for lhs eval. 
  mutate(dat, !!typed_as_name_lhs(result) := !!typed_as_name(arg)*2)
}

## working call form:
double_col(mtcars, cyl, cylx2) %>%
  head()

double_col <- function(dat, arg, result){
  ## note usage of ':=' for lhs eval. 
  mutate(dat, !!value_as_name(result) := !!value_as_name(arg)*2)
}

## working call form:
double_col(mtcars, arg = 'cyl',  result = 'cylx2')


reverse_group_by <- function(dat, ...){
  groups <- typed_list_as_name_list(...)

  group_by(dat, !!!rev(groups))
}

reverse_group_by(mtcars, gear, am)

reverse_group_by <- function(dat, columns){
  groups <- value_list_as_name_list(columns)

  group_by(dat, !!!rev(groups))
}

reverse_group_by(mtcars, c('gear', 'am'))

reverse_group_by <- function(dat, ...){
  ## note the list() around ... to collect the arguments into a list.
  groups <- value_list_as_name_list(list(...)) 

  group_by(dat, !!!rev(groups))
}

reverse_group_by(mtcars, 'gear', 'am')

### Splicing

select_these <- function(dat, ...){
  select(dat, !!!typed_list_as_name_list(...))
}
select_these(mtcars, cyl, wt)



select_these2 <- function(dat, cols){
  select(dat, !!!value_list_as_name_list(cols))
}
select_these2(mtcars, c("cyl", "wt"))

select_these3 <- function(dat, cols){
  select(dat, -c(!!!value_list_as_name_list(cols)))
}
select_these3(mtcars, c("cyl", "wt"))

select_these4 <- function(dat, ...){
  dots <- list(...)
  select(dat, !!!value_list_as_name_list(dots))
}

select_these4(mtcars, "cyl", "wt")


