# Connecting to mercadoedu data source ####
mo_con <- connect_dsn(dsn = sn$mo_dsn_name)

# Collecting mercadoedu's stopwords data ####
mo_stopwords_list <- get_stopwords(con = mo_con, tbl_name = sn$mo_tbl_name_sw)

# Collecting mercadoedu's matching data ####
tbl_matching_data <- get_matching_data(
  con = mo_con,
  tbl_name_ftk = sn$mo_tbl_name_ftk,
  tbl_name_pc = sn$mo_tbl_name_pc
) |>
  prep_matching_data(my_stopwords = mo_stopwords_list)

# Disconnecting from mercadoedu data source ####
DBI::dbDisconnect(conn = mo_con)

# Collecting mercadoedu's quarantine data ####
tbl_quarantine_data <- show_objects_s3(
  bucket_name = sn$mo_bucket_name,
  prefixer = sn$mo_objects_prefix
) |>
  get_quarantine_data(bucket_name = sn$mo_bucket_name) |>
  prep_quarantine_data(my_stopwords = mo_stopwords_list)

# Testing join of mercadoedu's matching data and quarantine data ####
test_that("make_join() works with mocked data source", {
  tbl_join_maked <- make_join(
    tbl_nn = tbl_quarantine_data,
    tbl_db = tbl_matching_data,
    by_n = c("original_name_clean" = "name_detail_clean"),
    n_iter = 3
  )

  # "tbl_join_maked" is a data frame ####
  expect_s3_class(object = tbl_join_maked, class = "data.frame")

  # "tbl_join_maked" has > 0 rows ####
  tbl_join_maked |>
    nrow() |>
    expect_gt(expected = 0)

  # "tbl_join_maked" has the correct four columns ####
  tbl_join_maked |>
    colnames() |>
    expect_equal(
      expected = c(
        "original_name",
        "original_name_lower",
        "original_name_clean",
        "name",
        "discr_id",
        "name_detail",
        "name_detail_lower",
        "name_detail_clean",
        "priority"
      )
    )

  # "original_name" column is a character vector ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name") |>
    expect_type(type = "character")

  # "original_name" column does not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name" column has only one discr_id per text ####
  tbl_join_maked |>
    dplyr::select(discr_id, original_name) |>
    dplyr::group_by(original_name) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "original_name_lower" column is a character vector ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name_lower") |>
    expect_type(type = "character")

  # "original_name_lower" column does not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name_lower") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name_lower" column has names in lower case ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name_lower") |>
    stringr::str_detect(pattern = "[:upper:]") |>
    any() |>
    expect_false()

  # "original_name_lower" column has only valid names(letters) ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name_lower") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "original_name_clean" column is a character vector ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name_clean") |>
    expect_type(type = "character")

  # "original_name_clean" column does not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name_clean") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name_clean" column has names in lower case ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name_clean") |>
    stringr::str_detect(pattern = "[:upper:]") |>
    any() |>
    expect_false()

  # "original_name_clean" column has only valid names(letters) ####
  tbl_join_maked |>
    dplyr::pull(var = "original_name_clean") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "name" column is a character vector ####
  tbl_join_maked |>
    dplyr::pull(var = "name") |>
    expect_type(type = "character")

  # "name" column doest not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "name") |>
    is.na() |>
    any() |>
    expect_false()

  # "name" column has only one discr_id per text ####
  tbl_join_maked |>
    dplyr::select(discr_id, name) |>
    dplyr::group_by(name) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "discr_id" column is an integer vector ####
  tbl_join_maked |>
    dplyr::pull(var = "discr_id") |>
    expect_type(type = "integer")

  # "discr_id" column does not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "discr_id") |>
    is.na() |>
    any() |>
    expect_false()

  # "discr_id" column does not have zero as id ####
  tbl_join_maked |>
    dplyr::pull(var = "discr_id") |>
    is.element(0) |>
    any() |>
    expect_false()

  # "name_detail" column is a character vector ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail") |>
    expect_type(type = "character")

  # "name_detail" column doest not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail") |>
    is.na() |>
    any() |>
    expect_false()

  # "name_detail" column has only one discr_id per text ####
  tbl_join_maked |>
    dplyr::select(discr_id, name_detail) |>
    dplyr::group_by(name_detail) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "name_detail_lower" column is a character vector ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail_lower") |>
    expect_type(type = "character")

  # "name_detail_lower" column does not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail_lower") |>
    is.na() |>
    any() |>
    expect_false()

  # "name_detail_lower" column has names in lower case ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail_lower") |>
    stringr::str_detect(pattern = "[:upper:]") |>
    any() |>
    expect_false()

  # "name_detail_lower" column has only valid names(letters) ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail_lower") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "name_detail_lower" column has only one discr_id per text ####
  tbl_join_maked |>
    dplyr::select(discr_id, name_detail_lower) |>
    dplyr::group_by(name_detail_lower) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "name_detail_clean" column is a character vector ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail_clean") |>
    expect_type(type = "character")

  # "name_detail_clean" column does not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail_clean") |>
    is.na() |>
    any() |>
    expect_false()

  # "name_detail_clean" column has names in lower case ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail_clean") |>
    stringr::str_detect(pattern = "[:upper:]") |>
    any() |>
    expect_false()

  # "name_detail_clean" column has only valid names(letters) ####
  tbl_join_maked |>
    dplyr::pull(var = "name_detail_clean") |>
    stringr::str_detect(pattern = "[:alpha:]", negate = TRUE) |>
    any() |>
    expect_false()

  # "name_detail_clean" column has only one discr_id per text ####
  tbl_join_maked |>
    dplyr::select(discr_id, name_detail_clean) |>
    dplyr::group_by(name_detail_clean) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "priority" column is an integer vector ####
  tbl_join_maked |>
    dplyr::pull(var = "priority") |>
    expect_type(type = "integer")

  # "priority" column does not have NA ####
  tbl_join_maked |>
    dplyr::pull(var = "priority") |>
    is.na() |>
    any() |>
    expect_false()

  # "priority" column does not have zero as id ####
  tbl_join_maked |>
    dplyr::pull(var = "priority") |>
    is.element(set = 0) |>
    any() |>
    expect_false()

  # "priority" have 3 as id in all rows ####
  tbl_join_maked |>
    dplyr::pull(var = "priority") |>
    is.element(set = 3) |>
    all() |>
    expect_true()
})

