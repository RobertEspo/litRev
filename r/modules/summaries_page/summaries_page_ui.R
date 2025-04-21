summaries_page_ui <- function(id) {
  ns <- NS(id)  
  
  div(class = "summaries-container",
      div(class = "box-title", "Summaries"),
      selectInput(ns("filter_project"), "Filter by Project:", 
                  choices = c("All Projects" = "", all_projects), 
                  selected = ""),
      uiOutput(ns("summary_list"))
  )
}
