#' @title Make join
#'
#' @description A function to make joins.
#'
#' @param tbl_nn A data frame with new names of the courses.
#' @param tbl_db A data frame with the names of the courses.
#' @param by_n A list of variables combination to join.
#' @param n_iter A number of iterations.
#'
#' @return A data frame joined by `by_n`.
#'
#' @importFrom cli cli_progress_step cli_progress_update
#' @importFrom dplyr inner_join mutate
make_join <- function(tbl_nn, tbl_db, by_n, n_iter) {
  bys <- unlist(by_n)

  "Joining by {names(bys)} == {bys} (priority {n_iter})" |>
    cli_progress_step(spinner = TRUE)

  tbl_names_joined <- tbl_nn |>
    inner_join(y = tbl_db, by = bys, keep = TRUE) |>
    mutate("priority" = as.integer(n_iter))

  cli_progress_update()

  tbl_names_joined
}

#' @title Make Joineds Tables Append
#'
#' @description A function to make append of joineds tables.
#'
#' @param tbl_matching A data frame with the names of the courses.
#' @param tbl_new_names A data frame with new names of the courses.
#'
#' @return A data frame with all joins for course names.
#'
#' @importFrom cli cli_alert
#' @importFrom dplyr arrange distinct select
#' @importFrom purrr imap_dfr
make_joineds_append <- function(tbl_matching, tbl_new_names) {
  "Making joins with matching_data:" |>
    cli_alert()

  list(
    c("original_name" = "name_detail"),
    c("original_name_lower" = "name_detail_lower"),
    c("original_name_clean" = "name_detail_clean"),
    c("original_name" = "name_detail_lower"),
    c("original_name" = "name_detail_clean"),
    c("original_name_lower" = "name_detail"),
    c("original_name_lower" = "name_detail_clean"),
    c("original_name_clean" = "name_detail"),
    c("original_name_clean" = "name_detail_lower")
  ) |>
    imap_dfr(
      .f = ~ make_join(
        tbl_nn = tbl_new_names,
        tbl_db = tbl_matching,
        by_n = .x,
        n_iter = .y
      )
    ) |>
    select("name", "discr_id", "original_name", "priority") |>
    arrange(name, discr_id, original_name, priority) |>
    distinct(name, discr_id, original_name) |>
    arrange(discr_id, original_name)
}
