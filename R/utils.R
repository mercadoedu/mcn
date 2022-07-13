# AWS S3 functions ####
#' @title Show objects from S3
#'
#' @description Get objects names inside a AWS S3 Bucket.
#'
#' @param bucket_name A string(name of AWS S3 Bucket).
#' ```
#' Default: "price-quarentine"
#' ```
#' @param prefixer A string(prefix of bucket's objects).
#' ```
#' Default: NULL
#' ```
#'
#' @return A list of objects inside a bucket.
#'
#' @export
#'
#' @importFrom aws.s3 get_bucket
#' @importFrom cli cli_abort cli_warn
#' @importFrom purrr map_chr
#' @importFrom rlang try_fetch
show_objects_s3 <- function(bucket_name = "price-quarentine",
                            prefixer = NULL) {
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

  try_fetch(
    expr = {
      get_bucket(bucket = bucket_name, prefix = prefixer, max = Inf) |>
        map_chr(.f = 1) |>
        paste0()
    },
    error = function(e) {
      "Could not show the objects" |>
        msg_error(color = "white", symbol = "*") |>
        cli_abort(parent = e)
    },
    warning = function(w) {
      cli_warn(message = w)
    }
  )
}

#' @title Import CSV from S3
#'
#' @description Import CSV file object from S3 bucket with vroom package.
#'
#' @param obj_csv A vector character(name of object in S3 bucket).
#' @param obj_n A vector integer(index of object).
#' @param bkt_name A vector character(name of S3 bucket).
#' @param n_max A vector integer(total number of objects).
#' @param id A vector character(id of progress bar) to update.\strong{
#' ```
#' Default: "NULL"
#' ```
#' }
#'
#' @return A S3 file object csv in a data frame format.
#'
#' @export
#'
#' @importFrom aws.s3 s3read_using
#' @importFrom cli cli_abort cli_progress_update cli_warn
#' @importFrom dplyr filter select
#' @importFrom stringr str_detect
#' @importFrom vroom cols vroom
import_csv_s3 <- function(obj_csv, obj_n, bkt_name, n_max, id = NULL) {
  imported_csv <- s3read_using(
    FUN = vroom,
    col_select = c("course", "nome_do_curso"),
    col_types = cols(.default = "c"),
    show_col_types = FALSE,
    progress = FALSE,
    object = obj_csv,
    bucket = bkt_name
  ) |>
    filter(
      is.na(course),
      !is.na(nome_do_curso),
      !str_detect(string = nome_do_curso, pattern = "[:alpha:]", negate = TRUE)
    ) |>
    select("nome_do_curso")

  if (!is.null(id)) {
    cli_progress_update(set = obj_n, id = id)
  }

  imported_csv
}

#' @title Put CSV in S3
#'
#' @description Write a csv file from table and put into the AWS S3 bucket.
#'
#' @param tbl_mmn A data frame with the missmatched names.
#' @param bucket_name A string of bucket name in AWS S3.\strong{
#' ```
#' Default: "price-quarentine"
#' ```
#' }
#'
#' @export
#'
#' @importFrom aws.s3 put_object
#' @importFrom cli cli_abort cli_warn
#' @importFrom rlang try_fetch
#' @importFrom stringr str_replace_all
#' @importFrom vroom vroom_write
put_csv_s3 <- function(tbl_mmn,
                       bucket_name = "price-quarentine") {
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

  try_fetch(
    expr = {
      file_name_date <- paste0(
        "missmatched_names_",
        Sys.time() |>
          as.Date() |>
          str_replace_all("-", "_"),
        ".csv"
      )

      vroom_write(
        x = tbl_mmn,
        file = file_name_date,
        delim = ",",
      )

      put_object(
        file = file_name_date,
        object = file_name_date,
        bucket = bucket_name
      )
    },
    error = function(e) {
      "Could not write the object" |>
        msg_error(color = "white", symbol = "*") |>
        cli_abort(parent = e)
    },
    warning = function(w) {
      cli_warn(message = w)
    }
  )
}

#' @title Delete objects from S3
#'
#' @description Delete objects from the AWS S3 bucket.
#'
#' @param bucket_objects A vector character(name of objects in the AWS S3
#'  bucket).
#' @param bucket_name A string of bucket name in AWS S3.\strong{
#' ```
#' Default: "price-quarentine"
#' ```
#' }
#'
#' @export
#'
#' @importFrom aws.s3 delete_object
#' @importFrom cli cli_abort cli_warn
#' @importFrom rlang try_fetch
delete_objects_s3 <- function(bucket_objects,
                              bucket_name = "price-quarentine") {
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

  try_fetch(
    expr = {
      delete_object(
        object = bucket_objects,
        bucket = bucket_name
      )
    },
    error = function(e) {
      "Could not delete the objects" |>
        msg_error(color = "white", symbol = "*") |>
        cli_abort(parent = e)
    },
    warning = function(w) {
      cli_warn(message = w)
    }
  )
}


# Begin Exclude Linting
# dbplyr functions ####
#' @importFrom dbplyr dbplyr_edition
#' @export
dbplyr_edition.myConnectionClass <- function(con) 2L
# End Exclude Linting


# Math functions ####
#' @title Subtraction function
#'
#' @description Subtract values.
#'
#' @param ... The values to be subtracted (will be concatenated with `c()`).
#'
#' @return The number resulting from the subtraction.
#'
#' @importFrom purrr reduce
subtraction <- function(...) {
  ... |>
    c() |>
    reduce(`-`)
}

