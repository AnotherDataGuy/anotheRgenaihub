#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
    onStart = NULL,
    options = list(),
    enableBookmarking = NULL,
    uiPattern = "/",
    ...
) {
  with_golem_options(
    app = shinyApp(

      ui = shinymanager::secure_app(

        tags_top = tags$div(
          tags$img(
            src =  "https://previews.dropbox.com/p/thumb/ACjmblwv8bZ3TurFMeYhdpXk19CNUmEvb5eQP7RxEJ6wBcXyUFNSWrlYPbBX8DJD7-7SbR3B67meIEFjmc01CEOskLshp7Isw-5-PhVs55y36mwCYsXZQVfn9PBYo0YZMoaGawbbHtTP39IAe4rEc1VeXePaqZBCcbglzSyQkLVcLA7_vdgV6_y1mwl1UkDAO6EufXI8W3IVUpx4H1qLD62m4BAVgWC9-hiy_XwCa87bz8drDZECJRFDKURrz_OnLhdbUuWEYAoxwU2eHfMDzz9wkwm40mJ8K61vD7ufhDJizqIKilvBTjOkMjOYqP-6MBtnKKIVLhhgvdv65rlmmIUl/p.png?is_prewarmed=true",
            height = "150px", width = "150px"
          )
        ),
        # language = "fr",
        app_ui
      ),

      # ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}
