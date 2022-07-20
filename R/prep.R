#' @title Prepare matching data frame
#'
#' @description Prepare matching data frame, correcting wrong characters,
#' misspelling and squishing names.
#'
#' @param tbl_matching A data frame with matching data.
#' @param my_stopwords A list of stopwords.
#'
#' @return The matching data prepared in a data frame format.
#'
#' @export
#'
#' @importFrom dplyr arrange mutate
prep_matching_data <- function(tbl_matching, my_stopwords) {
  tbl_matching |>
    mutate(
      "name_detail_lower" = name_detail |>
        correct_n_lower(),
      "name_detail_clean" = name_detail_lower |>
        clear_n_squish(my_stopwords)
    ) |>
    arrange(discr_id)
}

#' @title Prepare quarantine data frame
#'
#' @description Prepare quarantine data frame, correcting wrong characters,
#' misspelling and squishing names.
#'
#' @param tbl_quarantine A data frame with quarantine data.
#' @param my_stopwords A list of stopwords.
#'
#' @return The quarantine data prepared in a data frame format.
#'
#' @export
#'
#' @importFrom dplyr mutate
prep_quarantine_data <- function(tbl_quarantine, my_stopwords) {
  tbl_quarantine |>
    mutate(
      "original_name_lower" = original_name |>
        correct_n_lower(),
      "original_name_clean" = original_name_lower |>
        clear_n_squish(my_stopwords)
    )
}
