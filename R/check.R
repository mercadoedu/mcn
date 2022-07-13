#' @title Check mount matched names
#'
#' @description Ask if you want to show the matched names mounted.
#'
#' @param tbl_mn A data frame with the matched names.
#' @param tbl_mmn A data frame with the missmatched names.
#'
#' @return The check message formated and printed.
#'
#' @importFrom cli cat_line cli_vec
#' @importFrom dplyr pull
#' @importFrom purrr walk walk2
#' @importFrom usethis ui_yeah
check_matched_names <- function(tbl_mn, tbl_mmn) {
  if (nrow(tbl_mn) > 0 || nrow(tbl_mmn) > 0) {
    if (interactive()) {
      if (nrow(tbl_mn) > 0) {
        show_match <- "{cli::symbol$fancy_question_mark}" |>
          paste("Would you like to show the names matched?") |>
          ui_yeah()

        if (show_match) {
          walk2(
            .x = tbl_mn |>
              pull("discr_id") |>
              unique(),
            .y = tbl_mn |>
              pull("name") |>
              unique(),
            .f = ui_matched,
            db = tbl_mn
          )
        }
      }

      cat_line()

      if (nrow(tbl_mmn) > 0) {
        show_missmatch <- "{cli::symbol$fancy_question_mark}" |>
          paste("Would you like to show the names that doesn't match?") |>
          ui_yeah()

        if (show_missmatch) {
          tbl_mmn |>
            pull("original_name") |>
            unique() |>
            walk(.f = ui_missmatched)
        }
      }
    } else {
      if (nrow(tbl_mn) > 0) {
        walk2(
          .x = tbl_mn |>
            pull("discr_id") |>
            unique(),
          .y = tbl_mn |>
            pull("name") |>
            unique(),
          .f = ui_match,
          db = tbl_mn
        )
      }

      cat_line()

      if (nrow(tbl_mmn) > 0) {
        tbl_mmn |>
          pull("original_name") |>
          unique() |>
          walk(.f = ui_missmatch)
      }
    }
  } else {
    ui_info("The matched names and missmatched names are empty.")
  }
}

#' @title Check mount stopwords
#'
#' @description Ask if you want to show the stopwords mounted.
#'
#' @param tbl A data frame with the stopwords.
#'
#' @return The check message formated and printed.
#'
#' @importFrom cli cli_vec
#' @importFrom dplyr pull
#' @importFrom usethis ui_yeah
check_stopwords <- function(tbl) {
  if (nrow(tbl) > 0) {
    sw_vec <- tbl |>
      pull("words") |>
      cli_vec(
        style = list(vec_sep = "', '", vec_last = "' and '", vec_trunc = 999)
      )

    if (interactive()) {
      yeah <- "{cli::symbol$fancy_question_mark}" |>
        paste("Would you like to show the stopwords?") |>
        ui_yeah()

      if (yeah) {
        ui_info("The stopwords are '{sw_vec}'.")
      }
    } else {
      ui_info("The stopwords are '{sw_vec}'.")
    }
    return(invisible(TRUE))
  } else {
    ui_info("The stopwords list are empty.")
    return(invisible(FALSE))
  }
}

