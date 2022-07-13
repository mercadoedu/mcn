# %%
# Att documentation #### (ctrl+shift+f1)
devtools::document()

# Clear workspace
rm(list = ls(all.names = TRUE))

# Load all functions from package #### (ctrl+shift+f2)
devtools::load_all()
# %%

# %%
# Run all tests in the package #### (ctrl+shift+f3)
devtools::test()

unlink("tests/testthat/_snaps", recursive = TRUE)
# %%

# %%
# Check package #### (ctrl+shift+f5)
devtools::check()
# %%
