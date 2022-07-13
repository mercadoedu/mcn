Matching Course Names
================

-   [Description](#description)
-   [Roadmap](#roadmap)
-   [Installation](#installation)
    -   [System Requirements](#system-requirements)
        -   [ODBC](#odbc)
            -   [Data Source Name](#data-source-name)
                -   [.odbcinst.ini](#odbcinstini)
                -   [.odbc.ini](#odbcini)
        -   [Environment variables](#environment-variables)
    -   [R Package installation](#r-package-installation)
-   [Usage](#usage)
    -   [Stopwords](#stopwords)
        -   [Stopwords pipeline](#stopwords-pipeline)
            -   [Mount stopwords](#mount-stopwords)
            -   [Update stopwords](#update-stopwords)
    -   [Matched names](#matched-names)
        -   [Matched names pipeline](#matched-names-pipeline)
            -   [Mount matched names](#mount-matched-names)
            -   [Update matched names](#update-matched-names)
            -   [Put missmatched in S3](#put-missmatched-in-s3)
            -   [Delete S3 files](#delete-s3-files)
-   [Authors and acknowledgment](#authors-and-acknowledgment)

<!-- README.md is generated from README.Rmd. Please edit that file -->

## Description

A package to deal with course names that have been extracted from
websites.The functions are responsible for classifying course names that
were extracted but it was not possible to classify with the raw string.

## Roadmap

To deal with different data sources and facilitate tests, functions were
created that:

-   [x] Pipeline for stopwords database
    -   [x] Connect on `Amazon RDS mercadoedu` data source name (with
        `ODBC` package using a `PostgreSQL` database client)
    -   [x] Mount stopwords data
        -   [x] Collect pt-br stopwords from `nltk`, `snowball` and
            `stopwords-iso` sources with the `stopwords` package
        -   [x] Append custom stopwords list with pt-br stopwords
        -   [x] Squish, sort and remove duplicate stopwords, before and
            after remove accents
        -   [x] Append custom wrong pt-br stopwords list with column
            called `stopwords_wrongs` to know if the stopword should not
            be used (If you have value 1, this stopword should not be
            used)
        -   [x] Show stopwords
    -   [x] Update stopwords database
        -   [x] Overwrite stopwords data on the `stopwords` table in
            data source
-   [x] Pipeline for matching database
    -   [x] Connect on `Amazon RDS mercadoedu` data source name (with
        `ODBC` package using a `PostgreSQL` database client)
    -   [x] Mount matching data of course names
        -   [x] Get stopwords data from `stopwords` table from data
            source
        -   [x] Get matching data from data source
            -   [x] Collect course names data to assist in strings
                matching from the `me_v3_pricing_fromtokey` table from
                data source
            -   [x] Collect course names categories from
                `pricing_course`
            -   [x] Join course names data to course names categories
            -   [x] Prepare matching data strings cleaning, squishing
                and lowering case
        -   [x] Get the names of quarantine data objects from the
            `AWS S3` bucket called `price-quarentine`
        -   [x] Get quarantine data from the bucket objects
            -   [x] Import the `.csv` objects from bucket with `vroom`
                package
            -   [x] Prepare matching data strings cleaning, squishing
                and lowering case
        -   [x] Make joins with `matching data` and `quarantine data` by
            strings to match course names
        -   [x] Show the number of `quarantine names` matched
        -   [x] Show the proportion of `quarantine names` matched
        -   [x] Show the proportion of `quarantine data` matched
        -   [x] Ask if want to check course names matched
            -   [x] Show course names matched
            -   [x] Show course names not matched
    -   [x] Update matching data database
        -   [x] Insert course names matched to the
            `me_v3_pricing_fromtokey` table from data source
    -   [ ] Write a `.csv` object with `missmached course names` into
        `price-quarentine/model/` bucket folder
    -   [ ] Delete `.csv` objects from `price-quarentine` bucket

## Installation

### System Requirements

-   ODBC

You will need to install the ODBC driver and configure data source names
to use this package.

#### ODBC

To install the drivers(only [PostgreSQL](https://www.postgresql.org/))
and libraries required to use the `ODBC`, follow the official
installation tutorial available in the [ODBC Library Github repository
for R](https://github.com/r-dbi/odbc/#installation).

##### Data Source Name

To connect to databases you will need to configure data source names, we
suggest using a local DSN file (according to the [DSN Configuration
Files section](https://github.com/r-dbi/odbc/#dsn-configuration-files)
of the official repository). Below is the example of the configuration
files `~/.odbc.ini` and `~/.odbcinst.ini`:

###### .odbcinst.ini

Contains driver information, particularly the name of the driver
library. Multiple drivers can be specified in the same file.

> `Driver` and `Setup` parameter can change depending on the operating
> system.

``` ini
[PostgreSQL Unicode]
Description=PostgreSQL ODBC driver (Unicode version)
Driver=psqlodbcw.so
Setup=libodbcpsqlS.so
Debug=0
CommLog=1
UsageCount=1
```

###### .odbc.ini

Contains connection information, particularly the username, database and
host information. The Driver line corresponds to the driver defined in
`.odbcinst.ini`.

``` ini
[Amazon RDS mock]
Driver=PostgreSQL Unicode
Description=PostgreSQL Unicode ODBC drive of mock datasets
Servername=me.coy3ddkwm8lj.sa-east-1.rds.amazonaws.com
Port=5432
Database=ia_text_class
UserName=fernando
locale=pt-BR

[Amazon RDS mercadoedu]
Driver=PostgreSQL Unicode
Description=PostgreSQL Unicode ODBC drive of mercadoedu datasets
Servername=me.coy3ddkwm8lj.sa-east-1.rds.amazonaws.com
Port=5432
Database=me
UserName=fernando
locale=pt-BR
```

#### Environment variables

We suggest using the `Renviron` configuration file to define the
environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`,
`AWS_DEFAULT_REGION` and `RDS_PWD`) required for R connect to
`PostgreSQL` and `AWS S3`. Below is the example of the `~/.Renviron`:

``` ini
AWS_ACCESS_KEY_ID=AKIAJRFALDAXH2YOWCAA # example of an AWS Access Key ID(you need to get yours)
AWS_SECRET_ACCESS_KEY=DpACpvciP0oK7fwOIAOx7FyufRSqb61yhuHpHK+5y # example of an AWS Secret Access Key(you need to get yours)
AWS_DEFAULT_REGION=us-east-2 # you need to set us-east-2 as default region
RDS_PWD=mypassword # example of an AWS RDS Password for username fernando (you need to get yours)
```

### R Package installation

To install this R package, you will need to have the Gitlab PAT ([Gitlab
Personal Access
Tokens](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html))
as a variable of the environment, after do that, just run the commands
below:

``` r
# install.packages("devtools")
devtools::install_gitlab("mercadoedu/price-automation/mcn")
```

## Usage

You can use the pipeline functions, which only requires the data source
name and table name as a parameter.

### Stopwords

You need to define what stopwords will be included beyond the default
stopwords and which default stopwords should not be included.

``` r
# My stopwords that must be included ####
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

# Defaul stopwords that should not be included ####
my_stopwords_wrongs_list <- c(
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
```

#### Stopwords pipeline

The `pipeline_stopwords` function is used to mount and update the
stopwords that are stored in database.

``` r
# Pipe stopwords lists
stopwords_piped <- mcn::pipeline_stopwords(
  data_source_name = "Amazon RDS mercadoedu",
  stopwords_list = my_stopwords_list,
  stopwords_wrongs_list = my_stopwords_wrongs_list,
  table_name_stopwords = "stopwords"
)
```

You can also use the basic functions that make up the
`pipeline_stopwords` function, but in update function you will need to
pass the connection already made as the first parameter (`con`).

##### Mount stopwords

The function is used to mount the table with default stopwords in
`pt-br` and the stopwords you have chosen that will be used or not.

``` r
# Mount stopwords table
table_stopwords <- mcn::mount_stopwords(
  sw_list = my_stopwords_list,
  sw_wrongs_list = my_stopwords_wrongs_list,
  check = TRUE
)
```

##### Update stopwords

The function is used to update the stopwords table, but you must be
connected to an ODBC data source and pass the connection as a first
parameter.

``` r
# Connect to odbc data source ####
my_con <- mcn::connect_dsn(dsn = "Amazon RDS mercadoedu")

# Update stopwords table ####
stopwords_update <- mcn::update_stopwords(
  con = my_con,
  tbl_sw = table_stopwords,
  tbl_name = "stopwords",
  check = TRUE
)
```

### Matched names

The goal is to classify the course names that were collected from the
AWS S3 bucket with the existing matching data in the mercadoedu
database. So you can classify course names collected that had no match
and the names not classified will be stored in an AWS bucket folder.

After the matching, update and upload missmatched into AWS S3 bucket,
the AWS bucket files that were used will be deleted.

#### Matched names pipeline

To classify and update the matching data, pass as a parameter on
pipeline the data source name and the table name.

``` r
# Pipe matched names
matched_names_piped <- mcn::pipeline_matched_names(
  data_source_name = "Amazon RDS mercadoedu",
  table_name_fromtokey = "me_v3_pricing_fromtokey",
  table_name_pricing_course = "pricing_course",
  table_name_stopwords = "stopwords",
  bucket_name = "price-quarentine",
  objects_prefix = "run-AmazonS3_node",
  check = FALSE
)
```

##### Mount matched names

To update the matching data, create the connection to
`Amazon RDS mercadoedu` and `Amazon RDS mercadoedu` and pass as a
parameters on pipeline:

``` r
# Connect to odbc data source ####
my_con <- mcn::connect_dsn(dsn = "Amazon RDS mercadoedu")

# Mount matched names table
matched_names <- mcn::mount_matched_names(
  con = my_con,
  tbl_name_ftk = "me_v3_pricing_fromtokey",
  tbl_name_pc = "pricing_course",
  tbl_name_stopwords = "stopwords",
  bucket_name = "price-quarentine",
  objects_prefix = "run-AmazonS3_node",
  check = TRUE
)
```

##### Update matched names

The function is used to update the matching data, but you must be
connected to an ODBC data source and pass the connection as a first
parameter. It should also be passed as a parameter(`tbl_mn`) the table
`table_matched_names$matched` which was set up as a result of the
`mount_matched_names` function.

``` r
# Connect to odbc data source ####
my_con <- mcn::connect_dsn(dsn = "Amazon RDS mercadoedu")

# Update stopwords table ####
stopwords_update <- mcn::update_matched_names(
  con = my_con,
  tbl_mn = matched_names$tables$matched,
  tbl_name_ftk = "me_v3_pricing_fromtokey",
  tbl_name_pc = "pricing_course",
  check = TRUE
)
```

##### Put missmatched in S3

The function is used to put missmatched names into S3 bucket, you have
to pass as the first parameter(`tbl_mmn`), the table
`table_matched_names$missmatched` which was set up as a result of the
`mount_matched_names` function. It should also be passed as a
parameter(`bucket_name`) the name of the AWS S3 bucket where the
missmatched names will be stored.

``` r
s3_csv <- mcn::put_s3_csv(
  tbl_mmn = matched_names$tables$missmatched,
  bucket_name = "price-quarentine"
)
```

##### Delete S3 files

The function is used to delete the course names in the S3 bucket, you
have to pass as the first parameter(`bucket_objects`), the bucket
objects names `table_matched_names$bucket_objects` which was set up as a
result of the `mount_matched_names` function. It should also be passed
as a parameter(`bucket_name`) the name of the AWS S3 bucket where the
quarantine data was collected.

``` r
deleted_objects <- mcn::delete_objects(
  bucket_objects = matched_names$bucket_objects,
  bucket_name = "price-quarentine"
)
```

## Authors and acknowledgment

<table>
<tr>
<th>
Author & Maintainer
</th>
<th>
Company & Copyright Holder
</th>
</tr>
<tr>
<td align="center">
<a href="https://tawk.to/fcs.est">
<img src="./mcn/man/figures/name.png" style = "vertical-align:top;"/> </a>
<a href="https://tawk.to/fcs.est">
<img src="./mcn/man/figures/photo.png" style = "vertical-align:top;"/> </a>
</td>
<td align="center">
<a href="https://mercadoedu.com.br">
<img src="./mcn/man/figures/mercadoedu.png" style = "width:300px; margin-top:-20px; margin-bottom:20px; margin-left:50px; margin-right:50px;"/>
</a> <a href="https://www.mercadoedu.com.br">
<img src="http://files.mercadoedu.com.br/signs_8anos/common/website.png" style = "width:25px;"/>
</a> <a href="https://www.linkedin.com/company/22292521">
<img src="http://files.mercadoedu.com.br/signs_8anos/common/linkedin.png" style = "width:25px;"/>
</a> <a href="https://www.facebook.com/mercadoedu">
<img src="http://files.mercadoedu.com.br/signs_8anos/common/facebook.png" style = "width:25px;"/>
</a> <a href="https://www.instagram.com/mercadoedu_/">
<img src="http://files.mercadoedu.com.br/signs_8anos/common/instagram.png" style = "width:25px;"/>
</a>
</td>
</tr>
</table>
