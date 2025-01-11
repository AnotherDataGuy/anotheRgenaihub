#' main_local_gpt_agent UI Function
#'
#' @description A shiny Module.
#'
#'@param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyjs runjs
mod_main_local_gpt_agent_ui <- function(id) {
  ns <- NS(id)

  div(
    tags$head(
      tags$style("
  .chat-messages {
    display: flex;
    flex-direction: column;
    gap: 10px;
    overflow-y: auto;
  }
  /* Use a different CSS clearfix approach */
  .chat-messages:before,
  .chat-messages:after {
    content: ' ';
    display: table;
  }
  .chat-messages:after {
    clear: both;
  }
")
    ),
    class = "chat-interface",
    style = "margin: 0 auto;padding: 2vw;",
    useShinyjs(),
    fluidRow(
      column(
        width = 8,
        div(
          class = "panel panel-default",
          div(class = "panel-heading",
              h4(class = "panel-title", "Chat Interface")
          ),
          div(
            class = "panel-body chat-messages",
            style = "height: 400px; overflow-y: auto; padding: 15px; background-color: #e5e5e533;",
            # uiOutput(ns("messages"))
            htmlOutput(ns("response"))
          ),
          div(
            class = "panel-footer",
            style = "padding: 15px;",
            textAreaInput(
              ns("user_input"),
              label = NULL,
              rows = 3,
              width = "100%",
              placeholder = "Type your message (max 500 characters)",
              value = ""
            ),
            div(
              style = "display: flex; justify-content: space-between; margin-top: 5px;",
              div(
                textOutput(ns("char_count")),
                style = "color: #666; font-size: 0.9em;"
              ),
              div(
                textOutput(ns("interactions_left")),
                style = "color: #666; font-size: 0.9em;"
              )
            ),
            div(
              style = "margin-top: 10px;",
              actionButton(ns("ask_button"), "Send", class = "btn btn-primary"),
              actionButton(ns("reset_button"), "Reset Thread", class = "btn-warning")
            ),
            div(
              class = "alert alert-info",
              textOutput(ns("thread_status"))
            ),
            conditionalPanel(
              condition = sprintf("input['%s']", ns("show_debug")),
              verbatimTextOutput(ns("debug_output"))
            ),
            # div(
            #   class = "well",
            #   htmlOutput(ns("response"))
            # ),
            checkboxInput(ns("show_debug"), "Show Debug Logs", value = FALSE)
          )
        )


    ),
    column(
      width = 4,
      div(
        class = "panel panel-default",
        div(class = "panel-heading",
            h4(class = "panel-title", "Usage Metrics")
        ),
        div(class = "panel-body",
            htmlOutput(ns("metrics_summary"))
        )
      )
    )

    )
  )



}


globalVariables(c("e", "prompt", "completion", "total", "timestamp", "tokens", "type", "response_time"))



#' mod_main_local_gpt_agent_server
#'
#' @param id The Module ID
#' @param config Configuration list with API credentials
#' @importFrom shiny moduleServer reactive reactiveVal observeEvent
#' @importFrom shinyjs runjs disable
#' @importFrom rlang .data tail
#' @import ggplot2
#' @import plotly
#' @noRd
mod_main_local_gpt_agent_server <- function(id, config, shared_state){
  moduleServer(id, function(input, output, session) {
    # messages <- reactiveVal(list())
    ns <- session$ns

    MAX_LOG_ENTRIES <- 100

    values <- reactiveValues(
      thread_id = NULL,
      debug_logs = character(),
      is_processing = FALSE,
      # New metrics
      current_prompt_tokens = 0,
      current_completion_tokens = 0,
      current_total_tokens = 0,
      total_prompt_tokens = 0,
      total_completion_tokens = 0,
      total_tokens = 0,
      start_time = NULL,
      response_time = 0
    )
    # Start timing

    initialize_thread <- function() {
      values$debug_logs <- character()
      shared_state$thread_id <- create_thread(config)
      values$debug_logs <- c(values$debug_logs,
                             sprintf("Thread created successfully: %s", shared_state$thread_id))
    }

    observeEvent(input$reset_button, {
      shared_state$thread_id <- NULL
      # messages(list())  # Reset messages
      # Reset metrics
      shared_state$messages <- list()

      values$current_prompt_tokens <- 0
      values$current_completion_tokens <- 0
      values$current_total_tokens <- 0
      shared_state$metrics$total_prompt_tokens <- 0
      shared_state$metrics$total_completion_tokens <- 0
      shared_state$metrics$total_tokens <- 0
      shared_state$metrics$response_times <- numeric()
      shared_state$metrics$timestamps <- character()
      initialize_thread()
    })

    output$thread_status <- renderText({
      if (!is.null(shared_state$thread_id)) {
        sprintf("Active thread ID: %s", shared_state$thread_id)
      } else {
        "No active thread"
      }
    })

    observeEvent(input$ask_button, {
      req(input$user_input)
      values$start_time <- Sys.time()

      # Early return if already processing
      if (values$is_processing) {
        showNotification("Please wait for the current request to complete", type = "warning")
        return()
      }

      # Update processing state
      values$is_processing <- TRUE
      values$debug_logs <- c(values$debug_logs, "Processing new request...")

      # Store current user message in shared state
      shared_state$messages <- c(shared_state$messages,
                                 list(list(type = "user", text = input$user_input)))



      # Validate message length
      if (nchar(input$user_input) > 500) {
        showNotification("Message exceeds 500 characters limit", type = "error")
        return()
      }

      # Check interaction limit
      interactions_used <- length(shared_state$messages) / 2
      if (interactions_used >= 10) {
        showNotification(
          "You have reached the maximum number of interactions. Please start a new thread.",
          type = "warning"
        )
        return()
      }

      # Update UI immediately with user message
      output$response <- renderUI({
        div(
          class = "chat-messages",
          lapply(shared_state$messages, function(msg) {
            if (msg$type == "user") {
              div(class = "chat-message user-message",
                  style = "background: #007bff; color: white; padding: 10px;
                      margin: 5px; border-radius: 15px; margin-left: 20%;
                      max-width: 70%; float: right; clear: both;",
                  msg$text
              )
            } else {
              div(class = "chat-message assistant-message",
                  style = "background: #f8f9fa; padding: 10px; margin: 5px;
                      border-radius: 15px; margin-right: 20%;
                      max-width: 70%; float: left; clear: both;",
                  msg$text
              )
            }
          })
        )
      })

      # Initialize thread if needed
      if (is.null(shared_state$thread_id)) {
        tryCatch({
          initialize_thread()
        }, error = function(e) {
          values$debug_logs <- c(values$debug_logs,
                                 sprintf("Thread initialization error: %s", e$message))
          showNotification(sprintf("Failed to initialize thread: %s", e$message),
                           type = "error")
          values$is_processing <- FALSE
          return()
        })
      }

      # Process the message
      withProgress(message = 'Getting response...', {
        tryCatch({
          # Add message to thread
          add_message(config, shared_state$thread_id, input$user_input)

          values$debug_logs <- c(values$debug_logs, "Message added successfully")

          # Run assistant
          run_id <- run_assistant(config, shared_state$thread_id)
          values$debug_logs <- c(values$debug_logs,
                                 sprintf("Assistant run started: %s", run_id))

          # Check status
          status <- "queued"
          attempts <- 0
          max_attempts <- 30

          while (status %in% c("queued", "in_progress") && attempts < max_attempts) {
            Sys.sleep(1)
            status <- check_run_status(config, shared_state$thread_id, run_id)
            values$debug_logs <- c(values$debug_logs, sprintf("Status: %s", status))
            attempts <- attempts + 1
          }

          if (attempts >= max_attempts) {
            stop("Request timed out after 30 seconds")
          }

          if (status == "completed") {
            # Get and display response
            response_data <- get_response(config, shared_state$thread_id)

            # print(str(response_data))

            # Extract the actual text from the response
            response_text <- if (is.list(response_data)) {
              if (!is.null(response_data$response)) {
                response_data$response
              } else if (!is.null(response_data$text)) {
                response_data$text
              } else if (!is.null(response_data$content)) {
                response_data$content
              } else {
                "Error: Unable to extract response text"
              }
            } else if (is.character(response_data)) {
              response_data
            } else {
              "Error: Unexpected response format"
            }

            # Calculate response time
            values$response_time <- round(as.numeric(difftime(Sys.time(), values$start_time, units = "secs")), 1)


            # Update token counts from the API response
            if (is.list(response_data) && !is.null(response_data$usage)) {
              # Update current session values
              values$current_prompt_tokens <- response_data$usage$prompt_tokens
              values$current_completion_tokens <- response_data$usage$completion_tokens
              values$current_total_tokens <- response_data$usage$total_tokens

              # Update shared state metrics
              shared_state$metrics$prompt_tokens <- c(shared_state$metrics$prompt_tokens,
                                                      response_data$usage$prompt_tokens)
              shared_state$metrics$completion_tokens <- c(shared_state$metrics$completion_tokens,
                                                          response_data$usage$completion_tokens)
              shared_state$metrics$total_tokens <- c(shared_state$metrics$total_tokens,
                                                     response_data$usage$total_tokens)
              current_timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
              shared_state$metrics$timestamps <- c(shared_state$metrics$timestamps,
                                                   current_timestamp)

              # Calculate response time and add to metrics
              values$response_time <- round(as.numeric(difftime(Sys.time(),
                                                                values$start_time,
                                                                units = "secs")), 1)
              shared_state$metrics$response_times <- c(shared_state$metrics$response_times,
                                                       values$response_time)
            }

            # Add assistant response to messages
            shared_state$messages <- c(shared_state$messages,
                                       list(list(type = "assistant", text = response_text)))

            # Update UI with all messages
            output$response <- renderUI({
              div(
                class = "chat-messages",
                lapply(shared_state$messages, function(msg) {
                  if (msg$type == "user") {
                    div(class = "chat-message user-message",
                        style = "background: #007bff; color: white; padding: 10px;
                            margin: 5px; border-radius: 15px; margin-left: 20%;
                            max-width: 70%; float: right; clear: both;",
                        msg$text
                    )
                  } else {
                    div(class = "chat-message assistant-message",
                        style = "background: #f8f9fa; padding: 10px; margin: 5px;
                            border-radius: 15px; margin-right: 20%;
                            max-width: 70%; float: left; clear: both;",
                        msg$text
                    )
                  }
                })
              )
            })
          } else {
            # Handle error status
            error_msg <- sprintf("Error: Final status was %s", status)
            shared_state$messages <- c(shared_state$messages,
                                       list(list(type = "error", text = sprintf("Error: %s", e$message))))
            # messages(shared_state$messages)
          }

        }, error = function(e) {
          # Handle errors
          values$debug_logs <- c(values$debug_logs, sprintf("Error: %s", e$message))
          if (length(values$debug_logs) > MAX_LOG_ENTRIES) {
            values$debug_logs <- utils::tail(values$debug_logs, MAX_LOG_ENTRIES)
          }

          # Add error message to chat
          shared_state$messages <- c(shared_state$messages,
                                list(list(type = "error", text = sprintf("Error: %s", e$message)))
          )
          # messages(shared_state$messages)

          # Update UI
          output$response <- renderUI({
            div(
              class = "chat-messages",
              lapply(shared_state$messages, function(msg) {
                if (msg$type == "error") {
                  div(class = "chat-message error-message",
                      style = "background: #dc3545; color: white; padding: 10px;
                          margin: 5px; border-radius: 15px; margin-right: 20%;
                          max-width: 70%; float: left; clear: both;",
                      msg$text
                  )
                } else if (msg$type == "user") {
                  div(class = "chat-message user-message",
                      style = "background: #007bff; color: white; padding: 10px;
                          margin: 5px; border-radius: 15px; margin-left: 20%;
                          max-width: 70%; float: right; clear: both;",
                      msg$text
                  )
                } else {
                  div(class = "chat-message assistant-message",
                      style = "background: #f8f9fa; padding: 10px; margin: 5px;
                          border-radius: 15px; margin-right: 20%;
                          max-width: 70%; float: left; clear: both;",
                      msg$text
                  )
                }
              })
            )
          })
        })
      })

      # Reset processing state
      values$is_processing <- FALSE

      # Clear input
      updateTextAreaInput(session, "user_input", value = "")
    })

    output$debug_output <- renderPrint({
      n <- length(values$debug_logs)
      if (n == 0) return(invisible())
      writeLines(values$debug_logs)
    })



    output$metrics_summary <- renderUI({
      ns <- NS(id)
      div(
        class = "metrics-content",
        # Token Calculator Link
        div(
          class = "metrics-info",
          style = "margin-bottom: 15px; text-align: right;",
          tags$a(
            href = "https://token-calculator.net/",
            target = "_blank",
            icon("calculator"),
            "Token Calculator",
            style = "color: #0275d8 !important; text-decoration: none;"
          )
        ),

        # Current Call Section
        div(
          class = "metrics-section",
          h4(class = "metrics-header", "Current Call"),

          # Token Usage Grid
          div(
            class = "metrics-grid",
            # Prompt Tokens
            div(
              class = "metric-card",
              div(class = "metric-card-header",
                  icon("keyboard"),
                  span("Prompt")
              ),
              div(class = "metric-card-value",
                  values$current_prompt_tokens,
                  span("tokens", class = "metric-unit")
              )
            ),
            # Completion Tokens
            div(
              class = "metric-card",
              div(class = "metric-card-header",
                  icon("robot"),
                  span("Completion")
              ),
              div(class = "metric-card-value",
                  values$current_completion_tokens,
                  span("tokens", class = "metric-unit")
              )
            ),
            # Total Tokens
            div(
              class = "metric-card",
              div(class = "metric-card-header",
                  icon("calculator"),
                  span("Current total")
              ),
              div(class = "metric-card-value",
                  values$current_total_tokens,
                  span("tokens", class = "metric-unit")
              )
            ),
            div(
              class = "metric-card response-time",
              div(class = "metric-card-header",
                  icon("clock"),
                  span("Response Time")
              ),
              div(class = "metric-card-value",
                  sprintf("%.1f", values$response_time),
                  span("seconds", class = "metric-unit")
              )
            )
          )
        ),

        # Conversation Total Section
        div(
          class = "metrics-section",
          h4(class = "metrics-header", "Conversation Total"),
          div(
            class = "metric-card highlight",
            div(class = "metric-card-header",
                icon("chart-bar"),
                span("Total Usage")
            ),
            div(class = "metric-card-value",
                sum(shared_state$metrics$total_tokens, na.rm = TRUE),  # Sum the values and handle NAs
                span("tokens", class = "metric-unit")
            )
          )
        ),

        # Add plots section
        div(
          class = "metrics-section plots",
          style = "margin-top: 20px;",
          h4(class = "metrics-header", "Usage Analytics"),
          div(
            style = "background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 15px;",
            plotlyOutput(ns("token_usage_plot"), height = "300px")
          ),
          div(
            style = "background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
            plotlyOutput(ns("response_time_plot"), height = "300px")
          )
        )
      )
    })




    # Token usage plot
    output$token_usage_plot <- renderPlotly({
      req(length(shared_state$metrics$timestamps) > 0)

      df <- data.frame(
        timestamp = as.POSIXct(shared_state$metrics$timestamps),
        prompt = cumsum(shared_state$metrics$prompt_tokens),
        completion = cumsum(shared_state$metrics$completion_tokens),
        total = cumsum(shared_state$metrics$total_tokens)
      )

      # Reshape data for better plotting
      df_long <- tidyr::pivot_longer(
        df,
        cols = c(prompt, completion, total),
        names_to = "type",
        values_to = "tokens"
      )

      p <- ggplot(df_long, aes(x = .data$timestamp,
                               y = .data$tokens,
                               color = .data$type)) +
        geom_line(aes(linetype = .data$type), size = 1) +
        scale_color_manual(values = c("completion" = "#E53935",
                                      "prompt" = "#43A047",
                                      "total" = "#1E88E5")) +
        scale_linetype_manual(values = c("completion" = "dashed",
                                         "prompt" = "dashed",
                                         "total" = "solid")) +
        theme_minimal() +
        labs(title = "Token Usage Over Time",
             x = "Time",
             y = "Tokens") +
        theme(legend.position = "bottom",
              legend.title = element_blank())

      ggplotly(p) %>%
        layout(hovermode = "x unified")
    })

    # Response time plot
    output$response_time_plot <- renderPlotly({
      req(length(shared_state$metrics$response_times) > 0)

      df <- data.frame(
        timestamp = as.POSIXct(shared_state$metrics$timestamps),
        response_time = shared_state$metrics$response_times
      )

      p <- p <- ggplot(df, aes(x = .data$timestamp,
                               y = .data$response_time)) +
        geom_line(color = "#1E88E5", size = 1) +
        geom_point(color = "#1E88E5", size = 3) +
        geom_smooth(method = "loess", span = 0.3, se = FALSE,
                    color = "#E53935", size = 1) +
        theme_minimal() +
        labs(title = "Response Time per Call",
             x = "Time",
             y = "Response Time (seconds)") +
        theme(legend.position = "bottom")

      ggplotly(p) %>%
        layout(hovermode = "x unified") %>%
        config(displayModeBar = FALSE)
    })





    js_code <- sprintf('
  $(document).ready(function() {
    $("#%s").attr("maxlength", "500");
  });
', ns("user_input"))


    shinyjs::runjs(js_code)

    output$char_count <- renderText({
      current_length <- nchar(input$user_input)
      sprintf("%d/500 characters", current_length)
    })

    # Interactions left output
    output$interactions_left <- renderText({
      interactions_used <- length(shared_state$messages) / 2  # Divide by 2 because each interaction has user + assistant message
      interactions_left <- 10 - interactions_used
      sprintf("%d interactions remaining", max(0, floor(interactions_left)))
    })

    # Enable/disable input based on limits
    observe({
      interactions_used <- length(shared_state$messages) / 2
      if (interactions_used >= 10) {
        shinyjs::disable(ns("user_input"))    # Add ns()
        shinyjs::disable(ns("ask_button"))
        showNotification(
          "You have reached the maximum number of interactions. Please start a new thread.",
          type = "warning",
          duration = NULL
        )
      }
    })




  })
}

## To be copied in the UI
# mod_main_local_gpt_agent_ui("main_local_gpt_agent_1")

## To be copied in the server
# mod_main_local_gpt_agent_server("main_local_gpt_agent_1")
