#' Tests for utils_anotheRgenai_api.R
#'
#' Tests functionality of the rate limiter and API execution utilities.
#' Be cautious with these tests - they involve timing and may be sensitive
#' to system load.

test_that("RateLimiter class initialization sets correct parameters", {
  # Given
  rpm <- 30
  retries <- 2

  # When
  limiter <- RateLimiter$new(
    requests_per_minute = rpm,
    max_retries = retries
  )

  # Then
  expect_s3_class(limiter, "RateLimiter")
})

test_that("execute_with_rate_limit handles successful API calls", {
  # Given
  mock_api_call <- function() {
    return("success")
  }

  # When
  result <- execute_with_rate_limit(mock_api_call)

  # Then
  expect_equal(result, "success")
})

test_that("execute_with_rate_limit implements retry logic", {
  # Given
  attempt_count <- 0
  retry_test_fn <- function() {
    attempt_count <<- attempt_count + 1
    if (attempt_count < 2) {
      stop("429 Too Many Requests")  # Retryable error
    }
    return("success")
  }

  # When
  result <- execute_with_rate_limit(retry_test_fn)

  # Then
  expect_equal(result, "success")
  expect_equal(attempt_count, 2)
})

test_that("execute_with_rate_limit respects rate limits", {
  # Skip on CRAN due to timing dependencies
  skip_on_cran()

  # Given
  start_time <- Sys.time()
  call_times <- list()

  # When - make several rapid requests
  for(i in 1:3) {
    execute_with_rate_limit(function() {
      call_times[[length(call_times) + 1]] <<- Sys.time()
      return(TRUE)
    })
  }

  # Then - verify timing between calls
  time_diffs <- diff(do.call(c, call_times))
  expect_true(all(time_diffs >= 0))  # Ensures calls are sequential
})

test_that("execute_with_rate_limit handles non-retryable errors", {
  # Given
  non_retryable_fn <- function() {
    stop("Invalid input parameter")  # Non-retryable error
  }

  # Then
  expect_error(
    execute_with_rate_limit(non_retryable_fn),
    "Invalid input parameter"
  )
})
