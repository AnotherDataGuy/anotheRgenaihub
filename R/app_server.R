#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import httr
#' @import shinymanager
#' @import rlang
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom bs4Dash dashboardPage dashboardHeader
#' @importFrom plotly plot_ly layout
#' @noRd
app_server <- function(input, output, session) {

  # Authentication (outside of tryCatch to make res_auth available in the wider scope)
  res_auth <- shinymanager::secure_server(
    check_credentials = shinymanager::check_credentials(
      db = "anothergenaihubusers.sqlite",
      passphrase = Sys.getenv("shinymanagerauth")
    ),
    timeout = 600
  )

  # Error handling for authentication
  # observe({
  #   tryCatch({
  #     print(res_auth$user)  # Print the authenticated user info
  #   }, error = function(e) {
  #     print(paste("Authentication error:", e$message))
  #   })
  # })

  shared_state <- reactiveValues(
    messages = list(),
    thread_id = NULL,
    metrics = list(
      prompt_tokens = numeric(),
      completion_tokens = numeric(),
      total_tokens = numeric(),
      response_times = numeric(),
      timestamps = character()
    )
  )

  observeEvent(res_auth$user, {
    if (!is.null(res_auth$user)) {
      shinyjs::runjs("
            // Show app content first but invisible
            document.querySelector('.app-container').style.display = 'block';
            document.querySelector('.app-container').style.opacity = '0';

            // Wait a bit then fade out loader and fade in content
            setTimeout(function() {
                document.querySelector('.auth-loader').classList.add('hidden');
                document.querySelector('.app-container').style.opacity = '1';
            }, 800);
        ")

      # No automatic guide display here
    }
  })





  # Reactive value to track the current section
  current_tab <- reactiveVal("Assistant Builder")

  # Observe button clicks and update the current tab
  observeEvent(input$btn_assistant_builder, {
    current_tab("Assistant Builder")
  })

  observeEvent(input$btn_chat_agent, {
    current_tab("Admin's Hub assistant")
  })

  # Dynamically load the appropriate module based on the current tab
  output$main_content <- renderUI({
    if (current_tab() == "Admin's Hub assistant") {
      mod_main_local_gpt_agent_ui("main_local_gpt_agent_1")
    } else if (current_tab() == "Assistant Builder") {
      mod_assistant_builder_gpt_hub_ui("assistant_builder_gpt_hub_1")
    }
  })

  # Initialize the modules with shared state
  mod_main_local_gpt_agent_server("main_local_gpt_agent_1",
                                  config = create_config(
                                    api_key = Sys.getenv("API_KEY_FirstStepper"),
                                    assistant_id = Sys.getenv("assistant_id_FirstStepperAssistant")
                                  ),
                                  shared_state = shared_state
  )
  mod_assistant_builder_gpt_hub_server("assistant_builder_gpt_hub_1")
}


