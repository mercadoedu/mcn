#' @title Connect to RDS Databases
#'
#' @description Use a data source name to connect on AWS RDS Database.
#'
#' @param dsn A string of mercadoedu data source name in ODBC.\strong{
#' ```
#' Default: "Amazon RDS mercadoedu"
#' ```
#' }
#'
#' @return The connection of AWS RDS Database.
#'
#' @export
#'
#' @importFrom cli cli_abort cli_progress_step cli_progress_update cli_warn
#' @importFrom DBI dbConnect
#' @importFrom dplyr filter
#' @importFrom odbc odbc odbcListDataSources
#' @importFrom rlang try_fetch
connect_dsn <- function(dsn = "Amazon RDS mercadoedu") {
  have_dsn <- odbcListDataSources() |>
    filter(name == dsn) |>
    nrow() |>
    as.logical()

  if (!have_dsn) {
    "{msg_ref(dsn)} data source not found!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  if (Sys.getenv("RDS_PWD") == "") {
    "{msg_ref('RDS_PWD')} environment variable is not set!" |>
      msg_error(symbol = "x") |>
      cli_abort()
  }

  "Connecting with {msg_ref(dsn)} data source..." |>
    cli_progress_step(
      msg_done = "{msg_ref(dsn)} data source have been successfully connected!",
      msg_failed = "Connection to {msg_ref(dsn)} data source failed!" |>
        msg_error(),
      spinner = TRUE
    )

  try_fetch(
    expr = {
      dbConnect(
        drv = odbc(),
        dsn = dsn,
        PWD = Sys.getenv("RDS_PWD")
      )
    },
    error = function(e) {
      "Could not connect to database" |>
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
