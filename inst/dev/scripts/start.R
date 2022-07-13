usethis::create_package("mcn")

usethis::use_dev_package(
  package = "abjutils",
  remote = "github::abjur/abjutils@v0.3.2"
)

usethis::use_dev_package(
  package = "aws.s3",
  remote = "github::cloudyr/aws.s3@v0.3.20"
)

usethis::use_dev_package(
  package = "cli",
  remote = "github::r-lib/cli@v3.2.0"
)

usethis::use_dev_package(
  package = "dbplyr",
  remote = "github::tidyverse/dbplyr@v2.1.1"
)

usethis::use_dev_package(
  package = "dplyr",
  remote = "github::tidyverse/dplyr@v1.0.8"
)

usethis::use_dev_package(
  package = "glue",
  remote = "github::tidyverse/glue@v1.6.2"
)

usethis::use_dev_package(
  package = "odbc",
  remote = "github::r-dbi/odbc@v1.3.3"
)

usethis::use_dev_package(
  package = "purrr",
  remote = "github::tidyverse/purrr@v0.3.4"
)

usethis::use_dev_package(
  package = "rlang",
  remote = "github::r-lib/rlang@v1.0.2"
)

usethis::use_dev_package(
  package = "stopwords",
  remote = "github::quanteda/stopwords@v2.3"
)

usethis::use_dev_package(
  package = "stopwords",
  remote = "github::quanteda/stopwords@v2.3"
)

usethis::use_dev_package(
  package = "stringr",
  remote = "github::tidyverse/stringr@v1.4.0"
)

usethis::use_package(package = "tm")

usethis::use_dev_package(
  package = "usethis",
  remote = "github::r-lib/usethis@v2.1.5"
)

usethis::use_dev_package(
  package = "vroom",
  remote = "github::r-lib/vroom@v1.5.7"
)

usethis::use_dev_package(
  package = "tibble",
  remote = "github::tidyverse/tibble@v3.1.7.9000"
)

usethis::use_dev_package(
  package = "lambdr",
  remote = "github::mdneuzerling/lambdr@v1.2.0"
)

usethis::use_r("utils")
usethis::use_r("get")
usethis::use_r("prep")
usethis::use_r("make")
usethis::use_r("mount")
usethis::use_r("insert")

usethis::use_r("globals")

usethis::use_test("connect")
usethis::use_test("get")
usethis::use_test("make")
usethis::use_test("mount")
usethis::use_test("prep")
# usethis::use_test("update")
# usethis::use_test("utils")
# usethis::use_test("insert")
