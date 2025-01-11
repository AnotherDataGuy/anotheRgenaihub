#' assistant_builder_gpt_hub UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyjs useShinyjs
mod_assistant_builder_gpt_hub_ui <- function(id) {
  ns <- NS(id)

  tagList(
    shinyjs::useShinyjs(),

    tags$head(
      tags$style(HTML("
    /* Light mode styles for DataTable */
    .dataTables_wrapper .dataTables_paginate .paginate_button {
      color: #333 !important;
      background-color: #fff !important;
      border-color: #ddd !important;
    }

    .dataTables_wrapper .dataTables_paginate .paginate_button.current {
      color: #fff !important;
      background-color: #007bff !important;
      border-color: #007bff !important;
    }

    .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
      color: #fff !important;
      background-color: #565e64 !important;
      border-color: #565e64 !important;
    }

    .dataTables_wrapper .dataTables_length,
    .dataTables_wrapper .dataTables_filter,
    .dataTables_wrapper .dataTables_info,
    .dataTables_wrapper .dataTables_processing,
    .dataTables_wrapper .dataTables_paginate {
      color: #333 !important;
    }

    .dataTables_wrapper .dataTables_paginate .ellipsis {
      color: #333 !important;
    }

    table.dataTable thead th {
      border-bottom: 1px solid #ddd !important;
      color: #333 !important;
    }

    table.dataTable tfoot th {
      border-top: 1px solid #ddd !important;
      color: #333 !important;
    }

    table.dataTable.no-footer {
      border-bottom: 1px solid #ddd !important;
    }

    /* Dark mode styles for DataTable */
    .dark-mode .dataTables_wrapper .dataTables_paginate .paginate_button {
      color: #fff !important;
      background-color: #343a40 !important;
      border-color: #343a40 !important;
    }

    .dark-mode .dataTables_wrapper .dataTables_paginate .paginate_button.current {
      color: #fff !important;
      background-color: #007bff !important;
      border-color: #007bff !important;
    }

    .dark-mode .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
      color: #fff !important;
      background-color: #565e64 !important;
      border-color: #565e64 !important;
    }

    .dark-mode .dataTables_wrapper .dataTables_length,
    .dark-mode .dataTables_wrapper .dataTables_filter,
    .dark-mode .dataTables_wrapper .dataTables_info,
    .dark-mode .dataTables_wrapper .dataTables_processing,
    .dark-mode .dataTables_wrapper .dataTables_paginate {
      color: #fff !important;
    }

    .dark-mode .dataTables_wrapper .dataTables_paginate .ellipsis {
      color: #fff !important;
    }

    .dark-mode table.dataTable thead th {
      border-bottom: 1px solid #454d55 !important;
      color: #fff !important;
    }

    .dark-mode table.dataTable tfoot th {
      border-top: 1px solid #454d55 !important;
      color: #fff !important;
    }

    .dark-mode table.dataTable.no-footer {
      border-bottom: 1px solid #454d55 !important;
    }
  "))
    ),

    tags$head(
      tags$style(HTML("
    /* Table Styling */
    .assistants-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 20px;
    }

    .assistants-table th {
      padding: 12px;
      border: 1px solid #ddd;
      font-weight: bold;
    }

    .assistants-table td {
      padding: 8px;
      border: 1px solid #ddd;
    }

    /* Progress Bar Styling */
    .progress-bar-container {
      border-radius: 4px;
      height: 20px;
      width: 100%;
      overflow: hidden;
    }

    .progress-bar-temperature {
      background-color: #f44336;
      height: 100%;
      transition: width 0.3s ease;
    }

    .progress-bar-top_p {
      background-color: #4caf50;
      height: 100%;
      transition: width 0.3s ease;
    }

    /* Button Styling */
    .action-btn {
      padding: 4px 8px;
      margin: 0 2px;
      border-radius: 4px;
      border: none;
      cursor: pointer;
      font-size: 12px;
    }

    .edit-btn {
      background-color: #4CAF50;
      color: white;
    }

    .delete-btn {
      background-color: #f44336;
      color: white;
    }
  ")),
      tags$link(
        rel = "stylesheet",
        href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css"
      )
    ),


    # Custom CSS for code sections and layout
    tags$head(
      tags$style(HTML("
        .code-section {
          margin-bottom: 20px;
        }
        .code-block {
          position: relative;
          padding: 15px;
          border-radius: 4px;
          margin-top: 5px;
        }
        .code-block .btn {
          position: absolute;
          top: 10px;
          right: 10px;
          z-index: 100;
        }
        .code-block pre {
          margin-top: 30px;
          white-space: pre-wrap;
          max-height: 300px;
          overflow-y: auto;
        }
        .chat-preview {
          border: 1px solid #ddd;
          border-radius: 4px;
          padding: 15px;
          margin-top: 15px;
        }
        .panel-heading .btn-group {
          margin-left: 10px;
        }
      "))
    ),
    tags$head(
      tags$style(HTML("
    .nav-pills {
      border-bottom: 1px solid #dee2e6;
      padding: 0.5rem 1rem;
      margin-bottom: 1rem;
      place-content: space-evenly;
    }

    .nav-pills .nav-link {
      margin-right: 0.5rem;
      border-radius: 4px;
      padding: 0.5rem 1rem;
    }

    .nav-pills .nav-link.active {
      background-color: #007bff;
      color: white;
    }

    .nav-pills .nav-item {
      margin-right: 1rem;
    }
"))
    ),

    div(
      style = "padding: 15px;",

      # API Connection Panel
      div(class = "panel panel-default",
          div(class = "panel-heading",
              h4(class = "panel-title", "API Connection")
          ),
          div(class = "panel-body",
              div(class = "row",
                  div(class = "col-md-8",
                      div(class = "form-group",
                          div(style = "display: flex; gap: 10px; align-items: flex-end;",
                              div(style = "flex-grow: 1;",
                                  tags$label("OpenAI API Key (project api_key)", class = "control-label"),
                                  passwordInput(ns("connect_api_key"),
                                                label = NULL,
                                                placeholder = "sk-...",
                                                width = "100%")
                              ),
                              actionButton(ns("connect_api"),
                                           "Connect",
                                           icon = icon("plug"),
                                           class = "btn btn-primary")
                          )
                      )
                  ),
                  div(class = "col-md-4",
                      uiOutput(ns("connection_status"))
                  )
              )
          )
      ),

      # Assistant Management Panel
      div(class = "panel panel-default",
          div(class = "panel-heading d-flex justify-content-between align-items-center",
              h4(class = "panel-title m-0", "Assistant Management"),
              div(
                actionButton(ns("new_assistant"),
                             class = "btn btn-success",
                             # icon("plus"),
                             "New Assistant")
              )
          ),
          div(class = "panel-body",
              # Search box and table
              div(
                # class = paste("panel-body", if (input$chat_theme == "dark") "dark-mode"),
                DTOutput(ns("assistants_table"))
              )
          )
      ),

      tabsetPanel(
        id = ns("main_tabs"),
        type = "pills",
        selected = "configuration",

        # Configuration Tab
        tabPanel(
          tags$span(icon("cog"), "Configuration"),
          # value = "configuration",
          # title = tags$span(icon("cog"), "Configuration"),
          div(class = "tab-content p-3",
              div(class = "row",
                  div(class = "col-md-4",
                      generate_chat_customization_ui(ns)
                  ),
                  div(class = "col-md-8",
                      uiOutput(ns("chat_interface_preview"))
                  )
              )
          )
        ),

        # Implementation Tab
        tabPanel(
          tags$span(icon("code"), "Implementation"),
          # value = "implementation",
          # title = tags$span(icon("code"), "Implementation"),
          div(class = "tab-content p-3",
              div(class = "row",
                  div(class = "col-md-12",
                      div(class = "card shadow-sm",
                          div(class = "card-header bg-light",
                              h4(class = "card-title mb-0", "Implementation Code"),
                              p(class = "text-muted small mt-1 mb-0",
                                "Copy and paste these code snippets to implement the assistant in your own Shiny app.")
                          ),
                          div(class = "card-body",
                              # Package Requirements Section
                              div(class = "code-section",
                                  div(class = "d-flex justify-content-between align-items-center mb-2",
                                      h5("Required Packages", class = "mb-0"),
                                      actionButton(ns("copy_packages"), "Copy",
                                                   class = "btn btn-sm btn-outline-secondary")
                                  ),
                                  div(class = "bg-light p-3 rounded",
                                      verbatimTextOutput(ns("packages_code"))
                                  )
                              ),
                              hr(),

                              # Configuration Section
                              div(class = "code-section",
                                  div(class = "d-flex justify-content-between align-items-center mb-2",
                                      h5("Configuration Setup", class = "mb-0"),
                                      actionButton(ns("copy_config"), "Copy",
                                                   class = "btn btn-sm btn-outline-secondary")
                                  ),
                                  div(class = "bg-light p-3 rounded",
                                      verbatimTextOutput(ns("config_code"))
                                  )
                              ),
                              hr(),

                              # UI Component Section
                              div(class = "code-section",
                                  div(class = "d-flex justify-content-between align-items-center mb-2",
                                      h5("UI Component", class = "mb-0"),
                                      actionButton(ns("copy_ui"), "Copy",
                                                   class = "btn btn-sm btn-outline-secondary")
                                  ),
                                  div(class = "bg-light p-3 rounded",
                                      verbatimTextOutput(ns("ui_code"))
                                  )
                              ),
                              hr(),

                              # Server Component Section
                              div(class = "code-section",
                                  div(class = "d-flex justify-content-between align-items-center mb-2",
                                      h5("Server Component", class = "mb-0"),
                                      actionButton(ns("copy_server"), "Copy",
                                                   class = "btn btn-sm btn-outline-secondary")
                                  ),
                                  div(class = "bg-light p-3 rounded",
                                      verbatimTextOutput(ns("server_code"))
                                  )
                              ),
                              hr(),

                              # Complete App Example Section
                              div(class = "code-section",
                                  div(class = "d-flex justify-content-between align-items-center mb-2",
                                      h5("Complete App Example", class = "mb-0"),
                                      actionButton(ns("copy_app"), "Copy",
                                                   class = "btn btn-sm btn-outline-secondary")
                                  ),
                                  div(class = "bg-light p-3 rounded",
                                      verbatimTextOutput(ns("app_code"))
                                  )
                              ),

                              # Implementation Notes
                              div(class = "alert alert-info mt-4",
                                  tags$span(icon("info-circle"),
                                            "Remember to set your OpenAI API key in your app's .Renviron file"),
                                  tags$br(),
                                  tags$code("OPENAI_API_KEY=sk-your-api-key")
                              )
                          )
                      )
                  )
              )
          )
        )
      ),

      # Debug Panel
      div(class = "row",
          div(class = "col-md-12",
              div(class = "panel panel-default",
                  div(class = "panel-heading",
                      div(style = "display: flex; justify-content: space-between; align-items: center;",
                          h4(class = "panel-title", "Debug Log"),
                          actionButton(ns("clear_log"),
                                       "Clear Log",
                                       icon = icon("eraser"),
                                       class = "btn btn-warning btn-sm")
                      )
                  ),
                  div(class = "panel-body",
                      style = "height: 200px; overflow-y: auto;",
                      verbatimTextOutput(ns("debug_log"))
                  )
              )
          )
      )
    )
  )
}

#' assistant_builder_gpt_hub Server Functions
#'
#' @importFrom DT datatable DTOutput JS renderDT
#' @importFrom jsonlite fromJSON
#' @importFrom httr add_headers GET http_error POST
#' @noRd
mod_assistant_builder_gpt_hub_server <- function(id, config=NULL){
  moduleServer(id, function(input, output, session) {
    # Initialize reactive values
    rv <- reactiveValues(
      config = NULL,
      assistants = NULL,
      debug_logs = character(),
      current_thread_id = NULL,
      current_messages = list(),
      is_connected = FALSE,
      selected_assistant_id = NULL,  # Add this to track selected assistant
      ui_settings = list(
        theme = "light",
        height = 400,
        input_rows = 3,
        send_text = "Send",
        new_chat_text = "New Chat",
        title = "Chat Interface",
        show_names = TRUE,
        user_name = "User",
        assistant_name = "Assistant"
      ),
      implementation_code = list(  # Add this section
        packages = "",
        config = "",
        ui = "",
        server = "",
        app = ""
      )
    )

    observe({
      rv$ui_settings <- list(
        theme = input$chat_theme %||% "light",
        height = input$chat_height %||% 400,
        input_rows = input$input_rows %||% 3,
        send_text = input$send_button_text %||% "Send",
        new_chat_text = input$new_chat_text %||% "New Chat",
        title = input$chat_title %||% "Chat Interface"
      )
    })

    # Disable buttons initially
    observe({
      ns <- session$ns  # Get the namespace function
      shinyjs::toggleState(ns("new_assistant"), rv$is_connected)
      shinyjs::toggleState(ns("edit_assistant"), rv$is_connected && !is.null(rv$selected_assistant_id))
      shinyjs::toggleState(ns("delete_assistant"), rv$is_connected && !is.null(rv$selected_assistant_id))
      shinyjs::toggleState(ns("send_message"), rv$is_connected && !is.null(rv$selected_assistant_id))
      shinyjs::toggleState(ns("new_thread"), rv$is_connected && !is.null(rv$selected_assistant_id))
    })

    theme_class <- reactive({
      if (input$chat_theme == "dark") {
        "dark-mode"
      } else {
        ""
      }
    })




    implementation_settings <- reactive({
      req(rv$config, input$selected_assistant)
      list(
        # Existing settings
        model = rv$config$model,
        system_prompt = rv$config$system_prompt,
        assistant_id = input$selected_assistant,
        chat_theme = input$chat_theme %||% "light",
        chat_height = input$chat_height %||% 400,
        color_scheme = input$color_scheme %||% "theme1",
        chat_background = input$chat_background %||% "#FFFFFF",
        timestamp_format = input$timestamp_format %||% "none",
        timestamp_position = input$timestamp_position %||% "top",
        input_rows = input$input_rows %||% 3,
        send_button_text = input$send_button_text %||% "Send",
        # Add new settings
        show_names = input$show_names %||% TRUE,
        user_name = input$user_name %||% "User",
        assistant_name = input$assistant_name %||% "Assistant"
      )
    })





    observeEvent(input$action_click, {
      req(input$action_click)
      action <- input$action_click$type
      row <- input$action_click$row

      if (action == "edit") {
        showModal(
          modalDialog(
            title = sprintf("Edit Assistant: %s", rv$assistants[row, "name"]),
            textInput(session$ns("edit_name"), "Name", value = rv$assistants[row, "name"]),
            selectInput(session$ns("edit_model"), "Model",
                        choices = c("gpt-4o-mini" = "gpt-4o-mini", "gpt-4o" = "gpt-4o"),
                        selected = rv$assistants[row, "model"] %||% "gpt-4o-mini"),
            sliderInput(session$ns("edit_temperature"), "Temperature",
                        min = 0, max = 1, value = rv$assistants[row, "temperature"] %||% 0.7, step = 0.1),
            sliderInput(session$ns("edit_top_p"), "Top P",
                        min = 0, max = 1, value = rv$assistants[row, "top_p"] %||% 1, step = 0.1),
            textAreaInput(session$ns("edit_instructions"), "Instructions",
                          value = rv$assistants[row, "instructions"]),
            footer = tagList(
              modalButton("Cancel"),
              actionButton(session$ns("save_edit"), "Save", class = "btn-primary")
            ),
            easyClose = TRUE
          )
        )
      } else if (action == "delete") {
        # Delete modal code remains the same
        showModal(
          modalDialog(
            title = sprintf("Delete Assistant: %s", rv$assistants[row, "name"]),
            "Are you sure you want to delete this assistant?",
            footer = tagList(
              modalButton("Cancel"),
              actionButton(session$ns("confirm_delete"), "Delete", class = "btn-danger")
            ),
            easyClose = TRUE
          )
        )
      }
    })




    observeEvent(input$save_edit, {
      req(input$edit_name, input$edit_model, input$edit_instructions, rv$config)

      tryCatch({
        row <- input$action_click$row
        assistant_id <- rv$assistants$id[row]

        body <- list(
          name = input$edit_name,
          model = input$edit_model,
          instructions = input$edit_instructions,
          temperature = input$edit_temperature,
          top_p = input$edit_top_p
        )

        response <- httr::POST(
          url = sprintf("https://api.openai.com/v1/assistants/%s", assistant_id),
          httr::add_headers(
            Authorization = paste("Bearer", rv$config$api_key),
            "Content-Type" = "application/json",
            "OpenAI-Beta" = "assistants=v2"
          ),
          body = jsonlite::toJSON(body, auto_unbox = TRUE),
          encode = "raw"
        )

        if (httr::http_error(response)) {
          content <- jsonlite::fromJSON(rawToChar(response$content))
          stop(content$error$message)
        }

        # Refresh the assistants list
        refresh_response <- httr::GET(
          url = "https://api.openai.com/v1/assistants?limit=100",
          httr::add_headers(
            Authorization = paste("Bearer", rv$config$api_key),
            "OpenAI-Beta" = "assistants=v2"
          )
        )

        if (!httr::http_error(refresh_response)) {
          content <- jsonlite::fromJSON(rawToChar(refresh_response$content))
          rv$assistants <- content$data
        }

        removeModal()
        showNotification("Assistant updated successfully", type = "message")

      }, error = function(e) {
        showNotification(sprintf("Failed to update assistant: %s", e$message), type = "error")
      })
    })







    output$chat_interface_preview <- renderUI({
      ns <- session$ns
      settings <- rv$ui_settings

      color_schemes <- list(
        theme1 = list(user = "#E3E9E5", assistant = "#1B2B44"),
        theme2 = list(user = "#F5EFE6", assistant = "#2C4A3E"),
        theme3 = list(user = "#E6EFF6", assistant = "#382B44"),
        theme4 = list(user = "#FFF8E7", assistant = "#1B4448"),
        theme5 = list(user = "#F0E9F5", assistant = "#3A2A24"),
        theme6 = list(user = "#F9F6F2", assistant = "#2B3844"),
        theme7 = list(user = "#F9F0F2", assistant = "#223A2C"),
        theme8 = list(user = "#F0F2F5", assistant = "#442B35")
      )

      selected_colors <- color_schemes[[input$color_scheme %||% "theme1"]]
      bg_color <- input$chat_background  # Use the actual color value

      div(
        class = paste("panel panel-default", if(settings$theme == "dark") "bg-dark text-white"),
        style = paste0(
          "margin-top: 20px; border: 1px solid #ddd; border-radius: 4px; ",
          sprintf("background-color: %s;", bg_color)  # Apply background color directly
        ),

        # Chat title
        div(class = "panel-heading",
            h4(class = "panel-title", settings$title)
        ),

        # Chat history area with dynamic height
        div(class = "panel-body",
            style = sprintf("height: %dpx; overflow-y: auto; padding: 15px; background-color: %s;",
                            input$chat_height %||% 400,
                            bg_color),  # Use background color here too
            uiOutput(ns("chat_history"))
        ),

        # Input area
        div(class = "panel-footer",
            style = if(settings$theme == "dark") "background-color: #343a40; border-top: 1px solid #454d55",
            textAreaInput(ns("message_input"), NULL,
                          rows = settings$input_rows,
                          width = "100%"
            ),
            div(style = "margin-top: 10px;",
                actionButton(ns("send_message"), settings$send_text,
                             class = "btn btn-primary"),
                actionButton(ns("new_thread"), settings$new_chat_text,
                             class = "btn btn-default")
            )
        )
      )
    })



    # Handle API connection with validation
    observeEvent(input$connect_api, {
      req(input$connect_api_key)

      shinyjs::disable("connect_api")

      tryCatch({
        rv$config <- init_enhanced_config(
          api_key = input$connect_api_key,
          timeout_seconds = 60
        )

        # Test connection and fetch assistants
        response <- httr::GET(
          url = "https://api.openai.com/v1/assistants?limit=100",
          httr::add_headers(
            Authorization = paste("Bearer", rv$config$api_key),
            "OpenAI-Beta" = "assistants=v2"
          )
        )

        if (httr::http_error(response)) {
          content <- jsonlite::fromJSON(rawToChar(response$content))
          stop(content$error$message)
        }

        content <- jsonlite::fromJSON(rawToChar(response$content))
        rv$assistants <- content$data
        rv$is_connected <- TRUE

        showNotification("Connected successfully", type = "message")

      }, error = function(e) {
        rv$is_connected <- FALSE
        rv$config <- NULL
        showNotification(sprintf("Connection failed: %s", e$message), type = "error")
      }, finally = {
        shinyjs::enable("connect_api")
      })
    })




    # Connection status text
    output$connection_status <- renderUI({
      if (rv$is_connected) {
        # Get the actual count from assistants data
        num_assistants <- if (!is.null(rv$assistants)) nrow(rv$assistants) else 0
        div(
          class = "text-success",
          style= "color: #28a745!important; font-size: larger; text-align-last: center;",
          tags$span(
            icon("check-circle"),
            sprintf("Connected (%d assistants)", num_assistants)
          )
        )
      } else {
        div(
          class = "text-muted",
          tags$span(
            icon("times-circle"),
            "Not connected"
          )
        )
      }
    })


    # Helper function to add debug log
    add_debug_log <- function(message, type = "INFO") {
      timestamp <- format(Sys.time(), "[%Y-%m-%d %H:%M:%S]")
      new_log <- sprintf("%s [%s] %s", timestamp, type, message)
      rv$debug_logs <- c(new_log, rv$debug_logs)[1:min(100, length(rv$debug_logs) + 1)]
    }

    # Show modal for new assistant
    observeEvent(input$new_assistant, {
      add_debug_log("Opening new assistant creation modal", "UI")
      showModal(
        modalDialog(
          title = "Create New Assistant",

          # Assistant Type Selection
          selectInput(session$ns("assistant_type"), "Assistant Type",
                      choices = c(
                        "Chat Assistant" = "chat",
                        "Code Generator" = "code",
                        "GEN-AI Assistant" = "gen-ai"
                      ),
                      selected = "chat"),

          # Name input
          textInput(session$ns("assistant_name"), "Assistant Name",
                    placeholder = "Enter a name for your assistant"),

          # Model Selection
          selectInput(session$ns("model"), "Model",
                      choices = c("gpt-4o-mini" = "gpt-4o-mini"),
                      selected = "gpt-4o-mini"),

          # System prompt
          textAreaInput(session$ns("system_prompt"), "System Instructions",
                        rows = 3,
                        placeholder = "What should this assistant do?"),

          footer = tagList(
            modalButton("Cancel"),
            actionButton(session$ns("submit_assistant"), "Create Assistant",
                         class = "btn-primary")
          ),

          size = "m",
          easyClose = TRUE
        )
      )
    })

    # Handle assistant creation
    observeEvent(input$submit_assistant, {
      req(input$assistant_name, input$model, input$system_prompt, rv$config)

      shinyjs::disable("submit_assistant")

      tryCatch({
        body <- list(
          name = input$assistant_name,
          model = input$model,
          instructions = input$system_prompt
        )

        response <- httr::POST(
          url = "https://api.openai.com/v1/assistants",
          httr::add_headers(
            Authorization = paste("Bearer", rv$config$api_key),
            "Content-Type" = "application/json",
            "OpenAI-Beta" = "assistants=v2"
          ),
          body = jsonlite::toJSON(body, auto_unbox = TRUE),
          encode = "raw"
        )

        if (httr::http_error(response)) {
          content <- jsonlite::fromJSON(rawToChar(response$content))
          stop(content$error$message)
        }

        # Refresh the assistants list
        refresh_response <- httr::GET(
          url = "https://api.openai.com/v1/assistants?limit=100",
          httr::add_headers(
            Authorization = paste("Bearer", rv$config$api_key),
            "OpenAI-Beta" = "assistants=v2"
          )
        )

        if (!httr::http_error(refresh_response)) {
          content <- jsonlite::fromJSON(rawToChar(refresh_response$content))
          rv$assistants <- content$data
        }

        removeModal()
        showNotification("Assistant created successfully", type = "message")

      }, error = function(e) {
        showNotification(sprintf("Failed to create assistant: %s", e$message), type = "error")
      }, finally = {
        shinyjs::enable("submit_assistant")
      })
    })

    observeEvent(input$confirm_delete, {
      req(rv$config)

      tryCatch({
        row <- input$action_click$row
        assistant_id <- rv$assistants$id[row]

        response <- httr::DELETE(
          url = sprintf("https://api.openai.com/v1/assistants/%s", assistant_id),
          httr::add_headers(
            Authorization = paste("Bearer", rv$config$api_key),
            "OpenAI-Beta" = "assistants=v2"
          )
        )

        if (httr::http_error(response)) {
          content <- jsonlite::fromJSON(rawToChar(response$content))
          stop(content$error$message)
        }

        # Refresh the assistants list
        refresh_response <- httr::GET(
          url = "https://api.openai.com/v1/assistants?limit=100",
          httr::add_headers(
            Authorization = paste("Bearer", rv$config$api_key),
            "OpenAI-Beta" = "assistants=v2"
          )
        )

        if (!httr::http_error(refresh_response)) {
          content <- jsonlite::fromJSON(rawToChar(refresh_response$content))
          rv$assistants <- content$data
        }

        removeModal()
        showNotification("Assistant deleted successfully", type = "message")

      }, error = function(e) {
        showNotification(sprintf("Failed to delete assistant: %s", e$message), type = "error")
      })
    })



    # Handle new thread creation
    observeEvent(input$new_thread, {
      req(rv$config)
      add_debug_log("Creating new thread...", "PROCESS")

      tryCatch({
        thread_id <- init_thread(rv$config)
        rv$current_thread_id <- thread_id
        rv$current_messages <- list()
        add_debug_log(sprintf("New thread created: %s", thread_id), "SUCCESS")
        showNotification("New thread created", type = "message")
      }, error = function(e) {
        add_debug_log(sprintf("Error creating thread: %s", e$message), "ERROR")
        showNotification(sprintf("Error: %s", e$message), type = "error")
      })
    })



    # Handle sending messages
    observeEvent(input$send_message, {
      req(input$message_input, rv$selected_assistant_id, rv$config, rv$current_thread_id)

      add_debug_log(sprintf("Sending message with assistant ID: %s", rv$selected_assistant_id))
      shinyjs::disable("send_message")

      tryCatch({
        # Set assistant ID in config
        rv$config$assistant_id <- rv$selected_assistant_id

        # Store message
        message_text <- input$message_input
        updateTextAreaInput(session, "message_input", value = "")

        # Update UI immediately with user message
        rv$current_messages <- c(
          rv$current_messages,
          list(list(role = "user", content = message_text))
        )

        # Send message and run assistant
        send_message(rv$config, rv$current_thread_id, message_text)
        run_id <- execute_assistant(rv$config, rv$current_thread_id)

        # Monitor status
        status <- "queued"
        attempts <- 0
        while(status %in% c("queued", "in_progress") && attempts < 30) {
          Sys.sleep(1)
          status <- monitor_run_status(rv$config, rv$current_thread_id, run_id)
          attempts <- attempts + 1
          add_debug_log(sprintf("Run status: %s (attempt %d)", status, attempts))
        }

        if(status == "completed") {
          response <- fetch_response(rv$config, rv$current_thread_id)
          if(!is.null(response)) {
            rv$current_messages <- c(
              rv$current_messages,
              list(list(role = "assistant", content = response))
            )
          }
        } else {
          showNotification("Response timed out or failed", type = "warning")
        }
      }, error = function(e) {
        showNotification(sprintf("Error: %s", e$message), type = "error")
        add_debug_log(sprintf("Message error: %s", e$message), "ERROR")
      }, finally = {
        shinyjs::enable("send_message")
      })
    })


    observeEvent(input$clear_log, {
      rv$debug_logs <- character()
      add_debug_log("Debug log cleared", "SYSTEM")
    })

    # Render debug log
    output$debug_log <- renderPrint({
      cat(paste(rv$debug_logs, collapse = "\n"))
    })


    # Render chat history
    # In mod_assistant_builder_gpt_hub.R, update the output$chat_history renderer:

    output$chat_history <- renderUI({
      color_schemes <- list(
        theme1 = list(user = "#E3E9E5", assistant = "#1B2B44"),
        theme2 = list(user = "#F5EFE6", assistant = "#2C4A3E"),
        theme3 = list(user = "#E6EFF6", assistant = "#382B44"),
        theme4 = list(user = "#FFF8E7", assistant = "#1B4448"),
        theme5 = list(user = "#F0E9F5", assistant = "#3A2A24"),
        theme6 = list(user = "#F9F6F2", assistant = "#2B3844"),
        theme7 = list(user = "#F9F0F2", assistant = "#223A2C"),
        theme8 = list(user = "#F0F2F5", assistant = "#442B35")
      )

      selected_colors <- color_schemes[[input$color_scheme %||% "theme1"]]

      if (length(rv$current_messages) > 0) {
        tagList(
          lapply(rv$current_messages, function(msg) {
            is_user <- msg$role == "user"
            timestamp <- format_timestamp(Sys.time(), input$timestamp_format)

            # Create timestamp element if needed
            timestamp_elem <- if (!is.null(timestamp)) {
              div(
                class = "message-timestamp",
                style = paste(
                  "font-size: 0.8em;",
                  "opacity: 0.7;",
                  if(input$timestamp_position %in% c("inside_right", "inside_left")) {
                    "display: inline-block; margin-left: 8px;"
                  } else {
                    "margin-bottom: 4px;"
                  }
                ),
                timestamp
              )
            }

            # Create participant name element if enabled
            name_elem <- if (input$show_names) {
              div(
                class = "message-sender",
                style = "font-weight: bold; margin-bottom: 5px;",
                if(is_user) input$user_name %||% "User" else input$assistant_name %||% "Assistant"
              )
            }

            # Create message content with potential inline timestamp
            message_content <- if(input$timestamp_position %in% c("inside_right", "inside_left")) {
              div(
                style = "display: flex; align-items: center; justify-content: space-between;",
                if(input$timestamp_position == "inside_left") list(timestamp_elem, msg$content) else list(msg$content, timestamp_elem)
              )
            } else {
              msg$content
            }

            # Combine everything into the message container
            div(
              class = if(is_user) "user-message" else "assistant-message",
              style = paste(
                "padding: 10px;",
                "margin: 5px 0;",
                "border-radius: 8px;",
                sprintf("background-color: %s;",
                        if(is_user) selected_colors$user else selected_colors$assistant),
                sprintf("color: %s;",
                        if(is_user) "#000000" else "#ffffff")
              ),
              if(input$show_names) name_elem,
              if(input$timestamp_position == "top") timestamp_elem,
              message_content,
              if(input$timestamp_position == "bottom") timestamp_elem
            )
          })
        )
      } else {
        div(
          class = "text-center text-muted",
          style = "margin-top: 20px;",
          "No messages yet. Start a new thread to begin chatting."
        )
      }
    })


    implementation_code <- reactive({
      req(rv$selected_assistant_id, rv$config)

      settings <- list(
        assistant_id = rv$selected_assistant_id,
        model = rv$config$model,
        chat_theme = input$chat_theme %||% "light",
        chat_height = input$chat_height %||% 400,
        color_scheme = input$color_scheme %||% "theme1",
        chat_background = input$chat_background %||% "#FFFFFF",
        input_rows = input$input_rows %||% 3,
        send_button_text = input$send_button_text %||% "Send",
        title = input$chat_title %||% "Chat Interface"
      )

      generate_implementation_code(settings, input)
    })

    # Render the code sections
    output$packages_code <- renderText({
      req(implementation_code())
      implementation_code()$packages
    })

    output$config_code <- renderText({
      req(implementation_code())
      implementation_code()$global
    })

    output$ui_code <- renderText({
      req(implementation_code())
      implementation_code()$ui
    })

    output$server_code <- renderText({
      req(implementation_code())
      implementation_code()$server
    })

    output$app_code <- renderText({
      req(implementation_code())
      implementation_code()$app
    })

    # Handle copy button clicks
    observeEvent(input$copy_packages, {
      req(implementation_code())
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(implementation_code()$packages)
        showNotification("Package code copied to clipboard!", type = "message")
      }
    })

    observeEvent(input$copy_config, {
      req(implementation_code())
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(implementation_code()$global)
        showNotification("Configuration code copied to clipboard!", type = "message")
      }
    })

    observeEvent(input$copy_ui, {
      req(implementation_code())
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(implementation_code()$ui)
        showNotification("UI code copied to clipboard!", type = "message")
      }
    })

    observeEvent(input$copy_server, {
      req(implementation_code())
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(implementation_code()$server)
        showNotification("Server code copied to clipboard!", type = "message")
      }
    })

    observeEvent(input$copy_app, {
      req(implementation_code())
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(implementation_code()$app)
        showNotification("Complete app code copied to clipboard!", type = "message")
      }
    })



    # Render the datatable with improved debugging
    output$assistants_table <- renderDT({
      req(rv$assistants)
      ns <- session$ns

      # Create display data
      display_data <- data.frame(
        id = rv$assistants$id,
        Name = rv$assistants$name,
        Model = rv$assistants$model,
        Created = format(as.POSIXct(rv$assistants$created_at), "%Y-%m-%d %H:%M"),
        stringsAsFactors = FALSE
      )

      # Add action buttons with proper event handling
      display_data$Actions <- sprintf(
        '<div class="btn-group">
        <button class="btn btn-sm btn-primary" onclick="Shiny.setInputValue(\'%s\', {type:\'edit\',row:%d}, {priority:\'event\'})">
          <i class="fas fa-edit"></i> Edit
        </button>
        <button class="btn btn-sm btn-danger" onclick="Shiny.setInputValue(\'%s\', {type:\'delete\',row:%d}, {priority:\'event\'})">
          <i class="fas fa-trash"></i> Delete
        </button>
      </div>',
        ns("action_click"), seq_len(nrow(display_data)),
        ns("action_click"), seq_len(nrow(display_data))
      )

      DT::datatable(
        display_data,
        escape = FALSE,
        selection = 'single',
        rownames = FALSE,
        options = list(
          dom = 't',
          pageLength = 10,
          scrollY = "400px",
          columnDefs = list(
            list(targets = 0, visible = FALSE),
            list(targets = -1, width = "150px")
          ),
          rowCallback = DT::JS("function(row, data) {
    $(row).css('background-color', '#343a40');
    $(row).css('color', '#fff');
  }"),
          drawCallback = DT::JS("function() {
    $('.paginate_button').css('background-color', '#343a40');
    $('.paginate_button').css('border-color', '#343a40');
    $('.paginate_button').css('color', '#fff');
    $('.paginate_button.current').css('background-color', '#007bff');
    $('.paginate_button.current').css('border-color', '#007bff');
  }")
        ),
        class = "table table-striped table-bordered"
      )
    })

    # Handle table row selection
    observeEvent(input$assistants_table_rows_selected, {
      req(input$assistants_table_rows_selected, rv$assistants)

      # Debug: Log selection event
      add_debug_log("Assistant selection triggered")

      selected_row <- input$assistants_table_rows_selected
      add_debug_log(sprintf("Selected row index: %s", selected_row))

      # Debug: Log assistant data
      add_debug_log(sprintf("Assistant name: %s", rv$assistants$name[selected_row]))
      add_debug_log(sprintf("Assistant ID: %s", rv$assistants$id[selected_row]))

      rv$selected_assistant_id <- rv$assistants$id[selected_row]
      add_debug_log(sprintf("Updated rv$selected_assistant_id to: %s", rv$selected_assistant_id))

      # Create new thread when selecting assistant
      tryCatch({
        rv$current_thread_id <- init_thread(rv$config)
        rv$current_messages <- list()
        showNotification(
          sprintf("Selected assistant: %s", rv$assistants$name[selected_row]),
          type = "message"
        )
      }, error = function(e) {
        showNotification(sprintf("Error creating thread: %s", e$message), type = "error")
      })
    })















  })
}

## To be copied in the UI
# mod_assistant_builder_gpt_hub_ui("assistant_builder_gpt_hub_1")

## To be copied in the server
# mod_assistant_builder_gpt_hub_server("assistant_builder_gpt_hub_1")
