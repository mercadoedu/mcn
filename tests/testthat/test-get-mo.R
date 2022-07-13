# Connecting to mock data source ####
mo_con <- connect_dsn(dsn = sn$mo_dsn_name)

# Testing mocked matching data ####
test_that("get_matching_data() works with mocked data source", {
  tbl_matching <- get_matching_data(
    con = mo_con,
    tbl_name_ftk = sn$mo_tbl_name_ftk,
    tbl_name_pc = sn$mo_tbl_name_pc
  )

  # "tbl_matching" is a data frame ####
  expect_s3_class(object = tbl_matching, class = "data.frame")

  # "tbl_matching" has > 1510 rows(initial data) ####
  tbl_matching |>
    nrow() |>
    expect_gt(expected = 1510)

  # "tbl_matching" has the correct two columns ####
  tbl_matching |>
    colnames() |>
    expect_equal(
      expected = c(
        "name",
        "discr_id",
        "name_detail"
      )
    )

  # "name" column is a character vector ####
  tbl_matching |>
    dplyr::pull(var = "name") |>
    expect_type(type = "character")

  # "name" column does not have NA ####
  tbl_matching |>
    dplyr::pull(var = "name") |>
    is.na() |>
    any() |>
    expect_false()

  # "name" column has only valid names(letters) ####
  tbl_matching |>
    dplyr::pull(var = "name") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "name" column has only one discr_id per text ####
  tbl_matching |>
    dplyr::group_by(name) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "discr_id" column is an integer vector ####
  tbl_matching |>
    dplyr::pull(var = "discr_id") |>
    expect_type(type = "integer")

  # "discr_id" column does not have NA ####
  tbl_matching |>
    dplyr::pull(var = "discr_id") |>
    is.na() |>
    any() |>
    expect_false()

  # "discr_id" column does not have zero as id ####
  tbl_matching |>
    dplyr::pull(var = "discr_id") |>
    is.element(set = 0) |>
    any() |>
    expect_false()

  # "name_detail" column is a character vector ####
  tbl_matching |>
    dplyr::pull(var = "name_detail") |>
    expect_type(type = "character")

  # "name_detail" column does not have NA ####
  tbl_matching |>
    dplyr::pull(var = "name_detail") |>
    is.na() |>
    any() |>
    expect_false()

  # "name_detail" column has no duplicated names ####
  tbl_matching |>
    dplyr::pull(var = "name_detail") |>
    duplicated() |>
    any() |>
    expect_false()

  # "name_detail" column has only valid names(letters) ####
  tbl_matching |>
    dplyr::pull(var = "name_detail") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "name_detail" column has only one discr_id per text ####
  tbl_matching |>
    dplyr::group_by(name_detail) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)
})

# Testing mocked stopwords data ####
test_that("get_stopwords() works with mocked data source", {
  stopwords_list <- get_stopwords(con = mo_con, tbl_name = sn$mo_tbl_name_sw)

  # "stopwords_list" is a vector character ####
  expect_vector(object = stopwords_list, ptype = character())

  # "stopwords_list" has > 0 elements ####
  stopwords_list |>
    length() |>
    expect_gt(expected = 0)

  # "stopwords_list" does not have NA ####
  stopwords_list |>
    is.na() |>
    any() |>
    expect_false()

  # "stopwords_list" has no duplicate stopwords ####
  stopwords_list |>
    duplicated() |>
    any() |>
    expect_false()

  # "stopwords_list" has only valid stopwords(letters) ####
  stopwords_list |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()
})

# Disconnecting from mock data source ####
DBI::dbDisconnect(conn = mo_con)

# Testing mocked quarantine data ####
test_that("get_quarantine_data() works with mocked bucket folder", {
  tbl_quarantine <- show_objects_s3(
    bucket_name = sn$mo_bucket_name,
    prefixer = sn$mo_objects_prefix
  ) |>
    get_quarantine_data(bucket_name = sn$mo_bucket_name)

  # "tbl_quarantine" is a data frame ####
  expect_s3_class(object = tbl_quarantine, class = "data.frame")

  # "tbl_quarantine" has > 0 row ####
  tbl_quarantine |>
    nrow() |>
    expect_gt(expected = 0)

  # "tbl_quarantine" has the only correct column ####
  tbl_quarantine |>
    colnames() |>
    expect_equal(expected = "original_name")

  # "original_name" column is a character vector ####
  tbl_quarantine |>
    dplyr::pull(var = "original_name") |>
    expect_type(type = "character")

  # "original_name" column does not have NA ####
  tbl_quarantine |>
    dplyr::pull(var = "original_name") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name" column has no duplicated names ####
  tbl_quarantine |>
    dplyr::pull(var = "original_name") |>
    duplicated() |>
    any() |>
    expect_false()

  # "original_name" column has only valid names(letters) ####
  tbl_quarantine |>
    dplyr::pull(var = "original_name") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()
})
