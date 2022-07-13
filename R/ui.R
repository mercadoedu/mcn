
# Message functions ####
#' @title Message Reference
#'
#' @description Customized message for references.
#'
#' @param text A vector character(reference in string format to be paste).
#'
#' @return A italic and quoted reference in terminal.
#'
#' @importFrom glue glue_col
msg_ref <- function(text) {
  glue_col("{italic `{text}`}")
}

#' @title Message Error
#'
#' @description Formated text for errors.
#'
#' @param text A vector character(reference in string format to be paste).
#' @param color A vector character(a color).\strong{
#' ```
#' Default: "red"
#' ```
#' }
#' @param symbol A vector character(a symbol e.g.: "*").\strong{
#' ```
#' Default: "NULL"
#' ```
#' }
#'
#' @return The text named with `symbol` icon.
#'
#' @importFrom cli make_ansi_style
#' @importFrom glue glue_col
msg_error <- function(text, color = "red", symbol = NULL) {
  ansi_col <- make_ansi_style(color)

  msg <- glue_col("{bold {ansi_col {text}}}")

  if (is.null(symbol)) {
    msg
  } else {
    names(msg) <- symbol
    msg
  }
}

# UI functions ####
#' @title UI Info
#'
#' @description Customized message for references.
#'
#' @param text A vector character(reference in string format to be paste).
#' @param bl A vector character with position of blank line
#' ("after", "before", "both" or "none").
#' \strong{
#' ```
#' Default: "both"
#' ```
#' }
#'
#' @return A info message formated in terminal.
#'
#' @importFrom cli cat_line cli_abort cli_alert_info
#' @importFrom stringr str_to_lower
ui_info <- function(text, bl = "after") {
  bl_options <- c("before", "after", "both", "none")

  if (!is.null(bl)) {
    bl <- str_to_lower(bl)

    if (valid_bl(bl, bl_options = bl_options)) {
      r"({msg_ref("bl")} must be a valid parameter)" |>
        paste(r"((must be "before", "after" or "both")!)") |>
        msg_error(symbol = "x") |>
        cli_abort(.envir = parent.frame())
    }
  }

  if (valid_bl(bl, bl_options = c("before", "both"))) {
    cat_line()
  }

  cli_alert_info(text, .envir = parent.frame())

  if (valid_bl(bl, bl_options = c("after", "both"))) {
    cat_line()
  }
}

#' @title UI Success
#'
#' @description Customized message for success.
#'
#' @param text A vector character(reference in string format to be paste).
#' @param bl A vector character with position of blank line
#' ("after", "before", "both" or "none").
#' \strong{
#' ```
#' Default: "both"
#' ```
#' }
#'
#' @return A success message with icon in terminal.
#'
#' @importFrom cli cat_line cli_abort cli_alert_success
#' @importFrom stringr str_to_lower
ui_success <- function(text, bl = "none") {
  bl_options <- c("before", "after", "both", "none")

  if (!is.null(bl)) {
    bl <- str_to_lower(bl)

    if (valid_bl(bl, bl_options = bl_options)) {
      r"({msg_ref("bl")} must be a valid parameter)" |>
        paste(r"((must be "before", "after" or "both")!)") |>
        msg_error(symbol = "x") |>
        cli_abort(.envir = parent.frame())
    }
  }
  if (valid_bl(bl, bl_options = c("before", "both"))) {
    cat_line()
  }

  text |>
    cli_alert_success(.envir = parent.frame())

  if (valid_bl(bl, bl_options = c("after", "both"))) {
    cat_line()
  }
}


#' @title UI Function
#'
#' @description Print start/end function message.
#'
#' @param text A vector character (will be printed).
#' @param color A vector character (a color name or a hex color).
#' \strong{
#' ```
#' Default: "#10aff2"
#' ```
#' }
#' @param type A vector character with the type of message ("start" or "end").
#' \strong{
#' ```
#' Default: "start"
#' ```
#' }
#' @param bl A vector character with position of blank line
#' ("after", "before", "both" or "none").
#' \strong{
#' ```
#' Default: "both"
#' ```
#' }
#'
#' @return The function message formated and printed.
#'
#' @importFrom cli cat_line cli_abort cli_rule make_ansi_style
#' @importFrom glue glue glue_col
#' @importFrom stringr str_to_lower
ui_function <- function(text,
                        color = "#10aff2",
                        type = "start",
                        bl = "both") {
  start_time <- Sys.time()

  bl_options <- c("before", "after", "both", "none")

  if (!valid_string(text)) {
    r"({msg_ref("text")} must be a valid parameter (must be a string)!)" |>
      msg_error(symbol = "x") |>
      cli_abort(.envir = parent.frame())
  }

  if (!valid_string(color)) {
    r"({msg_ref("color")} must be a valid parameter (must be a string)!)" |>
      msg_error(symbol = "x") |>
      cli_abort(.envir = parent.frame())
  } else if (!valid_color(color)) {
    r"({msg_ref("color")} must be a valid parameter)" |>
      paste(
        r"((must be a color name or hex color like "FFFFFF" or "#FFFFFFF")!)"
      ) |>
      msg_error(symbol = "x") |>
      cli_abort(.envir = parent.frame())
  }

  if (!valid_string(type)) {
    r"({msg_ref("type")} must be a valid parameter)" |>
      paste(r"((must be "start" or "end")!)") |>
      msg_error(symbol = "x") |>
      cli_abort(.envir = parent.frame())
  } else {
    type <- str_to_lower(type)
  }

  if (!is.null(bl)) {
    bl <- str_to_lower(bl)

    if (!valid_bl(bl, bl_options = bl_options)) {
      r"({msg_ref("bl")} must be a valid parameter)" |>
        paste(r"((must be "before", "after" or "both")!)") |>
        msg_error(symbol = "x") |>
        cli_abort(.envir = parent.frame())
    }
  }

  if (has_color(color)) {
    color_spec <- make_ansi_style(color)
  } else if (nchar(color) == 6) {
    color_spec <- glue("#", color) |>
      make_ansi_style()
  }

  if (type == "start") {
    if (valid_bl(bl, bl_options = c("before", "both"))) {
      cat_line()
    }

    "{bold {color_spec {text}}}" |>
      glue_col() |>
      cli_rule(.envir = parent.frame())

    if (valid_bl(bl, bl_options = c("after", "both"))) {
      cat_line()
    }
  } else if (type == "end") {
    if (valid_bl(bl, bl_options = c("before", "both"))) {
      cat_line()
    }

    "{bold {color_spec {text}}}" |>
      glue_col() |>
      cli_rule(left = "", center = "", .envir = parent.frame())

    if (valid_bl(bl, bl_options = c("after", "both"))) {
      cat_line()
    }
  }

  start_time
}

