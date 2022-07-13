# Parity function ##### Install dependencies ####
# renv::install()

# Show odbc drivers from ~/.odbcinst.ini or /etc/odbcinst.ini ####
#odbc::odbcListDrivers()
# Show odbc data sources from ~/.odbc.ini or /etc/odbc.ini ####
#odbc::odbcListDataSources()
# Show catalogs of Amazon RDS Model database ####
# odbc::odbcListObjects(model_con)
# Show schemas of catalog called "ia_text_class" ####
# odbc::odbcListObjects(model_con, catalog = "ia_text_class")
# Show tables of schema called "public" ####
# odbc::odbcListObjects(model_con, catalog = "ia_text_class", schema = "public")
# Show catalogs of Amazon RDS mercadoedu database ####
# odbc::odbcListObjects(me_con)
# Show schemas of catalog me ####
# odbc::odbcListObjects(me_con, catalog = "me")
# Show tables of schema public ####
# odbc::odbcListObjects(me_con, catalog = "me", schema = "public")

# %%
pipe_matched_names <- function() {
  # Connect to odbc data source called "Amazon RDS Model" ####
  me_con <- connect_dsn()

  cli::cat_line()

  # Mount matched names table ####
  matched_names <- mount_matched_names(con = me_con)

  DBI::dbDisconnect(conn = me_con)

  matched_names
}

# Mount matched_names ####
matched_names <- pipe_matched_names()
# %%

# %%
# Connect to odbc data source called "Amazon RDS mercadoedu" ####
me_con <- connect_dsn("Amazon RDS mercadoedu")

# Connect to odbc data source called "Amazon RDS Model" ####
model_con <- connect_dsn()

# Mount matching_data ####
matching_data <- get_matching_data(con = me_con) |>
  prep_matching_data(
    my_stopwords = model_con |>
      get_stopwords_data() |>
      dplyr::pull(var = "words")
  )

pc <- me_con |>
  dplyr::tbl("pricing_course") |>
  dplyr::filter(level == 1) |>
  dplyr::arrange(id) |>
  dplyr::collect()

# Get all rows from quarentine data ####
entire_quarentine_data <- show_objects_s3(
  bucket_name = "price-quarentine",
  prefixer = "run-AmazonS3_node"
) |>
  get_quarentine_data(dist = FALSE)

# Remove duplicates from quarentine data ####
quarentine_data <- entire_quarentine_data |>
  dplyr::distinct()


# Check rows that matched names solved in entire quarentine data ####
inner_entire <- entire_quarentine_data |>
  dplyr::inner_join(matched_names, by = "original_name")

# Check rows that matched names solved in quarentine data ####
inner_dist <- quarentine_data |>
  dplyr::inner_join(matched_names, by = "original_name")

# Names without solve (41) ####
not_solved <- quarentine_data |>
  dplyr::anti_join(matched_names, by = "original_name")

# Names without solve prepared ####
not_solved_prepared <- not_solved |>
  prep_quarentine_data(my_stopwords = model_con |>
    get_stopwords_data() |>
    dplyr::pull(var = "words"))

DBI::dbDisconnect(conn = model_con)
DBI::dbDisconnect(conn = me_con)
# %%

# %%
me_con <- connect_dsn("Amazon RDS mercadoedu")

model_con <- connect_dsn()

matched_names_df <- mount_matched_names(model_con = model_con, me_con = me_con)

appended <- matched_names_df |>
  dplyr::mutate(discr = "pricing_course_level_1") |>
  dplyr::select("discr_id", "discr", "arg" = original_name)

fromtokey <- me_con |>
  tbl("me_v3_pricing_fromtokey") |>
  filter(
    discr == "pricing_course_level_1",
    arg != "n/c",
    arg != "-new-"
  ) |>
  # select("discr_id", "name_detail" = arg) |>
  collect()

DBI::dbDisconnect(conn = model_con)
DBI::dbDisconnect(conn = me_con)
# %%

# %%
# me_con <- connect_dsn("Amazon RDS mercadoedu")
#
# tt <- DBI::dbWriteTable(
#   conn = me_con,
#   name = "me_v3_pricing_fromtokey",
#   value = appended,
#   overwrite = FALSE,
#   append = TRUE,
#   row.names = FALSE
# )
#
# DBI::dbDisconnect(conn = model_con)
# DBI::dbDisconnect(conn = me_con)
# %%

# %%
copy_tbl <- function(tbl_name, origin_con, target_con) {
  origin_con |>
    dplyr::tbl(tbl_name) |>
    dplyr::collect() |>
    DBI::dbWriteTable(
      conn = target_con,
      name = paste0("mock_", tbl_name),
      value = _,
      overwrite = TRUE,
      append = FALSE,
      row.names = FALSE
    )
}

tbl_list <- c(
  tbl_name_ftk = "me_v3_pricing_fromtokey",
  tbl_name_pc = "pricing_course",
  tbl_name_sw = "stopwords"
)

me_con <- connect_dsn()

model_con <- connect_dsn("Amazon RDS Model")

tbl_list |>
  purrr::map(
    .f = copy_tbl,
    origin_con = me_con,
    target_con = model_con
  )

odbc::odbcListObjects(conn = model_con, "ia_text_class", "public")

DBI::dbRemoveTable(conn = model_con, name = "mock_me_v3_pricing_fromtokey")

# %%
