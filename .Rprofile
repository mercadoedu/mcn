# Setting options
options(width = 80)

# We set the cloud mirror, which is "network-close" to everybody, as default
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cloud.r-project.org"
  options(repos = r)
})

source("renv/activate.R")

if (interactive()) {
  if (Sys.getenv("TERM_PROGRAM") == "vscode") {
    # Obtain list of packages in renv library currently
    project <- renv:::renv_project_resolve(NULL)

    proj_libs <- renv:::renv_diagnostics_packages_library(project) |>
      unclass()

    lib_packages <- proj_libs$Packages |>
      names()

    if (!"jsonlite" %in% lib_packages) {
      message("installing jsonlite package")
      renv::install("jeroen/jsonlite@v1.8.0")
    }

    if (!"rlang" %in% lib_packages) {
      message("installing rlang package")
      renv::install("r-lib/rlang@v1.0.2")
    }

    if (!"rstudioapi" %in% lib_packages) {
      message("installing rstudioapi package")
      renv::install("rstudio/rstudioapi@0.13")
    }

    if (!"vscDebugger" %in% lib_packages) {
      message("installing vscDebugger package")
      renv::install("ManuelHentschel/vscDebugger@v0.4.7")
    }

    if (!"prompt" %in% lib_packages) {
      message("installing prompt package")
      renv::install("gaborcsardi/prompt@v1.0.1")
    }

    if (!"usethis" %in% lib_packages) {
      message("installing usethis package")
      renv::install("r-lib/usethis@v2.1.5")
    }

    if (!"devtools" %in% lib_packages) {
      message("installing devtools package")
      renv::install("r-lib/devtools@v2.4.3")
    }

    if (!"languageserver" %in% lib_packages) {
      message("installing languageserver package")
      renv::install("REditorSupport/languageserver@v0.3.12")
    }

    if (!"httpgd" %in% lib_packages) {
      message("installing httpgd package")
      remotes::install_github("nx10/httpgd")
    }

    options(vsc.rstudioapi = TRUE)

    # use the new httpgd plotting device
    options(vsc.plot = TRUE)
    options(device = function(...) {
      httpgd:::hgd()
      .vsc.browser(httpgd::hgd_url(), viewer = "Beside")
    })
  }

  # attach R terminal to VSCode
  ifelse(
    .Platform$OS.type == "windows",
    "USERPROFILE",
    "HOME"
  ) |>
    Sys.getenv() |>
    file.path(
      ".vscode-R",
      "init.R"
    ) |>
    source()

  # Change console prompt line
  prompt::set_prompt(prompt::prompt_fancy)
}