# Testing joins of mercadoedu's matching data and quarantine data ####
test_that("make_joineds_append() works with mocked data source", {
  tbl_joined_appended <- make_joineds_append(
    tbl_matching = tbl_matching_data,
    tbl_new_names = tbl_quarantine_data
  )

  # "tbl_joined_appended" is a data frame ####
  expect_s3_class(object = tbl_joined_appended, class = "data.frame")

  # "tbl_joined_appended" has > 0 rows ####
  tbl_joined_appended |>
    nrow() |>
    expect_gt(expected = 0)

  # "tbl_joined_appended" has the correct four columns ####
  tbl_joined_appended |>
    colnames() |>
    expect_equal(
      expected = c(
        "name",
        "discr_id",
        "original_name"
      )
    )

  # "name" column is a character vector ####
  tbl_joined_appended |>
    dplyr::pull(var = "name") |>
    expect_type(type = "character")

  # "name" column does not have NA ####
  tbl_joined_appended |>
    dplyr::pull(var = "name") |>
    is.na() |>
    any() |>
    expect_false()

  # "name" column has only one discr_id per text ####
  tbl_joined_appended |>
    dplyr::group_by(name) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "discr_id" column is an integer vector ####
  tbl_joined_appended |>
    dplyr::pull(var = "discr_id") |>
    expect_type(type = "integer")

  # "discr_id" column does not have NA ####
  tbl_joined_appended |>
    dplyr::pull(var = "discr_id") |>
    is.na() |>
    any() |>
    expect_false()

  # "discr_id" column does not have zero as id ####
  tbl_joined_appended |>
    dplyr::pull(var = "discr_id") |>
    is.element(set = 0) |>
    any() |>
    expect_false()

  # "original_name" column is a character vector ####
  tbl_joined_appended |>
    dplyr::pull(var = "original_name") |>
    expect_type(type = "character")

  # "original_name" column does not have NA ####
  tbl_joined_appended |>
    dplyr::pull(var = "original_name") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name" column has no duplicated names ####
  tbl_joined_appended |>
    dplyr::pull(var = "original_name") |>
    duplicated() |>
    any() |>
    expect_false()

  # "original_name" column has only one discr_id per text ####
  tbl_joined_appended |>
    dplyr::group_by(original_name) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)
})
