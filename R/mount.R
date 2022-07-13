#' @title Mount matched names
#'
#' @description Mount course names matcheds in a data frame format.
#'
#' @param con A PostgreSQL's ODBC connection to Amazon RDS mercadoedu.
#' @param tbl_name_ftk A string of table name in mercadoedu database.\strong{
#' ```
#' Default: "me_v3_pricing_fromtokey"
#' ```
#' }
#' @param tbl_name_pc A string of table name in mercadoedu database.\strong{
#' ```
#' Default: "pricing_course"
#' ```
#' }
#' @param tbl_name_sw A string of stopwords table name in mercadoedu database.
#' \strong{
#' ```
#' Default: "stopwords"
#' ```
#' }
#' @param bucket_name A string of bucket name in AWS S3.\strong{
#' ```
#' Default: "price-quarentine"
#' ```
#' }
#' @param objects_prefix A string of prefix to filter objects from bucket.
#' \strong{
#' ```
#' Default: "run-AmazonS3_node"
#' ```
#' }
#' @param check A logical that defines if check results or not(asking to show).
#' \strong{
#' ```
#' Default: TRUE
#' ```
#' }
#'
#' @return List with `tables`(`matched` and `missmatched` in data frame format)
#'  and bucket_objects.
#'
#' @export
#'
#' @importFrom cli no
#' @importFrom dplyr anti_join distinct inner_join pull
mount_matched_names <- function(con,
                                tbl_name_ftk = "me_v3_pricing_fromtokey",
                                tbl_name_pc = "pricing_course",
                                tbl_name_sw = "stopwords",
                                bucket_name = "price-quarentine",
                                objects_prefix = "run-AmazonS3_node",
                                check = TRUE) {
  sw_list <- con |>
    get_stopwords(tbl_name = tbl_name_sw)

  n_stopwords <- length(sw_list)

  "{msg_ref(tbl_name_sw)} has {no(n_stopwords)} stopword{?s}." |>
    ui_info()

  tbl_matching_data <- con |>
    get_matching_data(
      tbl_name_ftk = tbl_name_ftk,
      tbl_name_pc = tbl_name_pc
    ) |>
    prep_matching_data(my_stopwords = sw_list)

  n_matching_data <- nrow(tbl_matching_data)

  "{msg_ref('tbl_matching_data')}(created from {msg_ref(tbl_name_ftk)})" |>
    paste("has {no(n_matching_data)} row{?s}.") |>
    ui_info()

  objs <- show_objects_s3(
    bucket_name = bucket_name,
    prefixer = objects_prefix
  )

  n_objects <- length(objs)

  "{msg_ref(bucket_name)} S3 bucket found!" |>
    paste("({no(n_objects)} object{?s} {?were/was/were} found)") |>
    ui_success()

  tbl_entire_quarantine_data <- objs |>
    get_quarantine_data(bucket_name = bucket_name, dist = FALSE)

  tbl_quarantine_data <- tbl_entire_quarantine_data |>
    distinct() |>
    prep_quarantine_data(my_stopwords = sw_list) |>
    anti_join(y = tbl_matching_data, by = c("original_name" = "name_detail"))

  n_quarantine_data <- nrow(tbl_quarantine_data)

  "{msg_ref('tbl_quarantine_data')} has {no(n_quarantine_data)} row{?s}." |>
    ui_info()

  tbl_matched_names <- make_joineds_append(
    tbl_matching = tbl_matching_data,
    tbl_new_names = tbl_quarantine_data
  )

  tbl_missmatched_names <- tbl_quarantine_data |>
    anti_join(tbl_matched_names, by = "original_name")

  n_names <- tbl_matched_names |>
    pull("original_name") |>
    unique() |>
    length()

  "{no(n_names)} name{?s} {?were/was/were} matched." |>
    ui_info(bl = "before")

  tbl_quarantine_data |>
    inner_join(y = tbl_matched_names, by = "original_name") |>
    nrow() |>
    multiplication(100) |>
    division(
      tbl_quarantine_data |>
        nrow()
    ) |>
    round(digits = 2) |>
    ui_percent(type = "names", bl = "after")

  tbl_entire_quarantine_data |>
    inner_join(y = tbl_matched_names, by = "original_name") |>
    nrow() |>
    multiplication(100) |>
    division(
      tbl_entire_quarantine_data |>
        nrow()
    ) |>
    round(digits = 2) |>
    ui_percent(type = "rows")

  if (check) {
    check_matched_names(
      tbl_mn = tbl_matched_names,
      tbl_mmn = tbl_missmatched_names
    )
  }

  list(
    tables = list(
      matched = tbl_matched_names,
      missmatched = tbl_missmatched_names
    ),
    bucket_objects = objs
  )
}

#' @title Mount stopwords data
#'
#' @description Mount stopwords table in a data frame format.
#'
#' @param sw_list A list of stopwords as string vector.
#' @param sw_wrongs_list A list of wrongs stopwords as string vector.
#' @param check A logical that defines if check results or not(asking to show).
#' \strong{
#' ```
#' Default: TRUE
#' ```
#' }
#'
#' @return A stopwords table in data frame format.
#'
#' @export
#'
#' @importFrom abjutils rm_accent
#' @importFrom purrr map2
#' @importFrom stopwords stopwords
#' @importFrom stringr str_squish
#' @importFrom tibble tibble
mount_stopwords <- function(sw_list,
                            sw_wrongs_list,
                            check = TRUE) {
  sw_list_new <- "pt" |>
    rep(3) |>
    c("br") |>
    map2(
      .y = "nltk" |>
        c(
          "snowball",
          rep(
            "stopwords-iso",
            2
          )
        ),
      .f = stopwords
    ) |>
    unlist() |>
    append(values = sw_list) |>
    str_squish() |>
    sort() |>
    unique()

  tbl_stopwords <- sw_list_new |>
    rm_accent() |>
    c(sw_list_new) |>
    sort() |>
    unique() |>
    tibble(
      stopwords = _,
      stopwords_wrongs = ifelse(stopwords %in% sw_wrongs_list, 1, 0)
    )

  if (check) {
    check_stopwords(tbl = tbl_stopwords)
  }

  tbl_stopwords
}
