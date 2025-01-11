#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`. DO NOT REMOVE.
#' @import shiny
#' @import bs4Dash
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    tags$style(HTML("
      #nav-buttons {
        position: fixed;
        bottom: 0;
        width: 100%;
        display: flex;
        justify-content: center;
        gap: 1rem;
        padding: 10px;
        background-color: #343a40;
        z-index: 1000;
      }
      .nav-button {
        flex: 1;
        text-align: center;
        padding: 10px;
        font-size: 16px;
        cursor: pointer;
        background-color: #495057;
        color: white;
        border-radius: 5px;
        border: none;
      }
      .nav-button:hover {
        background-color: #6c757d;
      }
    ")),
    bs4Dash::dashboardPage(
      help = NULL,
      title = "anothergenaihub",
      dark = TRUE,
      header = dashboardHeader(
        title = span(
          icon("robot"),
          "anotheRGenAIHub",
          style = "font-size: 1.5rem; font-weight: 500;"
        )
      ),
      sidebar = dashboardSidebar(disable = TRUE),
      controlbar = dashboardControlbar(collapsed = TRUE),
      body = dashboardBody(
        # Main Content Area
        uiOutput("main_content"),
        # Navigation Buttons at the Bottom
        div(
          id = "nav-buttons",
          actionButton("btn_assistant_builder", "Assistant Builder", class = "nav-button"),
          actionButton("btn_chat_agent", "Admin's Hub assistant", class = "nav-button")
        )
      )
    )
  )
}






#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "anothergenaihub"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