#' @title UI Percent
#'
#' @description Print a message according to the percent and type.
#'
#' @param percent The value (must be numeric).
#' @param type A vector character with the type of message ("rows" or "names").
#' @param bl A vector character with position of blank line
#' ("after", "before", "both" or "none").
#' \strong{
#' ```
#' Default: "both"
#' ```
#' }
#'
#' @return The message of percentage formated and printed.
#'
#' @importFrom cli cat_line cli_abort cli_alert_info
#' @importFrom glue glue
ui_percent <- function(percent, type, bl = "none") {
  if (!valid_percent(percent)) {
    r"({msg_ref("percent")} must be a valid parameter)" |>
      paste("(must be a number between 0 and 100)!") |>
      msg_error(symbol = "x") |>
      cli_abort(.envir = parent.frame())
  }

  if (!valid_string(type)) {
    r"({msg_ref("type")} must be a valid parameter (must be a string)!)" |>
      msg_error(symbol = "x") |>
      cli_abort(.envir = parent.frame())
  }

  if (valid_bl(bl, bl_options = c("before", "both"))) {
    cat_line()
  }

  if (percent > 0) {
    if (type == "rows") {
      glue("{percent}% of the quarantine data rows were solved!") |>
        cli_alert_info(.envir = parent.frame())
    } else if (type == "names") {
      glue("{percent}% of the quarantine data names were solved!") |>
        cli_alert_info(.envir = parent.frame())
    } else {
      r"({msg_ref("type")} must be a valid parameter)" |>
        paste(r"((must be "rows" or "names")!)") |>
        msg_error(symbol = "x") |>
        cli_abort(.envir = parent.frame())
    }
  } else if (percent <= 0) {
    if (type == "rows") {
      "None of the quarantine data rows were solved!" |>
        cli_alert_info(.envir = parent.frame())
    } else if (type == "names") {
      "None of the quarantine data names were solved!" |>
        cli_alert_info(.envir = parent.frame())
    } else {
      r"({msg_ref("type")} must be a valid parameter)" |>
        paste(r"((must be "rows" or "names")!)") |>
        msg_error(symbol = "x") |>
        cli_abort(.envir = parent.frame())
    }
  }

  if (valid_bl(bl, bl_options = c("after", "both"))) {
    cat_line()
  }
}

#' @title UI match
#'
#' @description Print results by main name.
#'
#' @param id The disc_id value (must be a numeric).
#' @param name A vector character with the label of discr_id (must be a string).
#' @param db A database with the matched names.
#'
#' @return The results as a message formated and printed.
#'
#' @importFrom cli cat_line cli_text
#' @importFrom glue glue glue_col
#' @importFrom dplyr filter pull
#' @importFrom purrr walk
ui_match <- function(id, name, db) {
  id_glue <- glue("({id})")

  cat_line()
  r"({bold {white {cli::symbol$record} {name} {blue {id_glue}}:}})" |>
    glue_col() |>
    cli_text(.envir = parent.frame())

  db |>
    filter(discr_id == id) |>
    pull(var = "original_name") |>
    unique() |>
    walk(
      .f = ~ cli_text(
        "\u00a0\u00a0{cli::symbol$bullet}\u00a0",
        '"',
        .x,
        '"',
        .envir = parent.frame()
      )
    )
}

#' @title UI missmatch
#'
#' @description Print results by main name.
#'
#' @param original_name A vector character with original_name (must be string).
#'
#' @return The results as a message formated and printed.
#'
#' @importFrom cli cat_line cli_text
#' @importFrom glue glue_col
ui_missmatch <- function(original_name) {
  cat_line()

  r"({bold {red {cli::symbol$record}} {white {original_name}}})" |>
    glue_col() |>
    cli_text(.envir = parent.frame())
}
