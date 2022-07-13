# Testing connection to Amazon RDS mock ####
test_that("connect_dsn() works with Amazon RDS mock data source", {
  # Connecting to Amazon RDS mock ####
  mo_con <- connect_dsn(dsn = sn$mo_dsn_name)

  # "mo_con" is a S4 object with a PostgreSQL class ####
  mo_con |>
    expect_s4_class(class = "PostgreSQL")

  # "mo_con" has the correct catalogs ####
  mo_con |>
    odbc::odbcListObjects() |>
    dplyr::filter(name == sn$mo_catalog_name) |>
    nrow() |>
    as.logical() |>
    expect_true()

  # "mo_catalog_name" catalog has the correct schemas ####
  mo_con |>
    odbc::odbcListObjects(catalog = sn$mo_catalog_name) |>
    dplyr::filter(name == "public") |>
    nrow() |>
    as.logical() |>
    expect_true()

  # "mo_con" has the stopwords table ####
  mo_con |>
    odbc::odbcListObjects(catalog = sn$mo_catalog_name, schema = "public") |>
    dplyr::filter(name == sn$mo_tbl_name_sw) |>
    nrow() |>
    as.logical() |>
    expect_true()

  # "mo_con" has the fromtokey table ####
  mo_con |>
    odbc::odbcListObjects(catalog = sn$mo_catalog_name, schema = "public") |>
    dplyr::filter(name == sn$mo_tbl_name_ftk) |>
    nrow() |>
    as.logical() |>
    expect_true()

  # "mo_con" has the pricing_course table ####
  mo_con |>
    odbc::odbcListObjects(catalog = sn$mo_catalog_name, schema = "public") |>
    dplyr::filter(name == sn$mo_tbl_name_pc) |>
    nrow() |>
    as.logical() |>
    expect_true()

  DBI::dbDisconnect(conn = mo_con)
})

# Testing connection to Amazon RDS mercadoedu ####
test_that("connect_dsn() works with Amazon RDS mercadoedu data source", {
  # Connecting to Amazon RDS mercadoedu ####
  me_con <- connect_dsn(dsn = sn$me_dsn_name)

  # "me_con" is a S4 object with a PostgreSQL class ####
  me_con |>
    expect_s4_class(class = "PostgreSQL")

  # "me_con" has the correct catalogs ####
  me_con |>
    odbc::odbcListObjects() |>
    dplyr::filter(name == sn$me_catalog_name) |>
    nrow() |>
    as.logical() |>
    expect_true()

  # "me_catalog_name" catalog has the correct schemas ####
  me_con |>
    odbc::odbcListObjects(catalog = sn$me_catalog_name) |>
    dplyr::filter(name == "public") |>
    nrow() |>
    as.logical() |>
    expect_true()

  # "me_con" has the stopwords table ####
  me_con |>
    odbc::odbcListObjects(catalog = sn$me_catalog_name, schema = "public") |>
    dplyr::filter(name == sn$me_tbl_name_sw) |>
    nrow() |>
    as.logical() |>
    expect_true()

  # "me_con" has the fromtokey table ####
  me_con |>
    odbc::odbcListObjects(catalog = sn$me_catalog_name, schema = "public") |>
    dplyr::filter(name == sn$me_tbl_name_ftk) |>
    nrow() |>
    as.logical() |>
    expect_true()

  # "me_con" has the pricing_course table ####
  me_con |>
    odbc::odbcListObjects(catalog = sn$me_catalog_name, schema = "public") |>
    dplyr::filter(name == sn$me_tbl_name_pc) |>
    nrow() |>
    as.logical() |>
    expect_true()

  DBI::dbDisconnect(conn = me_con)
})

# Testing connection to a nonexistent data source ####
test_that("connect_dsn() doesn't works with nonexistent data source", {
  # Connect to Amazon RDS mercadoedu ####
  connect_dsn(dsn = "Amazon RDS nonexistent") |>
    expect_error()

  connect_dsn(dsn = c("garbage")) |>
    expect_error()

  connect_dsn(dsn = "Test") |>
    expect_error()
})