#' @title Check update matched names
#'
#' @description Ask if you want to show the matched names updated.
#'
#' @param tbl_mn_old A data frame with the old matching data.
#' @param tbl_mn_new A data frame with the new matching data.
#'
#' @return The check update message formated and printed.
#'
#' @importFrom cli cli_abort cli_vec cli_warn
#' @importFrom dplyr anti_join pull
#' @importFrom purrr walk2
#' @importFrom usethis ui_yeah
check_update_matched_names <- function(tbl_mn_new, tbl_mn_old) {
  if (identical(tbl_mn_old, tbl_mn_new)) {
    "The {msg_ref('me_v3_pricing_fromtokey')} table was not updated!" |>
      cli_warn()
  } else if (!identical(tbl_mn_old, tbl_mn_new)) {
    tbl_mn_diff_new <- tbl_mn_new |>
      anti_join(y = tbl_mn_old)

    tbl_mn_diff_old <- tbl_mn_old |>
      anti_join(y = tbl_mn_new)

    "The {msg_ref('me_v3_pricing_fromtokey')} table was updated!" |>
      ui_success()

    if (nrow(tbl_mn_diff_new) > 0) {
      if (interactive()) {
        yeah_new <- "{cli::symbol$fancy_question_mark}" |>
          paste("Would you like to show course names from table?") |>
          ui_yeah()

        if (yeah_new) {
          walk2(
            .x = tbl_mn_diff_new |>
              pull("discr_id") |>
              unique(),
            .y = tbl_mn_diff_new |>
              pull("name") |>
              unique(),
            .f = ui_match,
            db = tbl_mn_diff_new
          )
        }
      } else {
        walk2(
          .x = tbl_mn_diff_new |>
            pull("discr_id") |>
            unique(),
          .y = tbl_mn_diff_new |>
            pull("name") |>
            unique(),
          .f = ui_match,
          db = tbl_mn_diff_new
        )
      }
    }

    if (nrow(tbl_mn_diff_old) > 0) {
      if (interactive()) {
        yeah_old <- "{cli::symbol$fancy_question_mark}" |>
          paste("Would you like to show course names from table?") |>
          ui_yeah()

        if (yeah_old) {
          walk2(
            .x = tbl_mn_diff_old |>
              pull("discr_id") |>
              unique(),
            .y = tbl_mn_diff_old |>
              pull("name") |>
              unique(),
            .f = ui_match,
            db = tbl_mn_diff_old
          )
        }
      } else {
        walk2(
          .x = tbl_mn_diff_old |>
            pull("discr_id") |>
            unique(),
          .y = tbl_mn_diff_old |>
            pull("name") |>
            unique(),
          .f = ui_match,
          db = tbl_mn_diff_old
        )
      }
    }
  } else {
    "Something goes wrong!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }
}

#' @title Check update stopwords
#'
#' @description Ask if you want to show the stopwords updated.
#'
#' @param tbl_sw_old A data frame with the old stopwords.
#' @param tbl_sw_new A data frame with the new stopwords.
#'
#' @return The check update message formated and printed.
#'
#' @importFrom cli cli_abort cli_vec cli_warn
#' @importFrom dplyr anti_join pull
#' @importFrom usethis ui_yeah
check_update_stopwords <- function(tbl_sw_new, tbl_sw_old) {
  if (identical(tbl_sw_old, tbl_sw_new)) {
    "The {msg_ref('stopwords')} table was not changed!" |>
      cli_warn()
  } else if (!identical(tbl_sw_old, tbl_sw_new)) {
    tbl_sw_diff_new <- tbl_sw_new |>
      anti_join(y = tbl_sw_old, by = "words")

    tbl_sw_diff_old <- tbl_sw_old |>
      anti_join(y = tbl_sw_new, by = "words")

    "The {msg_ref('stopwords')} table was updated!" |>
      ui_success()

    if (nrow(tbl_sw_diff_new) > 0) {
      sw_vec_new <- tbl_sw_diff_new |>
        pull("words") |>
        cli_vec(
          style = list(
            vec_sep = "', '", vec_last = "' and '", vec_trunc = 999
          )
        )

      if (interactive()) {
        yeah_new <- "{cli::symbol$fancy_question_mark}" |>
          paste("Would you like to show the new stopwords added?") |>
          ui_yeah()

        if (yeah_new) {
          ui_info("The stopwords added in the table are '{sw_vec_new}'.")
        }
      } else {
        ui_info("The stopwords added in the table are '{sw_vec_new}'.")
      }
    }

    if (nrow(tbl_sw_diff_old) > 0) {
      sw_vec_old <- tbl_sw_diff_old |>
        pull("words") |>
        cli_vec(
          style = list(
            vec_sep = "', '", vec_last = "' and '", vec_trunc = 999
          )
        )

      if (interactive()) {
        yeah_old <- "{cli::symbol$fancy_question_mark}" |>
          paste("Would you like to show the old stopwords removed?") |>
          ui_yeah()

        if (yeah_old) {
          ui_info("The stopwords inserted on table are '{sw_vec_old}'.")
        }
      } else {
        ui_info("The stopwords inserted on table are '{sw_vec_old}'.")
      }
    }
  } else {
    "Something goes wrong!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }
}
