#' Rate limiter class for API requests
#' @description Creates a rate limiter to manage API request frequency
#' @importFrom R6 R6Class
#' @export
RateLimiter <- R6::R6Class(
  "RateLimiter",
  public = list(
    #' @description Create a new RateLimiter instance
    #' @param requests_per_minute Maximum number of requests allowed per minute
    #' @param max_retries Maximum number of retry attempts for failed requests
    initialize = function(requests_per_minute = 60, max_retries = 3) {
      private$rpm <- requests_per_minute
      private$max_retries <- max_retries
      private$request_times <- list()
      private$retry_delays <- c(1, 2, 4, 8, 16)  # Exponential backoff
    },

    #' @description Execute a function with rate limiting
    #' @param fn Function to execute
    #' @param ... Additional arguments passed to the function
    #' @return Result of the function execution
    execute = function(fn, ...) {
      private$cleanup_old_requests()
      private$wait_if_needed()

      result <- NULL
      error <- NULL

      for (attempt in 1:private$max_retries) {
        tryCatch({
          result <- fn(...)
          break
        }, error = function(e) {
          error <- e
          if (!private$is_retryable_error(e)) {
            stop(e)
          }
          if (attempt < private$max_retries) {
            Sys.sleep(private$retry_delays[attempt])
          }
        })
      }

      if (is.null(result) && !is.null(error)) {
        stop(error)
      }

      private$record_request()
      result
    }
  ),

  private = list(
    rpm = NULL,
    max_retries = NULL,
    request_times = NULL,
    retry_delays = NULL,

    cleanup_old_requests = function() {
      current_time <- Sys.time()
      private$request_times <- Filter(
        function(time) difftime(current_time, time, units = "mins") < 1,
        private$request_times
      )
    },

    wait_if_needed = function() {
      if (length(private$request_times) >= private$rpm) {
        oldest_allowed_time <- Sys.time() - as.difftime(1, units = "mins")
        while (length(private$request_times) >= private$rpm &&
               private$request_times[[1]] > oldest_allowed_time) {
          Sys.sleep(0.1)
          private$cleanup_old_requests()
        }
      }
    },

    record_request = function() {
      private$request_times[[length(private$request_times) + 1]] <- Sys.time()
    },

    is_retryable_error = function(error) {
      error_msg <- conditionMessage(error)
      grepl("429|500|502|503|504", error_msg) ||  # HTTP errors
        grepl("timed out|connection reset|connection refused", error_msg, ignore.case = TRUE)  # Network errors
    }
  )
)

# Initialize a global rate limiter instance
.rate_limiter <- RateLimiter$new(
  requests_per_minute = 60,
  max_retries = 3
)

#' Execute API request with rate limiting
#' @param fn The function to execute
#' @param ... Additional arguments passed to the function
#' @return The result of the function execution
#' @export
execute_with_rate_limit <- function(fn, ...) {
  .rate_limiter$execute(fn, ...)
}



#' Modify an existing OpenAI assistant
#'
#' @param config Configuration object from init_enhanced_config
#' @param assistant_id ID of the assistant to modify
#' @param model Optional new model to use
#' @param name Optional new name for the assistant
#' @param description Optional description for the assistant
#' @param instructions Optional new instructions (system prompt)
#' @param tools Optional new tools configuration
#' @return Modified assistant data
#' @export
modify_assistant <- function(config,
                             assistant_id,
                             model = NULL,
                             name = NULL,
                             description = NULL,
                             instructions = NULL,
                             tools = NULL) {
  tryCatch({
    url <- sprintf("https://api.openai.com/v1/assistants/%s", assistant_id)

    # Build body with non-null values only
    body <- list()
    if (!is.null(model)) body$model <- model
    if (!is.null(name)) body$name <- name
    if (!is.null(description)) body$description <- description
    if (!is.null(instructions)) body$instructions <- instructions
    if (!is.null(tools)) body$tools <- tools

    response <- httr::PATCH(
      url,
      httr::add_headers(
        Authorization = paste("Bearer", config$api_key),
        "Content-Type" = "application/json",
        "OpenAI-Beta" = "assistants=v2"
      ),
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      encode = "raw"
    )

    if (httr::http_error(response)) {
      content <- jsonlite::fromJSON(rawToChar(response$content))
      stop(paste("HTTP error:", content$error$message))
    }

    content <- jsonlite::fromJSON(rawToChar(response$content))
    return(content)
  }, error = function(e) {
    stop(sprintf("Failed to modify assistant: %s", e$message))
  })
}


