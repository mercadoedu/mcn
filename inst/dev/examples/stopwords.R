# %%
# Connect to a mercadoedu's odbc data source  ####
me_con <- connect_dsn()
# %%

# %%
# My stopwords ####
my_stopwords_list <- c(
  "abi",
  "centro universitário",
  "centros universitário",
  "centro universitários",
  "centros universitários",
  "cidade universitária",
  "cidades universitária",
  "cidade universitárias",
  "cidades universitárias",
  "cst",
  "curso",
  "distância",
  "ead",
  "ensino superior",
  "fgv",
  "graduação",
  "híbrido",
  "lins",
  "lucas",
  "matutino",
  "mg",
  "modalidade ensino",
  "modalidade",
  "noturno",
  "novembro",
  "novo",
  "parceria",
  "pe",
  "plena",
  "premium",
  "presencial",
  "semestre",
  "semestres",
  "semipresencial",
  "sup",
  "superior",
  "unisl",
  "xv",
  "zona norte"
)

# Stopwords wrongs ####
my_wrong_stopwords_list <- c(
  "ai",
  "aí",
  "apoio",
  "área",
  "coisa",
  "conselho",
  "diversa",
  "diversas",
  "diversos",
  "estado",
  "geral",
  "grande",
  "grandes",
  "grupo",
  "logo",
  "meio",
  "obra",
  "pessoas",
  "relação",
  "trabalho",
  "viagem"
)

# Mount stopwords table ####
tbl_stopwords <- mount_stopwords(
  sw_list = my_stopwords_list,
  sw_wrongs_list = my_wrong_stopwords_list,
  quietly = FALSE
)
# %%

# %%
# Update stopwords table ####
stopwords_update <- update_stopwords(
  con = me_con,
  tbl_sw = tbl_stopwords,
  tbl_name = "stopwords",
  check = TRUE
)
# %%

# %%
# Closing mercadoedu's odbc data source connection ####
DBI::dbDisconnect(me_con)
# %%