#' @title Multiplication function
#'
#' @description Multiplies values.
#'
#' @param ... The values to be multiplied (will be concatenated with `c()`).
#'
#' @return The number resulting from the multiplication.
#'
#' @importFrom purrr reduce
multiplication <- function(...) {
  ... |>
    c() |>
    reduce(`*`)
}

#' @title Division function
#'
#' @description Divide values.
#'
#' @param ... The values to be divided (will be concatenated with `c()`).
#'
#' @return The number resulting from the division.
#'
#' @importFrom purrr reduce
division <- function(...) {
  ... |>
    c() |>
    reduce(`/`)
}

# Globals variables ####
c(
  "arg",
  "color"
  "course",
  "discr",
  "discr_id",
  "id",
  "level",
  "name",
  "name_detail",
  "name_detail_lower",
  "nome_do_curso",
  "original_name",
  "original_name_lower",
  "priority",
  "stopwords_wrongs",
  "table_name_fromtokey",
  "ui_matched",
  "ui_missmatched",
  "wrong_stopwords_list"
) |>
  utils::globalVariables()

# String functions ####
#' @title Correct and lowercase
#'
#' @description Correct some characters errors with str_replace_all and
#' lower them.
#'
#' @param string A vector character.
#'
#' @return A string corrected and lowered.
#'
#' @importFrom stringr str_replace_all str_to_lower
correct_n_lower <- function(string) {
  string |>
    str_replace_all(r"(\u00e3\u00aa)", r"(\u00ea)") |>
    str_replace_all(r"(\u00e3\u00a1)", r"(\u00e1)") |>
    str_replace_all(r"(\u00e3\u00a3)", r"(\u00e3)") |>
    str_replace_all(r"(\u00e3\u00a7)", r"(\u00e7)") |>
    str_replace_all(r"(\u00e3\u00a9)", r"(\u00e9)") |>
    str_replace_all(r"(\u00e3\u00ad)", r"(\u00ed)") |>
    str_replace_all(r"(\u00e3\u00ba)", r"(\u00fa)") |>
    str_replace_all(r"(\u00e3\u00b3)", r"(\u00f3)") |>
    str_replace_all("alimentosnovo", "alimentos") |>
    str_replace_all(
      r"(superiorgest\u00e3o)",
      r"(superior gest\u00e3o)"
    ) |>
    str_replace_all(
      pattern = paste0(
        "([:punct:])|",
        "([:digit:])|",
        "(\\|)|",
        "(\u00aa)|",
        "(\u00ba)|",
        "(\u00b0)"
      ),
      replacement = " "
    ) |>
    str_to_lower(locale = "br")
}

#' @title Clear string
#'
#' @description Removing stopwords, accents and squishing.
#'
#' @param string A vector character.
#' @param my_stopwords A vector character with stopwords.
#'
#' @return A string corrected.
#'
#' @importFrom abjutils rm_accent
#' @importFrom grDevices colors
#' @importFrom stringr str_squish
#' @importFrom tm removeWords
clear_n_squish <- function(string, my_stopwords) {
  string |>
    removeWords(words = my_stopwords) |>
    rm_accent() |>
    str_squish()
}

#' @title Valid percent
#'
#' @description Check it out if it is a valid percentage(not null, is numeric
#'  and be between 0 and 100).
#'
#' @param x A number.
#'
#' @return A logical.
valid_percent <- function(x) {
  if (is.null(x) || !is.numeric(x) || x < 0 || x > 100) {
    FALSE
  } else {
    TRUE
  }
}

#' @title Valid string
#'
#' @description Check it out if it is a valid string(not null, is character and
#'  the length is more than 1).
#'
#' @param x A string.
#'
#' @return A logical.
valid_string <- function(x) {
  if (is.null(x) || !is.character(x) || length(x) != 1) {
    FALSE
  } else {
    TRUE
  }
}

#' @title Valid blank line option
#'
#' @description Check it out if it is a valid blank line option(if is a valid
#'  string or if are in the options).
#'
#' @param bl A string.
#' @param bl_options A vector character with the options.
#'
#' @return A logical.
valid_bl <- function(bl, bl_options) {
  if (valid_string(bl) || !(bl %in% bl_options)) {
    FALSE
  } else {
    TRUE
  }
}

#' @title Has hex color
#'
#' @description Check if the string is a hexadecimal color(have length equals to
#'  7 and starts with `#`).
#'
#' @param x A string with a hexadecimal color.
#'
#' @return A logical.
has_hex_color <- function(x) {
  start_with_hastag <- str_detect(string = x, pattern = "^#")

  if (start_with_hastag && length(x) == 7) {
    TRUE
  } else {
    FALSE
  }
}

#' @title Has color
#'
#' @description Check it out if it has the color(in colors list or in
#'  hexadecimal).
#'
#' @param x A string with a hexadecimal color.
#'
#' @return A logical.
has_color <- function(x) {
  if (x %in% colors() || has_hex_color(x)) {
    TRUE
  } else {
    FALSE
  }
}

#' @title Valid color
#'
#' @description Check it out if it is a valid color(it has the color list, or it
#'  is a hexadecimal color).
#'
#' @param x A string with a color name or a hexadecimal color(with or without
#'  hashtag).
#'
#' @return A logical.
valid_color <- function(x) {
  if (has_color(x) || nchar(x) == 6) {
    TRUE
  } else {
    FALSE
  }
}
