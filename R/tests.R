
#### Testing
library(dplyr)

mutate_this <- function(a_col){
 mutate(mtcars, result = mean(!!typed_as_name(a_col)))
}

mutate_this(cyl)


my_mutate1 <- function(dat, col_name){
  
  mutate(dat,
         !!typed_as_name_lhs(colname) := 1
         )
}

mtcars %>%
  my_mutate1(cyl)

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

### Splicing

select_these <- function(dat, ...){
  select(dat, !!!typed_list_as_name_list(...))
}
select_these(mtcars, cyl, wt)


select_these2 <- function(dat, cols){
  select(dat, !!!value_list_as_name_list(cols))
}
select_these2(mtcars, c("cyl", "wt"))

select_these3 <- function(dat, ...){
  dots <- list(...)
  select(dat, !!!value_list_as_name_list(dots))
}

select_these3(mtcars, "cyl", "wt")


