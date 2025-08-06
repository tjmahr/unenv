# R/functions.R
# Put code that want to source into "_targets.R" here.

# See notebook/2025-08-01.Rmd
get_function_source_lines <- function(f, include_leading_comments = TRUE) {
  f_string <- if (is.character(f)) f else as.character(substitute(f))
  f <- if (is.character(f)) get(f, envir = parent.frame()) else f
  srcref <- attr(f, "srcref")
  src <- attr(srcref, "srcfile")

  if (is.null(srcref)) {
    lines <- deparse(f)
    lines[1] <- paste0(f_string, " <- ", lines[1])
    return(lines)
  }

  line_range <- as.integer(srcref)[c(1, 3)]
  line_start <- line_range[1]
  can_check_comments <- include_leading_comments

  while (can_check_comments && line_start > 1) {
    # fyi: not worrying about indented comments
    has_leading_comment_line <- src$lines[line_start - 1] |> startsWith("#")
    line_start <- line_start - as.integer(has_leading_comment_line)
    can_check_comments <- has_leading_comment_line
  }

  getSrcLines(src, line_start, line_range[2])
}
