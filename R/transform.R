friendlyeval_to_rlang <- function(){
  
  if (rstudioapi::isAvailable()){
    source_context <- rstudioapi::getSourceEditorContext()
    transform_content <- source_context$selection[[1]]$text
    if (nzchar(transform_content)){
      replace_target <- transform_content
    } else {
      replace_target <- source_context$contents
    }
  }
}