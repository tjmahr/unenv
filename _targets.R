library(targets)
library(tarchetypes)
library(notestar)
# options(tidyverse.quiet = TRUE)
# library(tidyverse)

source("R/functions.R")

tar_option_set(
  packages = c("notestar"),
  imports = c("notestar"),
  controller = crew::crew_controller_local(workers = 4)
)

# Develop your main targets here
targets_main <- list(

)

targets_notebook <- list(
  tar_notebook_index_rmd(
    title = "Unevaluated expressions",
    author = "TJ Mahr",
    bibliography = "refs.bib",
    csl = "apa.csl",
    index_rmd_body_lines =
      "Notes to self and other noodlings. [Main site](https://tjmahr.com/). "
  ),
  tar_notebook_pages(),
  tar_notebook(
    subdir_output = "../../docs",
    markdown_document2_args = list(
      css = "assets/downlit.css"
    ),
    use_downlit = TRUE
  ),

  # the main notebook output is `main.html` because I forget why... So we make
  # `index.html` as a copy of it.
  tar_file(
    book_index,
    {
      file.copy(notebook, "docs/index.html", overwrite = TRUE)
      "docs/index.html"
    }
  ),

  # Remove the following three targets to disable spellchecking
  # or add new exceptions here
  tar_target(
    spellcheck_exceptions,
    c(
      # need a placeholder word so that tests work
      "tibble"
      # add new exceptions here
    )
  ),

  tar_target(
    spellcheck_notebook,
    spelling::spell_check_files(notebook_rmds, ignore = spellcheck_exceptions)
  ),

  # Prints out spelling mistakes when any are found
  tar_force(
    spellcheck_report_results,
    print(spellcheck_notebook),
    nrow(spellcheck_notebook) > 0
  )
)

list(
  targets_main,
  targets_notebook
)
