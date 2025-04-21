bibtex_errors_ui <- function(id) {
  ns <- NS(id)
  
  tabItem(tabName = "bibtex_errors",
          fluidRow(
            column(width = 6,
                   div(class = "box-title", "BibTeX entries that failed to load"),
                   DTOutput(ns("bibtex_errors")), style = "height: 600px; overflow-y: auto;"
            ),
            column(width = 6,
                   div(class = "box-title", "Click on Row to Edit BibTeX Entry"),
                   textOutput(ns("project_display")),
                   aceEditor(ns("bibtex_editor"), mode = "r", theme = "textmate", height = "400px"),
                   actionButton(ns("save_button"), "Save Changes")
            )
          )
  )
}
