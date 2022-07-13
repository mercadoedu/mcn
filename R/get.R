#' @title Get matching data
#'
#' @description Get matching data from "fromtokey" table in mercadoedu's
#' database(AWS RDS).
#'
#' @param con A database connection.
#' @param tbl_name_ftk A string with the name of the fromtokey table in
#' mercadoedu's database.\strong{
#' ```
#' Default: "me_v3_pricing_fromtokey"
#' ```
#' }
#' @param tbl_name_pc A string with the name of the pricing_course table in
#' mercadoedu's database.\strong{
#' ```
#' Default: "pricing_course"
#' ```
#' }
#'
#' @return The matching data in a data frame format.
#'
#' @importFrom cli cli_abort cli_progress_step cli_progress_update cli_warn
#' @importFrom dplyr arrange collect distinct filter inner_join pull relocate
#' select tbl
#' @importFrom odbc odbcListObjects
#' @importFrom rlang try_fetch
get_matching_data <- function(con,
                              tbl_name_ftk = "me_v3_pricing_fromtokey",
                              tbl_name_pc = "pricing_course") {
  catalogs_list <- odbcListObjects(connection = con)

  have_catalog <- catalogs_list |>
    nrow() |>
    as.logical()

  if (have_catalog) {
    catalog_name <- catalogs_list |>
      pull("name")
  } else {
    "No catalog was found!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  schemas_list <- odbcListObjects(
    connection = con,
    catalog = catalog_name
  )

  have_schema <- schemas_list |>
    filter(name == "public") |>
    nrow() |>
    as.logical()

  if (have_schema) {
    schema_name <- "public"
  } else {
    "{msg_ref('public')} schema not found!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  have_tbl_ftk <- con |>
    odbcListObjects(catalog = catalog_name, schema = schema_name) |>
    filter(name == tbl_name_ftk) |>
    nrow() |>
    as.logical()

  if (!have_tbl_ftk) {
    "{msg_ref(tbl_name_ftk)} table not found!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  have_tbl_pc <- con |>
    odbcListObjects(catalog = catalog_name, schema = schema_name) |>
    filter(name == tbl_name_pc) |>
    nrow() |>
    as.logical()

  if (!have_tbl_pc) {
    "{msg_ref(tbl_name_pc)} table not found!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  "Getting matching data..." |>
    cli_progress_step(
      msg_done = "Matching data have been successfully collected!",
      msg_failed = "The collection of matching data failed!" |>
        msg_error(),
      spinner = TRUE
    )

  try_fetch(
    expr = {
      con |>
        tbl(tbl_name_ftk) |>
        filter(
          discr == "pricing_course_level_1",
          arg != "n/c",
          arg != "-new-"
        ) |>
        select("discr_id" = discr_id, "name_detail" = arg) |>
        arrange(discr_id) |>
        distinct() |>
        inner_join(
          y = con |>
            tbl(tbl_name_pc) |>
            filter(level == 1) |>
            select("name", "discr_id" = id) |>
            arrange(discr_id) |>
            distinct(),
          by = "discr_id"
        ) |>
        relocate("name", "discr_id", "name_detail") |>
        collect()
    },
    error = function(e) {
      "Could not collect matching data" |>
        msg_error(color = "white", symbol = "*") |>
        cli_abort(parent = e)
    },
    warning = function(w) {
      cli_warn(message = w)
    },
    finally = {
      cli_progress_update()
    }
  )
}

#' @title Get stopwords
#'
#' @description Get stopwords from "stopwords"(default) table in
#'  mercadoedu's database(AWS RDS).
#'
#' @param con A database connection.
#' @param tbl_name A string with the name of the stopwords table in mercadoedu's
#'  database.\strong{
#' ```
#' Default: "stopwords"
#' ```
#' }
#'
#' @return The stopwords in a list.
#'
#' @importFrom cli cli_abort cli_progress_step cli_progress_update cli_warn
#' @importFrom dplyr filter pull tbl
#' @importFrom odbc odbcListObjects
#' @importFrom rlang try_fetch
get_stopwords <- function(con,
                          tbl_name = "stopwords") {
  catalogs_list <- odbcListObjects(connection = con)

  have_catalog <- catalogs_list |>
    nrow() |>
    as.logical()

  if (have_catalog) {
    catalog_name <- catalogs_list |>
      pull("name")
  } else {
    "No catalog was found!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  schemas_list <- odbcListObjects(
    connection = con,
    catalog = catalog_name
  )

  have_schema <- schemas_list |>
    filter(name == "public") |>
    nrow() |>
    as.logical()

  if (have_schema) {
    schema_name <- "public"
  } else {
    "{msg_ref('public')} schema not found!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  have_tbl <- con |>
    odbcListObjects(catalog = catalog_name, schema = schema_name) |>
    filter(name == tbl_name) |>
    nrow() |>
    as.logical()

  if (!have_tbl) {
    "{msg_ref(tbl_name)} table not found!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  "Getting stopwords data..." |>
    cli_progress_step(
      msg_done = "Stopwords data have been successfully collected!",
      msg_failed = "The collection of stopwords data failed!" |>
        msg_error(),
      spinner = TRUE
    )

  try_fetch(
    expr = {
      con |>
        tbl(tbl_name) |>
        filter(stopwords_wrongs == 0) |>
        pull("stopwords") |>
        sort() |>
        unique()
    },
    error = function(e) {
      "Could not collect stopwords" |>
        msg_error(color = "white", symbol = "*") |>
        cli_abort(parent = e)
    },
    warning = function(w) {
      cli_warn(message = w)
    },
    finally = {
      cli_progress_update()
    }
  )
}

#' @title Get quarantine data
#'
#' @description Get quarantine data from csv files objects in AWS S3 bucket.
#'
#' @param objects A list of string(objects names in S3 bucket).
#' @param bucket_name A string of bucket name in S3.\strong{
#' ```
#' Default: "price-quarentine"
#' ```
#' }
#' @param dist A logical bolean to apply `dplyr::distinct`.\strong{
#' ```
#' Default: "TRUE"
#' ```
#' }
#'
#' @return The quarantine data in a data frame format.
#'
#' @importFrom cli cli_abort cli_progress_bar cli_progress_step
#'  cli_progress_update cli_warn
#' @importFrom dplyr distinct rename
#' @importFrom purrr map2_dfr
#' @importFrom rlang try_fetch
get_quarantine_data <- function(objects,
                                bucket_name = "price-quarentine",
                                dist = TRUE) {
  if (Sys.getenv("AWS_ACCESS_KEY_ID") == "") {
    "{msg_ref('AWS_ACCESS_KEY_ID')} environment variable is not set!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  if (Sys.getenv("AWS_SECRET_ACCESS_KEY") == "") {
    "{msg_ref('AWS_SECRET_ACCESS_KEY')} environment variable is not set!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  if (Sys.getenv("AWS_DEFAULT_REGION") != "us-east-2") {
    "{msg_ref('AWS_DEFAULT_REGION')} environment variable isn't `us-east-2`!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  main_pb_id <- "Downloading objects from {msg_ref(bucket_name)}" |>
    paste(" AWS S3 Bucket...") |>
    cli_progress_step(
      msg_done = "quarantine data have been successfully collected!",
      msg_failed = "The collection of quarantine data failed!" |>
        msg_error(),
      spinner = TRUE
    )

  try_fetch(
    expr = {
      n_objects <- length(objects)

      pb_id <- cli_progress_bar(
        total = n_objects,
        format = "{cli::pb_bar}{cli::pb_percent} ({obj_n}/{n_max})" |>
          paste(
            "{msg_ref(glue({obj_csv}, '.csv'))}",
            sep = "|"
          )
      )

      tbl_quarantine_data <- objects |>
        map2_dfr(
          .y = seq_along(objects),
          .f = import_csv_s3,
          bkt_name = bucket_name,
          id = pb_id,
          n_max = n_objects
        ) |>
        rename("original_name" = nome_do_curso)

      if (dist) {
        tbl_quarantine_data |>
          distinct()
      } else {
        tbl_quarantine_data
      }
    },
    error = function(e) {
      "Could not collect the objects" |>
        msg_error(color = "white", symbol = "*") |>
        cli_abort(parent = e)
    },
    warning = function(w) {
      cli_warn(message = w)
    },
    finally = {
      cli_progress_update(id = main_pb_id)
    }
  )
}
