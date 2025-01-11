#' Generate Chat Interface UI based on assistant type
#' @param ns Namespace function
#'
#' @noRd
#'
#' @param assistant_data Assistant data including name and configuration
#' @return A tagList containing the chat interface UI elements
generate_chat_interface <- function(ns, assistant_data) {
  # Extract assistant type from name
  messages <- reactiveVal(list())

  assistant_type <- if (grepl("Code", assistant_data$name, ignore.case = TRUE)) {
    "code"
  } else if (grepl("GEN-AI", assistant_data$name, ignore.case = TRUE)) {
    "gen-ai"
  } else {
    "chat"
  }

  # Base UI elements that are common across all types
  base_ui <- list(
    div(
      class = "well",
      h4(paste0("Chat with ", assistant_data$name))
    )
  )

  # Additional UI elements based on assistant type
  type_specific_ui <- switch(
    assistant_type,
    "code" = list(
      # Code assistant specific elements
      div(
        style = "margin-bottom: 15px;",
        tags$label("Code Input:", class = "control-label"),
        textAreaInput(ns("message_input"), label = NULL, rows = 6,
                      resize = "vertical", width = "100%"),
        tags$div(
          style = "margin-top: 10px;",
          verbatimTextOutput(ns("code_output"))
        )
      ),
      div(
        style = "margin-bottom: 20px;",
        actionButton(ns("send_message"), "Run Code",
                     icon = icon("code"),
                     class = "btn btn-primary"),
        actionButton(ns("new_thread"), "New Session",
                     icon = icon("refresh"),
                     class = "btn btn-default")
      )
    ),
    "gen-ai" = list(
      # GEN-AI assistant specific elements
      div(
        style = "margin-bottom: 15px;",
        tags$label("Generation Prompt:", class = "control-label"),
        textAreaInput(ns("message_input"), label = NULL, rows = 4,
                      placeholder = "Enter your generation prompt here...",
                      width = "100%")
      ),
      div(
        style = "margin-bottom: 15px;",
        sliderInput(ns("temperature"), "Creativity Level:",
                    min = 0, max = 1, value = 0.7, step = 0.1)
      ),
      div(
        style = "margin-bottom: 20px;",
        actionButton(ns("send_message"), "Generate",
                     icon = icon("magic"),
                     class = "btn btn-primary"),
        actionButton(ns("new_thread"), "New Generation",
                     icon = icon("refresh"),
                     class = "btn btn-default")
      )
    ),
    # Default chat interface
    list(
      div(
        style = "margin-bottom: 15px;",
        tags$label("Your message:", class = "control-label"),
        textAreaInput(ns("message_input"), label = NULL, rows = 3,
                      width = "100%")
      ),
      div(
        style = "margin-bottom: 20px;",
        actionButton(ns("send_message"), "Send",
                     icon = icon("paper-plane"),
                     class = "btn btn-primary"),
        actionButton(ns("new_thread"), "New Thread",
                     icon = icon("refresh"),
                     class = "btn btn-default")
      )
    )
  )

  # Chat history area (common across all types)
  chat_history <- list(
    div(
      style = "border: 1px solid #ddd; border-radius: 4px; padding: 15px; margin-top: 20px; max-height: 400px; overflow-y: auto;",
      verbatimTextOutput(ns("chat_history"))
    )
  )

  # Combine all UI elements
  do.call(tagList, c(base_ui, type_specific_ui, chat_history))
}





