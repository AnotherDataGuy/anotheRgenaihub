# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
###################################
#### CURRENT FILE: DEV SCRIPT #####
###################################

# Engineering

## Dependencies ----
## Amend DESCRIPTION with dependencies read from package code parsing
## install.packages('attachment') # if needed.
attachment::att_amend_desc()

## Add modules ----
## Create a module infrastructure in R/
golem::add_module(name = "assistant_builder_hub", with_test = TRUE) # Name of the module
golem::add_module(name = "main_local_gpt_agent", with_test = TRUE) # Name of the module

## Add helper functions ----
## Creates fct_* and utils_*
### Examples
golem::add_fct("helpers", with_test = TRUE)
golem::add_utils("helpers", with_test = TRUE)

### Created for this app
golem::add_fct("gpt_helpers", with_test = TRUE)
golem::add_fct("gpt_helpers_for_interface", with_test = TRUE)
golem::add_utils("dynamic_gpt_agent_ui", with_test = TRUE)
golem::add_utils("dynamic_gpt_agent_server", with_test = TRUE)
golem::add_utils("dynamic_gpt_api", with_test = TRUE)

# code extraction from anotheRgenaiHub
golem::add_fct("helpers_server_to_template", with_test = TRUE)

golem::add_utils("dynamic_gpt_config", with_test = TRUE)
golem::add_utils("utils_dynamic_gpt_api", with_test = TRUE)
golem::add_utils("dynamic_gpt_config", with_test = TRUE)




# Security protocol to access the app
### To remove before deployment
keyring::key_set("YourKeys", "YourIdentifiers")

# Set users
### To remove before deployment
users <- data.frame(
  user = c("user1", "user2", "user3"),
  password = c("pwd1", "pwd2", "pwd3"),
  admin = c(TRUE, FALSE, FALSE),
  stringsAsFactors = FALSE
)

## Create the SQLite database
### To remove before deployment
shinymanager::create_db(
  credentials_data = users,
  sqlite_path = "anotherworkhubusers.sqlite",  # Path to save the database
  passphrase = "your_password"
)
conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = "anotherworkhubusers.sqlite")

retrieved_users <- shinymanager::read_db_decrypt(
  conn = conn,
  name = "credentials",  # Default table name
  passphrase =  keyring::key_get("YourKeys", "YourIdentifiers")
)

# Print the retrieved users
print(retrieved_users)



## External resources
## Creates .js and .css files at inst/app/www
golem::add_js_file("script")
golem::add_js_handler("handlers")
golem::add_css_file("main_local_interface")
golem::add_sass_file("custom")
golem::add_any_file("file.json")

## Add internal datasets ----
## If you have data in your package
usethis::use_data_raw(name = "my_dataset", open = FALSE)

## Tests ----
## Add one line by test you want to create
usethis::use_test("app")

# Documentation

## Vignette ----
usethis::use_vignette("anotheRgenaihub")
devtools::build_vignettes()

## Code Coverage----
## Set the code coverage service ("codecov" or "coveralls")
usethis::use_coverage()

# Create a summary readme for the testthat subdirectory
covrpage::covrpage()

## CI ----
## Use this part of the script if you need to set up a CI
## service for your application
##
## (You'll need GitHub there)
usethis::use_github()

# GitHub Actions
usethis::use_github_action()
# Chose one of the three
# See https://usethis.r-lib.org/reference/use_github_action.html
usethis::use_github_action_check_release()
usethis::use_github_action_check_standard()
usethis::use_github_action_check_full()
# Add action for PR
usethis::use_github_action_pr_commands()

# Circle CI
usethis::use_circleci()
usethis::use_circleci_badge()

# Jenkins
usethis::use_jenkins()

# GitLab CI
usethis::use_gitlab_ci()

# You're now set! ----
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")
