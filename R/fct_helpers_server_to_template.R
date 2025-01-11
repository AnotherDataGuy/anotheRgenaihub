#' helpers_server_to_template
#' Extract and process UI customization settings
#' @description Extracts all UI customization settings from the input and processes them into a structured format
#' @param input Shiny input object
#' @return List of processed UI settings
#' @export
extract_ui_settings <- function(input) {
  # Basic Settings
  basic_settings <- list(
    chat_title = input$chat_title %||% "Chat Interface",
    chat_theme = input$chat_theme %||% "light",
    chat_height = input$chat_height %||% 400,
    input_rows = input$input_rows %||% 3,
    send_button_text = input$send_button_text %||% "Send",
    new_chat_text = input$new_chat_text %||% "New Chat",
    show_names = input$show_names %||% TRUE,
    user_name = input$user_name %||% "User",
    assistant_name = input$assistant_name %||% "Assistant"
  )

  # Color Settings
  color_settings <- list(
    color_scheme = input$color_scheme %||% "theme1",
    chat_background = input$chat_background %||% "#FFFFFF",
    bubble_colors = get_color_scheme(input$color_scheme %||% "theme1")
  )

  # Timestamp Settings
  timestamp_settings <- list(
    format = input$timestamp_format %||% "none",
    position = input$timestamp_position %||% "top"
  )

  list(
    basic = basic_settings,
    colors = color_settings,
    timestamps = timestamp_settings
  )
}

#' Generate CSS styles from settings
#' @param settings Extracted UI settings
#' @return String containing CSS styles
#' @export
generate_css_styles <- function(settings) {
  sprintf('
    .chat-interface {
      max-width: 800px;
      margin: 0 auto;
    }

    .chat-container {
      background-color: %s;
      height: %dpx;
      overflow-y: auto;
      padding: 15px;
      border-radius: 4px;
    }

    .user-message {
      background-color: %s;
      margin-left: 20%%;
      padding: 10px;
      margin-bottom: 10px;
      border-radius: 8px;
    }

    .assistant-message {
      background-color: %s;
      color: white;
      margin-right: 20%%;
      padding: 10px;
      margin-bottom: 10px;
      border-radius: 8px;
    }

    .message-timestamp {
      font-size: 0.8em;
      opacity: 0.7;
      %s
    }

    .message-sender {
      font-weight: bold;
      margin-bottom: 5px;
      %s
    }',
          settings$colors$chat_background,
          settings$basic$chat_height,
          settings$colors$bubble_colors$user,
          settings$colors$bubble_colors$assistant,
          if(settings$timestamps$position %in% c("inside_right", "inside_left")) {
            "display: inline-block; margin-left: 8px;"
          } else {
            "margin-bottom: 4px;"
          },
          if(settings$basic$show_names) "display: block;" else "display: none;"
  )
}

#' Generate UI component code
#' @param settings Extracted UI settings
#' @return String containing UI component code
#' @export
generate_ui_component_code <- function(settings) {
  # CSS Styles
  css_styles <- generate_css_styles(settings)

  sprintf('
# UI Component
gptAssistantUI <- function(id) {
  ns <- NS(id)

  div(
    class = "chat-interface",
    useShinyjs(),

    # CSS Styles
    tags$head(
      tags$style(HTML("%s"))
    ),

    # Main Panel
    div(
      class = "panel panel-default",

      # Header
      div(class = "panel-heading",
          h4(class = "panel-title", "%s")
      ),

      # Chat Container
      div(
        class = "panel-body chat-container",
        uiOutput(ns("messages"))
      ),

      # Input Area
      div(
        class = "panel-footer",
        style = "padding: 15px;",
        textAreaInput(
          ns("message"),
          label = NULL,
          rows = %d,
          placeholder = "Type your message here..."
        ),
        div(
          style = "margin-top: 10px;",
          actionButton(ns("send"), "%s", class = "btn btn-primary"),
          actionButton(ns("new_chat"), "%s", class = "btn btn-default")
        )
      )
    )
  )
}',
          css_styles,
          settings$basic$chat_title,
          settings$basic$input_rows,
          settings$basic$send_button_text,
          settings$basic$new_chat_text
  )
}

#' Generate message rendering code
#' @param settings Extracted UI settings
#' @return String containing message rendering code
#' @export
generate_message_renderer_code <- function(settings) {
  # Create the timestamp formatting code block
  timestamp_code <- if(settings$timestamps$format != "none") {
    sprintf('format_timestamp <- function(timestamp) {
      format(timestamp, "%s")
    }',
            switch(settings$timestamps$format,
                   "HH:mm" = "%%H:%%M",
                   "HH:mm:ss" = "%%H:%%M:%%S",
                   "dd-MM" = "%%d-%%m",
                   "dd-MM-yyyy" = "%%d-%%m-%%Y",
                   "dd-MM-yy" = "%%d-%%m-%%y",
                   "day_time" = "%%A %%H:%%M",
                   "date_time" = "%%d-%%m %%H:%%M",
                   "full_date_time" = "%%A %%d %%B %%H:%%M",
                   "complete" = "%%A %%d %%B %%Y %%H:%%M:%%S",
                   NULL)
    )
  } else {
    "format_timestamp <- function(timestamp) NULL"
  }

  # Generate the complete renderer code
  sprintf('
  # Render messages
  output$messages <- renderUI({
    req(rv$messages)

    %s

    tagList(
      lapply(rv$messages, function(msg) {
        is_user <- msg$role == "user"
        timestamp <- format_timestamp(Sys.time())

        message_div <- div(
          class = if(is_user) "user-message" else "assistant-message",

          # Sender name if enabled
          if(%s) {
            div(
              class = "message-sender",
              if(is_user) "%s" else "%s"
            )
          },

          # Timestamp based on position
          if(!is.null(timestamp) && "%s" == "top") {
            div(class = "message-timestamp", timestamp)
          },

          # Message content with potential inline timestamp
          if("%s" %%in%% c("inside_right", "inside_left")) {
            div(
              style = "display: flex; align-items: center; justify-content: space-between;",
              if("%s" == "inside_left") {
                list(
                  if(!is.null(timestamp)) div(class = "message-timestamp", timestamp),
                  msg$content
                )
              } else {
                list(
                  msg$content,
                  if(!is.null(timestamp)) div(class = "message-timestamp", timestamp)
                )
              }
            )
          } else {
            msg$content
          },

          # Bottom timestamp
          if(!is.null(timestamp) && "%s" == "bottom") {
            div(class = "message-timestamp", timestamp)
          }
        )

        message_div
      })
    )
  })',
          timestamp_code,
          settings$basic$show_names,
          settings$basic$user_name,
          settings$basic$assistant_name,
          settings$timestamps$position,
          settings$timestamps$position,
          settings$timestamps$position,
          settings$timestamps$position
  )
}

#' Extract all settings and generate complete implementation code
#' @param input Shiny input object
#' @return List of code components
#' @export
extract_and_generate_code <- function(input) {
  # Extract all settings
  settings <- extract_ui_settings(input)

  # Generate individual components
  ui_code <- generate_ui_component_code(settings)
  server_code <- generate_message_renderer_code(settings)

  # Return all components
  list(
    settings = settings,
    ui_code = ui_code,
    server_code = server_code
  )
}

#' Utility function for null coalescing
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x
