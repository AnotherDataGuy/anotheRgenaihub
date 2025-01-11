#' Create configuration for API calls
#'
#' @param api_key The OpenAI API key
#' @param assistant_id The assistant ID
#' @return A list containing configuration parameters
#' @export
create_config <- function(api_key, assistant_id) {
  list(
    api_key = api_key,
    assistant_id = assistant_id,
    http_pattern = "^HTTP error:",
    common_headers = list(
      "Content-Type" = "application/json",
      "OpenAI-Beta" = "assistants=v2"
    )
  )
}

#' Create a new thread
#'
#' @param config The configuration object
#' @return Thread ID
#' @export
create_thread <- function(config) {
  Sys.sleep(0.5)
  tryCatch({
    url <- "https://api.openai.com/v1/threads"
    response <- POST(
      url,
      add_headers(
        Authorization = paste("Bearer", config$api_key),
        "Content-Type" = "application/json",
        "OpenAI-Beta" = "assistants=v2"
      ),
      encode = "json",
      timeout(10)
    )

    if (http_error(response)) {
      stop(sprintf("HTTP error: %s", http_status(response)$message))
    }

    content <- fromJSON(rawToChar(response$content))
    if (!is.null(content$error)) {
      stop(content$error$message)
    }
    return(content$id)
  }, error = function(e) {
    stop(sprintf("Thread creation failed: %s", e$message))
  })
}



#' Message settings
#'
#' @param config The configuration object
#' @param thread_id The thread ID
#' @param message The message to add
#' @param files Optional list of files to attach
#' @return Message content
#' @export
add_message <- function(config, thread_id, message, files = NULL) {
  Sys.sleep(0.5)
  tryCatch({
    url <- sprintf("https://api.openai.com/v1/threads/%s/messages", thread_id)

    # Prepare file attachments if present
    body <- list(
      role = "user",
      content = message
    )

    if (!is.null(files)) {
      file_contents <- lapply(files, function(file) {
        list(
          type = "text",
          text = list(
            value = sprintf("File: %s", file$name)
          )
        )
      })

      # Update body to include both message and files
      body$content <- list(
        list(
          type = "text",
          text = list(value = message)
        )
      )
      body$content <- c(body$content, file_contents)
    }

    response <- POST(
      url,
      add_headers(
        Authorization = paste("Bearer", config$api_key),
        "Content-Type" = "application/json",
        "OpenAI-Beta" = "assistants=v2"
      ),
      body = toJSON(body, auto_unbox = TRUE),
      encode = "raw",
      timeout(10)
    )

    if (http_error(response)) {
      stop(sprintf("HTTP error: %s", http_status(response)$message))
    }

    content <- fromJSON(rawToChar(response$content))
    if (!is.null(content$error)) {
      stop(content$error$message)
    }
    return(content)
  }, error = function(e) {
    stop(sprintf("Failed to add message: %s", e$message))
  })
}

#' Add message to thread
#'
#' @param config The configuration object
#' @param thread_id The thread ID
#' @return Message content
#' @export
run_assistant <- function(config, thread_id) {
  Sys.sleep(0.5)
  tryCatch({
    url <- sprintf("https://api.openai.com/v1/threads/%s/runs", thread_id)
    response <- POST(
      url,
      add_headers(
        Authorization = paste("Bearer", config$api_key),
        "Content-Type" = "application/json",
        "OpenAI-Beta" = "assistants=v2"
      ),
      body = toJSON(list(
        assistant_id = config$assistant_id
      ), auto_unbox = TRUE),
      encode = "raw",
      timeout(10)
    )

    if (http_error(response)) {
      stop(sprintf("HTTP error: %s", http_status(response)$message))
    }

    content <- fromJSON(rawToChar(response$content))
    if (!is.null(content$error)) {
      stop(content$error$message)
    }
    return(content$id)
  }, error = function(e) {
    stop(sprintf("Failed to run assistant: %s", e$message))
  })
}

#' Check run status
#'
#' @param config The configuration object containing API credentials and settings
#' @param thread_id The ID of the thread being checked
#' @param run_id The ID of the run to check status for
#' @return The status string from the API response
#' @export
check_run_status <- function(config, thread_id, run_id) {
  Sys.sleep(0.5)
  tryCatch({
    url <- sprintf("https://api.openai.com/v1/threads/%s/runs/%s", thread_id, run_id)
    response <- GET(
      url,
      add_headers(
        Authorization = paste("Bearer", config$api_key),
        "OpenAI-Beta" = "assistants=v2"
      ),
      timeout(10)
    )

    if (http_error(response)) {
      stop(sprintf("HTTP error: %s", http_status(response)$message))
    }

    content <- fromJSON(rawToChar(response$content))
    return(content$status)
  }, error = function(e) {
    stop(sprintf("Failed to check run status: %s", e$message))
  })
}

#' Get assistant response
#'
#' @param config The configuration object containing API credentials and settings
#' @param thread_id The ID of the thread to get responses from
#' @return The message text from the assistant's response, or "No response available yet" if none found
#' @export
get_response <- function(config, thread_id) {
  Sys.sleep(0.5)
  tryCatch({
    # First get the latest run to get usage data
    runs_url <- sprintf("https://api.openai.com/v1/threads/%s/runs", thread_id)
    runs_response <- GET(
      runs_url,
      add_headers(
        Authorization = paste("Bearer", config$api_key),
        "OpenAI-Beta" = "assistants=v2"
      ),
      timeout(10)
    )

    if (http_error(runs_response)) {
      stop(sprintf("HTTP error getting runs: %s", http_status(runs_response)$message))
    }

    runs_content <- fromJSON(rawToChar(runs_response$content), simplifyDataFrame = FALSE)
    # Debug log the runs content
    # print("Runs content:")
    # print(str(runs_content))
    usage_data <- NULL

    if (!is.null(runs_content$data) && length(runs_content$data) > 0) {
      latest_run <- runs_content$data[[1]]
      if (!is.null(latest_run$usage)) {
        usage_data <- latest_run$usage
      }
    }

    # Then get the message content as before
    messages_url <- sprintf("https://api.openai.com/v1/threads/%s/messages", thread_id)
    messages_response <- GET(
      messages_url,
      add_headers(
        Authorization = paste("Bearer", config$api_key),
        "OpenAI-Beta" = "assistants=v2"
      ),
      timeout(10)
    )

    if (http_error(messages_response)) {
      stop(sprintf("HTTP error getting messages: %s", http_status(messages_response)$message))
    }

    messages_content <- fromJSON(rawToChar(messages_response$content), simplifyDataFrame = FALSE)

    if (!is.null(messages_content$data) && length(messages_content$data) > 0) {
      assistant_idx <- vapply(messages_content$data, function(x) x$role == "assistant", logical(1))
      assistant_messages <- messages_content$data[assistant_idx]
      if (length(assistant_messages) > 0) {
        message_text <- assistant_messages[[1]]$content[[1]]$text$value
        return(list(
          response = message_text,
          usage = usage_data
        ))
      }
    }
    return(list(response = "No response available yet", usage = NULL))
  }, error = function(e) {
    stop(sprintf("Failed to get response: %s", e$message))
  })
}
