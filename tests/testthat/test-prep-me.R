# Connecting to mercadoedu data source ####
me_con <- connect_dsn(dsn = sn$me_dsn_name)

# Collecting mercadoedu's stopwords data ####
me_stopwords_list <- get_stopwords(con = me_con, tbl_name = sn$me_tbl_name_sw)

# Testing the preparation of mercadoedu's matching data ####
test_that("prep_matching_data() works with mercadoedu data source", {
  tbl_matching_prep <- get_matching_data(
    con = me_con,
    tbl_name_ftk = sn$me_tbl_name_ftk,
    tbl_name_pc = sn$me_tbl_name_pc
  ) |>
    prep_matching_data(my_stopwords = me_stopwords_list)

  # "tbl_matching_prep" is a data frame ####
  expect_s3_class(object = tbl_matching_prep, class = "data.frame")

  # "tbl_matching_prep" has > 1510 rows(initial data) ####
  tbl_matching_prep |>
    nrow() |>
    expect_gt(expected = 1510)

  # "tbl_matching_prep" has the correct four columns ####
  tbl_matching_prep |>
    colnames() |>
    expect_equal(
      expected = c(
        "name",
        "discr_id",
        "name_detail",
        "name_detail_lower",
        "name_detail_clean"
      )
    )

  # "discr_id" column is an integer vector ####
  tbl_matching_prep |>
    dplyr::pull(var = "discr_id") |>
    expect_type(type = "integer")

  # "discr_id" column does not have NA ####
  tbl_matching_prep |>
    dplyr::pull(var = "discr_id") |>
    is.na() |>
    any() |>
    expect_false()

  # "discr_id" column does not have zero as id ####
  tbl_matching_prep |>
    dplyr::pull(var = "discr_id") |>
    is.element(set = 0) |>
    any() |>
    expect_false()

  # "name_detail" column is a character vector ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail") |>
    expect_type(type = "character")

  # "name_detail" column does not have NA ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail") |>
    is.na() |>
    any() |>
    expect_false()

  # "name_detail" column has no duplicated names ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail") |>
    duplicated() |>
    any() |>
    expect_false()

  # "name_detail" column has only one discr_id per text ####
  tbl_matching_prep |>
    dplyr::select(discr_id, name_detail) |>
    dplyr::group_by(name_detail) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(0)

  # "name_detail_lower" column is a character vector ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail_lower") |>
    expect_type(type = "character")

  # "name_detail_lower" column does not have NA ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail_lower") |>
    is.na() |>
    any() |>
    expect_false()

  # "name_detail_lower" column has names in lower case ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail_lower") |>
    stringr::str_detect(pattern = "[:upper:]") |>
    any() |>
    expect_false()

  # "name_detail_lower" column has only valid names(letters) ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail_lower") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "name_detail_lower" column has only one discr_id per text ####
  tbl_matching_prep |>
    dplyr::select(discr_id, name_detail_lower) |>
    dplyr::group_by(name_detail_lower) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "name_detail_clean" column is a character vector ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail_clean") |>
    expect_type(type = "character")

  # "name_detail_clean" column does not have NA ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail_clean") |>
    is.na() |>
    any() |>
    expect_false()

  # "name_detail_clean" column has names in lower case ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail_clean") |>
    stringr::str_detect(pattern = "[:upper:]") |>
    any() |>
    expect_false()

  # "name_detail_clean" column has only valid names(letters) ####
  tbl_matching_prep |>
    dplyr::pull(var = "name_detail_clean") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "name_detail_clean" column has only one discr_id per text ####
  tbl_matching_prep |>
    dplyr::select(discr_id, name_detail_clean) |>
    dplyr::group_by(name_detail_clean) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)
})

# Disconnecting from mercadoedu data source ####
DBI::dbDisconnect(conn = me_con)

# Testing the preparation of mercadoedu's quarantine data ####
test_that("prep_quarantine_data() works with mercadoedu's bucket", {
  tbl_quarantine_prep <- show_objects_s3(
    bucket_name = sn$me_bucket_name,
    prefixer = sn$mo_objects_prefix
  ) |>
    get_quarantine_data(bucket_name = sn$me_bucket_name) |>
    prep_quarantine_data(my_stopwords = me_stopwords_list)

  # "tbl_quarantine_prep" is a data frame ####
  expect_s3_class(object = tbl_quarantine_prep, class = "data.frame")

  # "tbl_quarantine_prep" has > 0 rows ####
  tbl_quarantine_prep |>
    nrow() |>
    expect_gt(expected = 0)

  # "tbl_quarantine_prep" has the correct three columns ####
  tbl_quarantine_prep |>
    colnames() |>
    expect_equal(
      expected = c(
        "original_name",
        "original_name_lower",
        "original_name_clean"
      )
    )

  # "original_name" column is a character vector ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name") |>
    expect_type(type = "character")

  # "original_name" column does not have NA ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name" column does not no duplicated names ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name") |>
    duplicated() |>
    any() |>
    expect_false()

  # "original_name_lower" column is a character vector ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name_lower") |>
    expect_type(type = "character")

  # "original_name_lower" column does not have NA ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name_lower") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name_lower" column has names in lower case ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name_lower") |>
    stringr::str_detect(pattern = "[:upper:]") |>
    any() |>
    expect_false()

  # "original_name_lower" column has only valid names(letters) ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name_lower") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "original_name_clean" column is a character vector ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name_clean") |>
    expect_type(type = "character")

  # "original_name_clean" column does not have NA ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name_clean") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name_clean" column has names in lower case ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name_clean") |>
    stringr::str_detect(pattern = "[:upper:]") |>
    any() |>
    expect_false()

  # "original_name_clean" column has only valid names(letters) ####
  tbl_quarantine_prep |>
    dplyr::pull(var = "original_name_clean") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()
})
