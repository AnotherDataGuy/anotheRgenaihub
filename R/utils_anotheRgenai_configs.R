#' Initialize enhanced configuration for GPT API calls
#'
#' @param api_key The OpenAI API key
#' @param assistant_id Optional existing assistant ID
#' @param model GPT model name
#' @param system_prompt System instructions
#' @param functions_list Optional functions list
#' @param response_format Response format
#' @param temperature Temperature setting
#' @param max_tokens Max tokens setting
#' @param timeout_seconds Timeout in seconds
#' @param retry_attempts Number of retries
#' @param rate_limit_per_min Rate limit per minute
#' @param cache_responses Enable response caching
#' @param thread_cleanup_days Thread cleanup days
#' @return Configuration list
#' @export
init_enhanced_config <- function(
    api_key,
    assistant_id = NULL,
    model = NULL,
    system_prompt = NULL,
    functions_list = NULL,
    response_format = "markdown",
    temperature = 0.7,
    max_tokens = 1000,
    timeout_seconds = 30,
    retry_attempts = 3,
    rate_limit_per_min = 60,
    cache_responses = FALSE,
    thread_cleanup_days = 7
) {
  # Input validation
  if (is.null(api_key) || nchar(api_key) == 0) {
    stop("API key is required")
  }

  # Validate API key format
  if (!validate_api_key(api_key)) {
    stop("Invalid API key format. Please check your API key.")
  }

  # Validate numeric parameters
  if (!is.numeric(temperature) || temperature < 0 || temperature > 2) {
    stop("Temperature must be between 0 and 2")
  }
  if (!is.numeric(max_tokens) || max_tokens < 1) {
    stop("max_tokens must be positive")
  }
  if (!is.numeric(timeout_seconds) || timeout_seconds < 1) {
    stop("timeout_seconds must be positive")
  }
  if (!is.numeric(retry_attempts) || retry_attempts < 0) {
    stop("retry_attempts must be non-negative")
  }
  if (!is.numeric(rate_limit_per_min) || rate_limit_per_min < 1) {
    stop("rate_limit_per_min must be positive")
  }
  if (!is.numeric(thread_cleanup_days) || thread_cleanup_days < 1) {
    stop("thread_cleanup_days must be positive")
  }

  # Only validate creation parameters if we're actually creating an assistant
  # This check allows for "list-only" configurations
  if (is.null(assistant_id) && (!is.null(model) || !is.null(system_prompt))) {
    if (is.null(model)) {
      stop("model is required when creating a new assistant")
    }
    if (is.null(system_prompt) || !is.character(system_prompt)) {
      stop("system_prompt is required when creating a new assistant and must be a string")
    }
  }

  # Create configuration list
  config <- list(
    api_key = api_key,
    assistant_id = assistant_id,
    model = model,
    system_prompt = system_prompt,
    functions_list = functions_list,
    response_format = response_format,
    temperature = temperature,
    max_tokens = max_tokens,
    timeout_seconds = timeout_seconds,
    retry_attempts = retry_attempts,
    rate_limit_per_min = rate_limit_per_min,
    cache_responses = cache_responses,
    thread_cleanup_days = thread_cleanup_days,
    http_pattern = "^HTTP error:",
    common_headers = list(
      "Content-Type" = "application/json",
      "OpenAI-Beta" = "assistants=v2"
    )
  )

  class(config) <- c("gpt_config", class(config))
  return(config)
}

#' Validate OpenAI API key format
#'
#' @param api_key The API key to validate
#' @return logical indicating if the key is valid
#' @export
validate_api_key <- function(api_key) {
  # Only check if it's not empty
  !is.null(api_key) && nchar(trimws(api_key)) > 0
}







