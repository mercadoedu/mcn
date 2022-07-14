#' @title Pipeline matched names
#'
#' @description Connect to ODBC's data source, mount matched names table, update
#'  them and .
#'
#' @param data_source_name A ODBC data source name.
#' @param table_name_from_to_key A string of table name in mercadoedu database.
#' \strong{
#' ```
#' Default: "me_v3_pricing_fromtokey"
#' ```
#' }
#' @param table_name_pricing_course A string of table name in mercadoedu
#'  database.
#' \strong{
#' ```
#' Default: "pricing_course"
#' ```
#' }
#' @param table_name_stopwords A string of stopwords table name in mercadoedu
#'  database.
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
#' @return List with `tables`(`matched_names` and `missmatched_names`) and
#'  `results`(results of `update`, `put` and `delete`).
#'
#' @export
#'
#' @importFrom DBI dbDisconnect
pipeline_matched_names <- function(data_source_name,
                                   table_name_from_to_key,
                                   table_name_pricing_course,
                                   table_name_stopwords,
                                   bucket_name,
                                   objects_prefix,
                                   check = TRUE) {
  # Connect to odbc data source ####
  pipe_con <- connect_dsn(dsn = data_source_name)

  # Mount matched names table ####
  matched_names <- mount_matched_names(
    con = pipe_con,
    tbl_name_ftk = table_name_from_to_key,
    tbl_name_pc = table_name_pricing_course,
    tbl_name_sw = table_name_stopwords,
    bucket_name = bucket_name,
    objects_prefix = objects_prefix,
    check = check
  )

  # Update matched names table ####
  matched_names_updated <- update_matched_names(
    con = pipe_con,
    tbl_mn = matched_names$tables$matched,
    tbl_name_ftk = table_name_from_to_key,
    tbl_name_pc = table_name_pricing_course,
    check = check
  )

  # Closing odbc data source connection ####
  dbDisconnect(conn = pipe_con)

  if (matched_names_updated) {
    s3_csv <- put_csv_s3(
      tbl_mmn = matched_names$tables$missmatched,
      bucket_name = bucket_name
    )

    if (s3_csv) {
      deleted_objects <- delete_objects_s3(
        bucket_objects = matched_names$bucket_objects,
        bucket_name = bucket_name
      )
    }
  }

  list(
    tables = list(
      matched_names = matched_names$tables$matched,
      missmatched_names = matched_names$tables$missmatched
    ),
    results = list(
      update = matched_names_updated,
      put = s3_csv,
      delete = deleted_objects
    )
  )
}

#' @title Pipeline stopwords
#'
#' @description Connect to ODBC's data source, mount stopwords table and update
#'  them.
#'
#' @param data_source_name A PostgreSQL's ODBC connection.
#' @param stopwords_list A list of stopwords as string vector.
#' @param stopwords_wrongs_list A list of wrongs stopwords as string vector.
#' @param table_name_stopwords A string of table name in mercadoedu's database.
#' \strong{
#' ```
#' Default: "stopwords"
#' ```
#' }
#' @param check A logical that defines if check results or not(asking to show).
#' \strong{
#' ```
#' Default: TRUE
#' ```
#' }
#'
#' @return List with `table`(stopwords table) and `update`(result of stopwords
#'  update).
#'
#' @export
#'
#' @importFrom DBI dbDisconnect
pipeline_stopwords <- function(data_source_name,
                               stopwords_list,
                               stopwords_wrongs_list,
                               table_name_stopwords,
                               check = TRUE) {
  # Connect to a odbc data source  ####
  pipe_con <- connect_dsn(dsn = data_source_name)

  # Mount stopwords table ####
  table_stopwords <- mount_stopwords(
    sw_list = stopwords_list,
    sw_wrongs_list = stopwords_wrongs_list,
    check = check
  )

  # Update stopwords table ####
  stopwords_update <- update_stopwords(
    con = pipe_con,
    tbl_sw = table_stopwords,
    tbl_name = table_name_stopwords,
    check = check
  )

  # Closing odbc data source connection ####
  dbDisconnect(pipe_con)

  list(table = table_stopwords, update = stopwords_update)
}
