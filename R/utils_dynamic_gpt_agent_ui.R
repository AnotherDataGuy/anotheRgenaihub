#' Generate Chat Interface UI based on assistant type
#' @param ns Namespace function
#' @param assistant_data Assistant data including name and configuration
#' @return A tagList containing the chat interface UI elements
generate_chat_interface <- function(ns, assistant_data) {
  # Extract assistant type from name
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
#'
#' @noRd
#'
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
                                      choices = c(
                                        "None" = "none",
                                        "Time (24h) - 13:45" = "HH:mm",
                                        "Time with seconds - 13:45:30" = "HH:mm:ss",
                                        "Date (Short) - 04-01" = "dd-MM",
                                        "Date (Full) - 04-01-2025" = "dd-MM-yyyy",
                                        "Date (Short Year) - 04-01-25" = "dd-MM-yy",
                                        "Date (Day) - Monday 4th January" = "day_date",
                                        "Date (Full Day) - Monday 4th January 2025" = "full_day_date"
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

#' Format Timestamps with Various Output Styles
#'
#' @description
#' Formats a timestamp into different string representations based on the specified format option.
#' Supports various date-time formats including custom ordinal date formatting.
#' If the input timestamp is not in POSIXct format, it will be automatically converted.
#'
#' @param timestamp A date-time object that can be converted to POSIXct
#' @param format A character string specifying the output format. Valid options are:
#'   \itemize{
#'     \item "none" - Returns NULL
#'     \item "HH:mm" - Hours and minutes (24-hour format)
#'     \item "HH:mm:ss" - Hours, minutes and seconds
#'     \item "dd-MM" - Day and month
#'     \item "dd-MM-yyyy" - Day, month and full year
#'     \item "dd-MM-yy" - Day, month and 2-digit year
#'     \item "day_time" - Day name and time
#'     \item "date_time" - Day-month and time
#'     \item "full_date_time" - Full date with ordinal suffix and time
#'     \item "complete" - Complete date-time with ordinal suffix
#'   }
#'
#' @return A character string containing the formatted date-time value.
#'   Returns NULL if format is "none" or if an invalid format is provided.
#'
#' @examples
#' ts <- as.POSIXct("2024-01-07 14:30:00")
#' format_timestamp(ts, "HH:mm")  # Returns "14:30"
#' format_timestamp(ts, "complete")  # Returns "Monday 7th January 2024 14:30:00"
#' format_timestamp("2024-01-07 14:30:00", "dd-MM-yyyy")  # Returns "07-01-2024"
#'
#' @export
format_timestamp <- function(timestamp, format) {
  if (format == "none") return(NULL)

  # Convert timestamp to POSIXct if it isn't already
  if (!inherits(timestamp, "POSIXct")) {
    timestamp <- as.POSIXct(timestamp)
  }

  # Helper function for ordinal suffixes
  add_ordinal_suffix <- function(day) {
    suffix <- switch(
      as.character(day),
      "1" = "st", "21" = "st", "31" = "st",
      "2" = "nd", "22" = "nd",
      "3" = "rd", "23" = "rd",
      "th"
    )
    paste0(day, suffix)
  }

  # Format based on selection
  formatted <- switch(format,
                      "HH:mm" = format(timestamp, "%H:%M"),
                      "HH:mm:ss" = format(timestamp, "%H:%M:%S"),
                      "dd-MM" = format(timestamp, "%d-%m"),
                      "dd-MM-yyyy" = format(timestamp, "%d-%m-%Y"),
                      "dd-MM-yy" = format(timestamp, "%d-%m-%y"),
                      "day_time" = format(timestamp, "%A %H:%M"),
                      "date_time" = format(timestamp, "%d-%m %H:%M"),
                      "full_date_time" = {
                        sprintf("%s %s %s %s",
                                format(timestamp, "%A"),
                                add_ordinal_suffix(as.numeric(format(timestamp, "%d"))),
                                format(timestamp, "%B"),
                                format(timestamp, "%H:%M"))
                      },
                      "complete" = {
                        day <- format(timestamp, "%A")
                        date <- add_ordinal_suffix(as.numeric(format(timestamp, "%d")))
                        month <- format(timestamp, "%B")
                        year <- format(timestamp, "%Y")
                        time <- format(timestamp, "%H:%M:%S")
                        paste(day, date, month, year, time)
                      },
                      NULL
  )

  return(formatted)
}
