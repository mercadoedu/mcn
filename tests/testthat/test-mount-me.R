test_that("mount_matched_names() works with mercadoedu data source", {
  # Connecting to mercadoedu data source ####
  me_con <- connect_dsn(dsn = sn$me_dsn_name)

  # Testing matched names with mercadoedu data source ####
  matched_names <- mount_matched_names(
    con = me_con,
    tbl_name_ftk = sn$me_tbl_name_ftk,
    tbl_name_pc = sn$me_tbl_name_pc,
    tbl_name_sw = sn$me_tbl_name_sw,
    bucket_name = sn$me_bucket_name,
    objects_prefix = sn$me_objects_prefix
  )

  # Disconnecting from mercadoedu data source ####
  DBI::dbDisconnect(conn = me_con)

  # "matched_names$tables$matched" is a data frame ####
  expect_s3_class(object = matched_names$tables$matched, class = "data.frame")

  # "matched_names$tables$matched" has > 0 rows ####
  matched_names$tables$matched |>
    nrow() |>
    expect_gte(expected = 0)

  # "matched_names$tables$matched" has the correct three columns ####
  matched_names$tables$matched |>
    colnames() |>
    expect_equal(
      expected = c(
        "name",
        "discr_id",
        "original_name"
      )
    )

  # "name" column is a character vector ####
  matched_names$tables$matched |>
    dplyr::pull(var = "name") |>
    expect_type(type = "character")

  # "name" column does not have NA ####
  matched_names$tables$matched |>
    dplyr::pull(var = "name") |>
    is.na() |>
    any() |>
    expect_false()

  # "name" column has only one discr_id per text ####
  matched_names$tables$matched |>
    dplyr::group_by(name) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)

  # "discr_id" column is an integer vector ####
  matched_names$tables$matched |>
    dplyr::pull(var = "discr_id") |>
    expect_type(type = "integer")

  # "discr_id" column does not have NA ####
  matched_names$tables$matched |>
    dplyr::pull(var = "discr_id") |>
    is.na() |>
    any() |>
    expect_false()

  # "discr_id" column does not have zero as id ####
  matched_names$tables$matched |>
    dplyr::pull(var = "discr_id") |>
    is.element(set = 0) |>
    any() |>
    expect_false()

  # "original_name" column is a character vector ####
  matched_names$tables$matched |>
    dplyr::pull(var = "original_name") |>
    expect_type(type = "character")

  # "original_name" column does not have NA ####
  matched_names$tables$matched |>
    dplyr::pull(var = "original_name") |>
    is.na() |>
    any() |>
    expect_false()

  # "original_name" column does not no duplicated names ####
  matched_names$tables$matched |>
    dplyr::pull(var = "original_name") |>
    duplicated() |>
    any() |>
    expect_false()

  # "original_name" column has only one discr_id per text ####
  matched_names$tables$matched |>
    dplyr::group_by(original_name) |>
    dplyr::filter(dplyr::n_distinct(discr_id) > 1) |>
    dplyr::ungroup() |>
    nrow() |>
    expect_equal(expected = 0)
})
