#' @title Update matching data table
#'
#' @description Update a matching data table from database with new matches.
#'
#' @param con A PostgreSQL ODBC connection to Amazon RDS mercadoedu's database.
#' @param tbl_mn A data frame with matched names to be appended.
#' @param tbl_name_ftk A string of `fromtokey table` name in mercadoedu's
#'  database.\strong{
#' ```
#' Default: "me_v3_pricing_fromtokey"
#' ```
#' }
#' @param tbl_name_pc A string of `pricing_course table` name in mercadoedu's
#'  database.\strong{
#' ```
#' Default: "pricing_course"
#' ```
#' }
#' @param check A logical that defines when to check matched names.
#' \strong{
#' ```
#' Default: TRUE
#' ```
#' }
#'
#' @return A logical that warnings if new course names was append or not.
#'
#' @export
#'
#' @importFrom cli cli_abort cli_progress_step cli_progress_update cli_warn
#'  cli_vec
#' @importFrom dplyr anti_join arrange mutate select
#' @importFrom DBI dbWriteTable
update_matched_names <- function(con,
                                 tbl_mn,
                                 tbl_name_ftk = "me_v3_pricing_fromtokey",
                                 tbl_name_pc = "pricing_course",
                                 check = TRUE) {
  if (!is.data.frame(tbl_mn)) {
    "{msg_ref('tbl_mn')} aren't a date frame!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  if (nrow(tbl_mn) == 0) {
    "{msg_ref('tbl_mn')} has 0 rows!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  "Appending the matched names in mercadoedu's database" |>
    cli_progress_step(
      msg_done = "Matched names have been successfully appended!",
      msg_failed = "The matched names appending failed!" |>
        msg_error(),
      spinner = TRUE
    )

  tbl_mn_old <- con |>
    get_matching_data(tbl_name_ftk = tbl_name_ftk, tbl_name_pc = tbl_name_pc)

  appended <- tbl_mn |>
    mutate(discr = "pricing_course_level_1") |>
    select("discr_id", "discr", "arg" = original_name) |>
    dbWriteTable(
      conn = con,
      name = tbl_name_ftk,
      value = _,
      overwrite = FALSE,
      append = TRUE,
      row.names = FALSE
    )

  cli_progress_update()

  if (check && appended) {
    con |>
      get_matching_data(
        tbl_name_ftk = tbl_name_ftk,
        tbl_name_pc = tbl_name_pc
      ) |>
      check_update_matched_names(tbl_mn_old = tbl_mn_old)
  }

  appended
}

#' @title Update stopwords table
#'
#' @description Update a stopwords table from database with new stopwords.
#'
#' @param con A PostgreSQL ODBC connection to Amazon RDS mercadoedu's database.
#' @param tbl_sw A data frame with stopwords to be appended or overwritten.
#' @param tbl_name A string of table name in mercadoedu's database.\strong{
#' ```
#' Default: "stopwords"
#' ```
#' }
#' @param check A logical that defines when to check stopwords.
#' \strong{
#' ```
#' Default: TRUE
#' ```
#' }
#'
#' @return A logical that warnings if stopwords database was updated or not.
#'
#' @export
#'
#' @importFrom cli cli_abort cli_progress_step cli_progress_update cli_warn
#'  cli_vec
#' @importFrom dplyr anti_join
#' @importFrom DBI dbWriteTable
update_stopwords <- function(con,
                             tbl_sw,
                             tbl_name = "stopwords",
                             check = TRUE) {
  if (!is.data.frame(tbl_sw) || nrow(tbl_sw) == 0) {
    "{msg_ref('tbl_sw')} aren't a date frame or has 0 rows!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  if (append) {
    "Appending new stopwords to the stopwords table of mercadoedu's database" |>
      cli_progress_step(
        msg_done = "Stopwords have been successfully appended!",
        msg_failed = "The stopwords appending failed!" |>
          msg_error(),
        spinner = TRUE
      )
  } else {
    "Overwriting the stopwords table of mercadoedu's database" |>
      cli_progress_step(
        msg_done = "Overwriting have been successfully!",
        msg_failed = "The overwriting failed!" |>
          msg_error(),
        spinner = TRUE
      )
  }

  tbl_sw_old <- con |>
    get_stopwords(tbl_name = tbl_name)

  appended <- dbWriteTable(
    conn = con,
    name = tbl_name,
    value = tbl_sw,
    overwrite = TRUE,
    append = FALSE,
    row.names = FALSE
  )

  cli_progress_update()

  if (check && appended) {
    con |>
      get_stopwords(tbl_name = tbl_name) |>
      check_update_stopwords(tbl_sw_old = tbl_sw_old)
  }

  appended
}
