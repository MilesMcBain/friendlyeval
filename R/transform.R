.friendlyeval <- new.env(parent=emptyenv())
.friendlyeval$transforms <- 
  tibble::tribble(
    ~friendly, ~rlang,
    "treat_input_as_col", "rlang::ensym",
    "treat_inputs_as_cols", "rlang::ensyms",
    "treat_input_as_expr", "rlang::enquo",
    "treat_inputs_as_exprs", "rlang::enquos",
    "treat_string_as_col", "rlang::sym",
    "treat_strings_as_cols", "rlang::syms",
    "treat_string_as_expr", "rlang::parse_expr",
    "treat_strings_as_exprs", "(function(x){rlang::parse_exprs(textConnection(unlist(x)))})"
  )

#' Convert friendlyeval functions to rlang
#'
#' Works on a RStudio document selection if one exists, or the entire
#' active source editor if no selection exists.
#'
#' @return nothing.
#' @export
#'
friendlyeval_to_rlang <- function(){
  
  if (rstudioapi::isAvailable()){
    source_context <- rstudioapi::getSourceEditorContext()
    selection_content <- source_context$selection[[1]]$text
    
    if (nzchar(selection_content)){
      ## replace all friendlyeval functions in selection with rlang
      rlang_content <- replace_friendly(selection_content)
      rstudioapi::modifyRange(location = source_context$selection[[1]]$range, 
                              text = rlang_content,
                              id = source_context$id)
      
    } else {
      ## replace all friendlyeval functions in open document with rlang
      rlang_content <- replace_friendly(source_context$contents)
      rstudioapi::setDocumentContents(text = paste0(rlang_content, collapse = "\n"),
                                      id = source_context$id)
    }
  }
}

replace_friendly <- function(text){
  
  ## replace functions using the map in .friendlyeval$transforms
  rlang_text <- purrr::reduce2(
        .x = .friendlyeval$transforms$friendly,
        .y = .friendlyeval$transforms$rlang,
        .f = function(text, friendly, rlang){
          gsub(pattern = paste0("\\b",friendly,"\\b"),
               replacement = rlang, x = text)
        },
        .init = text
      )
  
  ## clean up any 'friendlyeval::'
  rlang_text <- gsub('friendlyeval::', '', rlang_text)
  rlang_text
}