#' Execute assistant with enhanced configuration
#'
#' @param config The enhanced configuration object
#' @param thread_id The thread ID
#' @return Run ID
#' @export
execute_assistant <- function(config, thread_id) {
  tryCatch({
    url <- sprintf("https://api.openai.com/v1/threads/%s/runs", thread_id)

    body <- list(assistant_id = config$assistant_id)

    response <- httr::POST(
      url,
      httr::add_headers(
        Authorization = paste("Bearer", config$api_key),
        "Content-Type" = "application/json",
        "OpenAI-Beta" = "assistants=v2"
      ),
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      encode = "json"
    )

    if (httr::http_error(response)) {
      content <- jsonlite::fromJSON(rawToChar(response$content))
      stop(paste("HTTP error:", content$error$message))
    }

    content <- jsonlite::fromJSON(rawToChar(response$content))
    return(content$id)
  }, error = function(e) {
    stop(sprintf("Failed to execute assistant: %s", e$message))
  })
}


#' Create a new OpenAI assistant
#'
#' @param config Configuration object from init_enhanced_config
#' @param name Optional name for the assistant
#' @return Assistant ID string
#' @export
init_new_assistant <- function(config, name = NULL) {
  if (!is.null(config$assistant_id)) {
    stop("Configuration already has an assistant_id")
  }

  tryCatch({
    url <- "https://api.openai.com/v1/assistants"

    # Build the body with all required parameters
    body <- list(
      model = config$model,
      name = if(is.null(name)) paste0("Assistant-", format(Sys.time(), "%Y%m%d-%H%M%S")) else name,
      instructions = config$system_prompt
    )

    response <- httr::POST(
      url,
      httr::add_headers(
        Authorization = paste("Bearer", config$api_key),
        "Content-Type" = "application/json",
        "OpenAI-Beta" = "assistants=v2"
      ),
      body = jsonlite::toJSON(body, auto_unbox = TRUE),
      encode = "raw"
    )

    if (httr::http_error(response)) {
      content <- jsonlite::fromJSON(rawToChar(response$content))
      stop(paste("HTTP error:", content$error$message))
    }

    content <- jsonlite::fromJSON(rawToChar(response$content))
    return(content$id)

  }, error = function(e) {
    stop(sprintf("Failed to create assistant: %s", e$message))
  })
}

#' Delete an OpenAI assistant
#'
#' @param config Configuration object from init_enhanced_config
#' @param assistant_id ID of assistant to delete
#' @return Logical indicating success
#' @export
remove_assistant <- function(config, assistant_id) {
  tryCatch({
    url <- sprintf("https://api.openai.com/v1/assistants/%s", assistant_id)

    response <- httr::DELETE(
      url,
      httr::add_headers(
        Authorization = paste("Bearer", config$api_key),
        "OpenAI-Beta" = "assistants=v2"
      )
    )

    if (httr::http_error(response)) {
      stop(sprintf("HTTP error: %s", httr::http_status(response)$message))
    }

    content <- jsonlite::fromJSON(rawToChar(response$content))
    if (!is.null(content$error)) {
      stop(content$error$message)
    }

    return(content$deleted)
  }, error = function(e) {
    stop(sprintf("Failed to delete assistant: %s", e$message))
  })
}

#' List available OpenAI assistants
#'
#' @param config Fetch assistants protocole with GET
#' @return Data frame of assistants
#' @export
fetch_assistants <- function(config) {
  tryCatch({
    url <- "https://api.openai.com/v1/assistants"

    response <- httr::GET(
      url,
      httr::add_headers(
        Authorization = paste("Bearer", config$api_key),
        "OpenAI-Beta" = "assistants=v2"
      )
    )

    if (httr::http_error(response)) {
      stop(sprintf("HTTP error: %s", httr::http_status(response)$message))
    }

    content <- jsonlite::fromJSON(rawToChar(response$content))

    if (length(content$data) == 0) {
      return(data.frame(
        id = character(0),
        name = character(0),
        stringsAsFactors = FALSE
      ))
    }

    return(content$data)
  }, error = function(e) {
    stop(sprintf("Failed to list assistants: %s", e$message))
  })
}

#' Create a new thread with enhanced configuration
#'
#' @param config The enhanced configuration object
#' @return Thread ID
#' @export
init_thread <- function(config) {
  Sys.sleep(0.5)
  tryCatch({
    url <- "https://api.openai.com/v1/threads"

    response <- httr::POST(
      url = url,
      httr::add_headers(
        Authorization = paste("Bearer", config$api_key),
        "Content-Type" = "application/json",
        "OpenAI-Beta" = "assistants=v2"
      ),
      body = jsonlite::toJSON(list(), auto_unbox = TRUE),
      encode = "raw"
    )

    if (httr::http_error(response)) {
      stop(sprintf("HTTP error: %s", httr::http_status(response)$message))
    }

    content <- jsonlite::fromJSON(rawToChar(response$content))
    if (!is.null(content$error)) {
      stop(content$error$message)
    }
    return(content$id)
  }, error = function(e) {
    stop(sprintf("Thread creation failed: %s", e$message))
  })
}


