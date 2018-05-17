# friendlyeval
A friendly interface to tidyeval/`rlang` for the casual dplyr user.

This package provides an alternative auto-complete friendly interface to `rlang` that is more closely aligned with the task domain of a user 'programming with dplyr'. It implements most of the cases in the 'programming with dplyr' vignette.

The interface can convert itself to standard `rlang` with the help of an RStudio addin that replaces `friendlyeval` functions with their `rlang` equivalents. This will allow you to prototype in friendly, then subsequently automagically transform to `rlang`. Your friends won't know the difference.

# TODO
I aim to explain the use of `friendyeval` here in simple task-oriented language in under 900 words, meaning the average `dplyr` programmer should know how to use it in under 3 minutes. 
