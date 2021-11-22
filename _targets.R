library(targets)
library(tarchetypes)
library(notestar)
# options(tidyverse.quiet = TRUE)
# library(tidyverse)

source("R/functions.R")

tar_option_set(
  packages = c(
    # "tidyverse",
    "notestar"
  ),
  imports = c("notestar")
)


# Develop your main targets here
targets_main <- list(

)


targets_notebook <- list(
  tar_notebook_pages(
    dir_notebook = "notebook",
    dir_md = "notebook/book",
    notebook_helper = "notebook/book/knitr-helpers.R"
  ),
  # tar_file(notebook_csl_file, "notebook/book/assets/apa.csl"),
  # tar_file(notebook_bib_file, "notebook/book/assets/refs.bib"),
  tar_notebook(
    book_filename = "main",
    subdir_output = "../../docs"
    # extra_deps = list(notebook_csl_file, notebook_bib_file)
  ),

  # If I use book_filename = "index", then "index.Rmd" gets deleted by
  # `delete_merged_file: yes` so this is a hack to make the index.html
  # file
  tar_file(
    book_index,
    {
      file.copy(notebook, "docs/index.html", overwrite = TRUE)
      "docs/index.html"
    }
  ),

  # tar_files(
  #   dir_notebook_output,
  #   {
  #     x <- file.path("notebook/book/docs", list.files("notebook/book/docs"))
  #     # make sure there is a dependency on the notebook file
  #     unique(c(x, notebook))
  #   }
  # ),
  #
  # tar_file(
  #   dir_docs,
  #   {
  #     x_new <- file.path("docs", basename(dir_notebook_output))
  #     x <- file.copy(dir_notebook_output, x_new)
  #     x_new
  #   }
  # ),
  #

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



