# tests/testthat/test-fct_gpt_helpers.R

test_that("create_config returns expected structure", {
  config <- create_config(
    api_key = "test_key",
    assistant_id = "test_id"
  )

  expect_type(config, "list")
  expect_equal(config$api_key, "test_key")
  expect_equal(config$assistant_id, "test_id")
  expect_equal(config$common_headers$`Content-Type`, "application/json")
  expect_equal(config$common_headers$`OpenAI-Beta`, "assistants=v2")
})

test_that("init_enhanced_config validates inputs", {
  # Test valid inputs
  valid_config <- init_enhanced_config(
    api_key = "test_key",
    temperature = 0.7
  )
  expect_type(valid_config, "list")
  expect_equal(valid_config$api_key, "test_key")

  # Test missing API key
  expect_error(
    init_enhanced_config(api_key = NULL),
    "API key is required"
  )

  # Test invalid temperature
  expect_error(
    init_enhanced_config(api_key = "test_key", temperature = 3),
    "Temperature must be between 0 and 2"
  )
})

test_that("validate_api_key works correctly", {
  expect_true(validate_api_key("test_key"))
  expect_true(validate_api_key("sk-1234567890"))
  expect_false(validate_api_key(""))
  expect_false(validate_api_key(NULL))
})

test_that("get_color_scheme returns expected colors", {
  theme1 <- get_color_scheme("theme1")
  expect_type(theme1, "list")
  expect_equal(length(theme1), 2)
  expect_true(all(c("user", "assistant") %in% names(theme1)))
  expect_match(theme1$user, "^#[0-9A-F]{6}$", ignore.case = TRUE)
  expect_match(theme1$assistant, "^#[0-9A-F]{6}$", ignore.case = TRUE)
})

test_that("extract_ui_settings handles defaults", {
  input <- list()
  settings <- extract_ui_settings(input)

  expect_type(settings, "list")
  expect_true(all(c("basic", "colors", "timestamps") %in% names(settings)))
  expect_equal(settings$basic$chat_title, "Chat Interface")
  expect_equal(settings$basic$chat_height, 400)
  expect_equal(settings$basic$input_rows, 3)
})

test_that("generate_css_styles produces valid CSS", {
  settings <- list(
    colors = list(
      chat_background = "#FFFFFF",
      bubble_colors = list(
        user = "#E3E9E5",
        assistant = "#1B2B44"
      )
    ),
    basic = list(
      chat_height = 400,
      show_names = TRUE
    ),
    timestamps = list(
      position = "top"
    )
  )

  css <- generate_css_styles(settings)
  expect_type(css, "character")
  expect_match(css, "chat-interface", all = FALSE)
  expect_match(css, "chat-container", all = FALSE)
})

test_that("generate_message_renderer handles basic cases", {
  settings <- list(
    basic = list(
      show_names = TRUE,
      user_name = "User",
      assistant_name = "Assistant"
    ),
    timestamps = list(
      format = "HH:mm",
      position = "top"
    )
  )

  code <- generate_message_renderer_code(settings)
  expect_type(code, "character")
  expect_true(nchar(code) > 0)
})

# Skip API tests appropriately
test_that("API functions skip in test environment", {
  testthat::skip_on_ci()
  testthat::skip_if_offline()
  testthat::skip("Skipping API tests in default environment")
})