#' Send message to thread with enhanced configuration
#'
#' @param config The enhanced configuration object
#' @param thread_id The thread ID
#' @param message The message to add
#' @param files Optional list of files to attach
#' @return Message content
#' @export
send_message <- function(config, thread_id, message, files = NULL) {
  execute_with_rate_limit(function() {
    Sys.sleep(0.5)
    tryCatch({
      if (is.null(thread_id) || nchar(thread_id) == 0) {
        stop("Thread ID cannot be null or empty")
      }

      if (is.null(message) || nchar(trimws(message)) == 0) {
        stop("Message cannot be null or empty")
      }

      if (is.null(config) || is.null(config$api_key)) {
        stop("Configuration or API key is missing")
      }

      url <- sprintf("https://api.openai.com/v1/threads/%s/messages", thread_id)

      # Prepare file attachments if present
      file_objects <- NULL
      if (!is.null(files)) {
        file_objects <- lapply(files, function(file) {
          list(
            type = "file",
            text = list(
              type = "text",
              value = sprintf("File: %s", file$name)
            )
          )
        })
      }

      # Prepare message body
      body <- list(
        role = "user",
        content = if (!is.null(file_objects)) {
          c(
            list(list(type = "text", text = list(value = message))),
            file_objects
          )
        } else {
          message
        }
      )

      response <- httr::POST(
        url = url,
        httr::add_headers(
          Authorization = paste("Bearer", config$api_key),
          "Content-Type" = "application/json",
          "OpenAI-Beta" = "assistants=v2"
        ),
        body = jsonlite::toJSON(body, auto_unbox = TRUE, null = "null"),
        encode = "json"
      )

      if (httr::http_error(response)) {
        error_content <- jsonlite::fromJSON(rawToChar(response$content))
        stop(paste("HTTP error:", error_content$error$message))
      }

      content <- jsonlite::fromJSON(rawToChar(response$content))
      if (!is.null(content$error)) {
        stop(content$error$message)
      }

      return(content)

    }, error = function(e) {
      msg <- sprintf("Failed to add message: %s. Thread ID: %s", e$message, thread_id)
      stop(msg)
    })
  })
}



#' Monitor run status with enhanced configuration
#'
#' @param config The enhanced configuration object
#' @param thread_id The thread ID
#' @param run_id The run ID to check status for
#' @return The status string from the API response
#' @export
monitor_run_status <- function(config, thread_id, run_id) {
  Sys.sleep(0.5)
  tryCatch({
    # Validate inputs
    if (is.null(thread_id) || nchar(thread_id) == 0) {
      stop("Thread ID is required")
    }
    if (is.null(run_id) || nchar(run_id) == 0) {
      stop("Run ID is required")
    }
    if (is.null(config$api_key)) {
      stop("API key is required in config")
    }

    url <- sprintf("https://api.openai.com/v1/threads/%s/runs/%s", thread_id, run_id)
    response <- httr::GET(
      url,
      httr::add_headers(
        Authorization = paste("Bearer", config$api_key),
        "OpenAI-Beta" = "assistants=v2"
      ),
      httr::timeout(config$timeout_seconds)
    )

    if (httr::http_error(response)) {
      content <- jsonlite::fromJSON(rawToChar(response$content))
      stop(sprintf("HTTP error: %s", content$error$message))
    }

    content <- jsonlite::fromJSON(rawToChar(response$content))
    return(content$status)
  }, error = function(e) {
    stop(sprintf("Failed to check run status: %s", e$message))
  })
}

#' Retrieve assistant response
#'
#' @param config The enhanced configuration object
#' @param thread_id The thread ID
#' @return The message text from the assistant's response
#' @export
fetch_response <- function(config, thread_id) {

  execute_with_rate_limit(function() {
    tryCatch({
      url <- sprintf("https://api.openai.com/v1/threads/%s/messages", thread_id)
      response <- httr::GET(
        url,
        httr::add_headers(
          Authorization = paste("Bearer", config$api_key),
          "OpenAI-Beta" = "assistants=v2"
        )
      )

      if (httr::http_error(response)) {
        stop(sprintf("HTTP error: %s", httr::http_status(response)$message))
      }

      content <- jsonlite::fromJSON(rawToChar(response$content))
      if (!is.null(content$data) && length(content$data) > 0) {
        # Get most recent assistant message
        assistant_messages <- content$data[content$data$role == "assistant", ]
        if (nrow(assistant_messages) > 0) {
          return(assistant_messages$content[[1]]$text$value)
        }
      }
      return(NULL)
    }, error = function(e) {
      stop(sprintf("Failed to get response: %s", e$message))
    })
  })
}

#' Refresh assistant response
#' @export
refreshAssistants <- function() {
  response <- httr::GET(
    "https://api.openai.com/v1/assistants",
    httr::add_headers(
      Authorization = paste("Bearer", rv$config$api_key),
      "OpenAI-Beta" = "assistants=v2"
    )
  )

  if (!httr::http_error(response)) {
    content <- jsonlite::fromJSON(rawToChar(response$content))
    rv$assistants <- content$data
  }
}
