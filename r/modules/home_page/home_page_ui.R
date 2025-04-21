home_page_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    #==========================================================================#
    ### home page             ~ top row ###
    ### summary & keyword box ~ add BibTeX box ###
    #==========================================================================#    
    
    div(class = "top-row",
        div(class = "summary-and-keywords-box",
            
            #------------------------------------------------------------------#
            ### summary box ###
            #------------------------------------------------------------------#
            
            div(class = "summary-content",
                div(class = "box-title", "Summary"),
                textOutput(ns("selected_summary_key")),
                textOutput(ns("selected_summary_title")),
                textOutput(ns("selected_summary_author")),
                div(
                  tags$label("Summary Text:"),
                  aceEditor(ns("summary_text"), 
                            mode = "plain_text", 
                            theme = "chrome", 
                            height = "200px",
                            debounce = 500,
                            wordWrap = TRUE)
                ),
                actionButton(ns("save_summary"), "Save Summary", class = "action-button")
            ),
            
            #------------------------------------------------------------------#
            ### keywords box ###
            #------------------------------------------------------------------#
            
            div(class = "keyword-box",
                div(class = "box-title", "Keywords",
                    tags$span(
                      style = "margin-left: 10px;",
                      tags$i(
                        class = "fa fa-question-circle",
                        `data-toggle` = "tooltip",
                        `data-placement` = "bottom",
                        title = "Write separate keywords using line breaks or commas. If a keyword has more than one word, use an underscore (e.g., 'spain_spanish')."
                      )
                    )
                ),
                aceEditor(ns("keywords_text"), 
                          mode = "plain_text", 
                          theme = "chrome", 
                          height = "100px",
                          debounce = 500,
                          wordWrap = TRUE),
                actionButton(ns("save_keywords"), "Save Keywords", class = "action-button")
            )
        ),
        
        #----------------------------------------------------------------------#
        ### add BibTeX box ###
        #----------------------------------------------------------------------#
        
        div(class = "add-bibtex",
            div(class = "box-title", "Add BibTeX"),
            selectInput(ns("bib_file"), "Select BibTeX File:", choices = c("", "file1.bib", "file2.bib"), selected = ""),
            div(
              tags$label("Paste BibTeX Entry Here:"),
              aceEditor(ns("bibtex_entry"), mode = "plain_text", theme = "chrome", height = "150px")
            ),
            actionButton(ns("add_bibtex"), "Add BibTeX", class = "action-button")
        )
    ),
    
    #==========================================================================#    
    ### home page   ~   bottom row ###
    ### search box  ~   references table ###
    #==========================================================================#    
    
    div(class = "bottom-row",
        div(class = "search-box",
            div(class = "box-title", "Search & Filter"),
            textInput(ns("search_title"), "Search Title:", ""),
            textInput(ns("search_author"), "Search Author:", ""),
            selectInput(ns("search_project"), "Filter by Project:", 
                        choices = c("All Projects" = "", all_projects), 
                        selected = ""),
            actionButton(ns("reset_filters"), "Reset Filters", class = "action-button")
        ),
        div(class = "references-box",
            div(class = "box-title", "References"),
            div(style = "height: 600px; overflow-y: auto;",
                DTOutput(ns("lit_table"))
            )
        )
    )
  )
}
