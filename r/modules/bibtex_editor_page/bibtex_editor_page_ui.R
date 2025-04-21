bibtex_editor_ui <- function(id) {
  ns <- NS(id)
  
  tabItem(tabName = "bibtex_editor",
          fluidRow(
            column(width = 6,
                   div(class = "box-title", "Literature References"),
                   selectInput(ns("project_filter"), "Select Project:", choices = NULL, selected = "All"),
                   DTOutput(ns("lit_table_editor")), style = "height: 600px; overflow-y: auto;"
            ),
            column(width = 6,
                   div(class = "box-title", "Edit BibTeX Entry"),
                   textOutput(ns("bibtype_display")),
                   aceEditor(ns("bibtex_text"), mode = "plain_text", theme = "textmate", height = "400px"),
                   actionButton(ns("save_bibtex"), "Save BibTeX Entry", class = "action-button")
            )
          )
  )
}
