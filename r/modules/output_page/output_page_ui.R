output_page_ui <- function(id) {
  ns <- NS(id)
  
  div(
    class = "grid-container",
    div(
      class = "box-container",
      
      div(
        class = "box-title",
        "Generate Project Output"
      ),

            p(
              "Select a project from the list to generate the output for that project. This will create a folder that contains a .bib file, a folder of PDFs, and all summaries written for the project."
              ),
      
      selectInput(ns("selected_project"), 
                  label = "Select a Project", 
                  choices = all_projects),
      
      actionButton(ns("generate_output"), "Generate Output", icon = icon("folder-open")),
      
      br(), br(),
      verbatimTextOutput(ns("output_status"))
    )
  )
}