#' Generate chat interface customization UI
#'
#' @param ns Namespace function for the Shiny module
#' @return Shiny UI elements for chat customization
#' @importFrom shiny div tagList tabPanel tabsetPanel column fluidRow
#' @importFrom shiny textInput selectInput numericInput
#' @export
generate_chat_customization_ui <- function(ns) {
  div(
    class = "panel panel-default",
    style = "border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
    div(
      class = "panel-heading",
      style = "border-bottom: 1px solid #dee2e6; padding: 15px;",
      h4(class = "panel-title", style = "margin: 0;", "Chat Interface Customization")
    ),
    div(
      class = "panel-body",
      # Add tabsetPanel for better organization
      tabsetPanel(
        id = ns("customization_tabs"),
        type = "pills",
        # First tab: Basic Settings
        tabPanel("Basic Settings",

                 title = tags$span(icon("cogs"), "Basic settings"),
                 fluidRow(
                   column(6,
                          textInput(ns("chat_title"), "Chat Title", "Chat Interface"),
                          selectInput(ns("chat_theme"), selected="dark", "Theme",
                                      choices = c("Light" = "light", "Dark" = "dark")),
                          numericInput(ns("chat_height"), "Chat Height (px)",
                                       value = 400, min = 200, max = 1000, step = 50)
                   ),
                   column(6,
                          numericInput(ns("input_rows"), "Input Area Rows",
                                       value = 3, min = 1, max = 10),
                          textInput(ns("send_button_text"), "Send Button Text", "Send")
                   ),
                   column(6,
                          checkboxInput(ns("show_names"),
                                        "Show participant names",
                                        value = TRUE),
                          textInput(ns("user_name"),
                                    "Custom user name",
                                    value = "User"),
                          textInput(ns("assistant_name"),
                                    "Custom assistant name",
                                    value = "Assistant")
                   )
                 )
        ),

        # Second tab: Colors
        tabPanel(title = tags$span(icon("paint-brush"), "Colors"),
                 fluidRow(
                   column(6,
                          selectInput(ns("color_scheme"), "Bubble Color Scheme",
                                      choices = c(
                                        "Professional" = "theme1",
                                        "Natural" = "theme2",
                                        "Modern" = "theme3",
                                        "Warm" = "theme4",
                                        "Soft" = "theme5",
                                        "Clean" = "theme6",
                                        "Gentle" = "theme7",
                                        "Classic" = "theme8"
                                      )),
                          selectInput(ns("chat_background"), "Chat Background Color",
                                      choices = c(
                                        "White" = "#FFFFFF",
                                        "Light Gray" = "#F5F5F5",
                                        "Soft Blue" = "#F0F8FF",
                                        "Warm Beige" = "#FDF5E6",
                                        "Mint" = "#F0FFF0",
                                        "Lavender" = "#F5F0FF",
                                        "Pale Pink" = "#FFF0F5",
                                        "Light Yellow" = "#FFFFE0",
                                        "Light Green" = "#F0FFF0",


                                        "Grey" = "#464f4f",
                                        "Black" = "#000000",
                                        "Dark Grey" = "#2c3e50",
                                        "Dark Blue" = "#2c3e50",
                                        "Dark Green" = "#223A2C",
                                        "Dark Purple" = "#382B44",
                                        "Dark Red" = "#442B35",
                                        "Dark Teal" = "#1B4448"

                                      ),
                                      selected = "#FFFFFF")
                   )
                 )
        ),

        # Third tab: Time & Date Display
        tabPanel(title = tags$span(icon("clock"), "Time & Date Display"),
                 fluidRow(
                   column(12,
                          selectInput(ns("timestamp_format"), "Message Timestamp Format",
                                      choices =  c(
                                        "None" = "none",
                                        "Time (24h) - 13:45" = "HH:mm",
                                        "Time with seconds - 13:45:30" = "HH:mm:ss",
                                        "Date (Short) - 04-01" = "dd-MM",
                                        "Date (Full) - 04-01-2025" = "dd-MM-yyyy",
                                        "Date (Short Year) - 04-01-25" = "dd-MM-yy",
                                        "Day and Time - Monday 13:45" = "day_time",
                                        "Date and Time - 04-01 13:45" = "date_time",
                                        "Full Date and Time - Monday 4th January 13:45" = "full_date_time",
                                        "Complete - Monday 4th January 2025 13:45:30" = "complete"
                                      ),
                                      selected = "none"
                          ),
                          selectInput(ns("timestamp_position"), "Timestamp Position",
                                      choices = c(
                                        "Above message" = "top",
                                        "Below message" = "bottom",
                                        "Inside message (right)" = "inside_right",
                                        "Inside message (left)" = "inside_left"
                                      ),
                                      selected = "top"
                          )
                   )
                 )
        )
      )
    )
  )
}


#' Add a new tab to the UI for implementation
#'
#' @param ns Namespace function
#' @return tabPanel ready to go
#' @export
generate_implementation_tab <- function(ns) {
  tabPanel("Implementation",
           div(
             class = "implementation-section",
             h4("Required Packages"),
             div(
               class = "code-block",
               verbatimTextOutput(ns("packages_code")),
               actionButton(ns("copy_packages"), "Copy",
                            class = "btn btn-sm btn-default")
             ),
             h4("Global Configuration"),
             div(
               class = "code-block",
               verbatimTextOutput(ns("global_code")),
               actionButton(ns("copy_global"), "Copy")
             ),
             h4("UI Component"),
             div(
               class = "code-block",
               verbatimTextOutput(ns("ui_code")),
               actionButton(ns("copy_ui"), "Copy")
             ),
             h4("Server Component"),
             div(
               class = "code-block",
               verbatimTextOutput(ns("server_code")),
               actionButton(ns("copy_server"), "Copy")
             ),
             h4("Example Implementation"),
             div(
               class = "code-block",
               verbatimTextOutput(ns("app_code")),
               actionButton(ns("copy_app"), "Copy")
             )
           )
  )
}



#' Get color scheme for chat bubbles
#'
#' @param theme_name Name of the color theme
#' @return List containing user and assistant colors
#' @export
get_color_scheme <- function(theme_name) {
  # Define color schemes with meaningful names and accessibility-friendly colors
  schemes <- list(
    theme1 = list(  # Professional
      user = "#E3E9E5",      # Sage Green
      assistant = "#1B2B44"   # Deep Navy
    ),
    theme2 = list(  # Natural
      user = "#F5EFE6",      # Light Sand
      assistant = "#2C4A3E"   # Forest Green
    ),
    theme3 = list(  # Modern
      user = "#E6EFF6",      # Soft Blue
      assistant = "#382B44"   # Deep Purple
    ),
    theme4 = list(  # Warm
      user = "#FFF8E7",      # Pale Yellow
      assistant = "#1B4448"   # Dark Teal
    ),
    theme5 = list(  # Soft
      user = "#F0E9F5",      # Light Lavender
      assistant = "#3A2A24"   # Deep Brown
    ),
    theme6 = list(  # Clean
      user = "#F9F6F2",      # Cream
      assistant = "#2B3844"   # Slate Blue
    ),
    theme7 = list(  # Gentle
      user = "#F9F0F2",      # Pale Pink
      assistant = "#223A2C"   # Deep Green
    ),
    theme8 = list(  # Classic
      user = "#F0F2F5",      # Light Gray
      assistant = "#442B35"   # Dark Burgundy
    )
  )

  # Return the requested scheme or default to theme1 if not found
  if (!theme_name %in% names(schemes)) {
    warning("Theme not found, using default Professional theme")
    return(schemes$theme1)
  }

  schemes[[theme_name]]
}

