# %%
# Connect to odbc mercadoedu's data source ####
me_con <- connect_dsn()
# %%

# %%
# Mount matched names table ####
tbl_matched_names <- mount_matched_names(
  con = me_con,
  tbl_name_ftk = "me_v3_pricing_fromtokey",
  tbl_name_pc = "pricing_course",
  tbl_name_sw = "stopwords",
  bucket_name = "price-quarentine",
  objects_prefix = "run-AmazonS3_node",
  quietly = FALSE
)
# %%

# %%
# Update matched names table ####
matched_names_update <- update_matched_names(
  con = me_con,
  tbl_mn = tbl_matched_names,
  tbl_name = "me_v3_pricing_fromtokey",
  check = TRUE
)
# %%

# %%
# Disconnect from odbc mercadoedu's data source ####
DBI::dbDisconnect(conn = me_con)
# %%
