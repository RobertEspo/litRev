##############################################################################
### Source libs, functions, and data ###
##############################################################################

source(here::here("r", "00_libs.R"))
source(here("r", "01_functions.R"))
source(here("r","02_load_data.R"))

##############################################################################
### UI ###
##############################################################################

ui <- dashboardPage(
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  ### define menu items ####
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  
  dashboardHeader(title = "LitRev", titleWidth = 300),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("Summaries", tabName = "summaries", icon = icon("file-alt")),
      menuItem("BibTeX Errors", tabName = "bibtex_errors", icon = icon("exclamation-triangle")),
      menuItem("BibTeX Editor", tabName = "bibtex_editor", icon = icon("edit")),
      menuItem("Visualizations", tabName = "viz", icon = icon("chart-bar"))
    )
  ),
  dashboardBody(
    tags$head(
      
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      ### collapsible items for summary page ####
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      
      tags$script(HTML("
        document.addEventListener('DOMContentLoaded', function() {
          document.querySelectorAll('details').forEach(function(detail) {
            detail.addEventListener('toggle', function() {
              var summary = detail.querySelector('summary');
              if (detail.open) {
                summary.querySelector('.indicator').textContent = '▼';
              } else {
                summary.querySelector('.indicator').textContent = '▶';
              }
            });
          });
        });
      ")),
      
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      ### prevent line breaks on summary page ####
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      
      tags$style(HTML("
        .summary-item {
          background-color: #f9f9f9;
          border: 1px solid #ddd;
          border-radius: 5px;
          padding: 15px;
          margin-bottom: 15px;
          resize: both; /* Allow resizing of the boxes */
          overflow: auto; /* Ensure content is scrollable if it overflows */
          word-break: break-word; /* Ensure words do not split awkwardly */
          width: 50%; /* Set initial width to 50% of the page */
        }
        .summary-item h4, .summary-item p {
          margin: 0;
        }
        .summary-item details {
          margin-top: 10px;
        }
        .summary-item summary {
          cursor: pointer;
          font-weight: bold;
        }
        .summary-item .indicator {
          margin-right: 5px;
        }
        .summary-item pre {
          white-space: pre-wrap; /* Preserve line breaks and spaces */
          word-break: break-word; /* Ensure words do not split awkwardly */
        }
      "))
    ),
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### grid & styling for homepage ####
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    tabItems(
      tabItem(tabName = "home",
              tags$head(
                tags$style(HTML("
              .grid-container {
                display: grid;
                grid-template-rows: auto auto; /* Two rows */
                gap: 20px;
                height: calc(100vh - 50px);
              }
              .top-row {
                display: grid;
                grid-template-columns: 2fr 1fr; /* Wider first column */
                gap: 20px;
              }
              .bottom-row {
                display: grid;
                grid-template-columns: 1fr 2fr; /* Wider second column */
                gap: 20px;
              }
              .summary-and-keywords-box {
                background-color: #FFFFFF;
                border-radius: 10px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                padding: 15px;
                display: flex;
                flex-direction: row;
                justify-content: space-between;
              }
              .summary-content {
                flex: 1;
                padding-right: 20px;
              }
              .keyword-box {
                flex: 0.3;
              }
              .filter-box, .add-bibtex, .search-box, .references-box {
                background-color: #FFFFFF;
                border-radius: 10px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                padding: 15px;
              }
              .box-title {
                font-family: 'Arial', sans-serif;
                font-weight: bold;
                color: #CC0033;
                margin-bottom: 10px;
              }
              .action-button {
                background-color: #CC0033;
                color: white;
                border: none;
                border-radius: 5px;
                padding: 10px 20px;
                margin-top: 10px;
                cursor: pointer;
              }
              .action-button:hover {
                background-color: #990026;
              }
              textarea, .keyword-filter-box textarea {
                width: 100%;
                box-sizing: border-box;
              }
              body, label, input, button, select, textarea, .box-title, .dataTables_wrapper {
                color: #000000;
              }
              .skin-blue .main-header .logo {
                background-color: #CC0033;
                color: #000000;
                font-weight: bold;
              }
              .skin-blue .main-header .navbar {
                background-color: #CC0033;
              }
            "))
              ),
              div(class = "grid-container",
                  
                  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
                  ### home page             ~ top row ####
                  ### summary & keyword box ~ add BibTeX box ####
                  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
                  div(class = "top-row",
                      div(class = "summary-and-keywords-box",
                          
                          #---------------------------------------------------#
                          ### summary box ###
                          #---------------------------------------------------#
                          
                          div(class = "summary-content",
                              div(class = "box-title", "Summary"),
                              textOutput("selected_summary_key"),
                              textOutput("selected_summary_title"),
                              textOutput("selected_summary_author"),
                              div(
                                tags$label("Summary Text:"),
                                aceEditor("summary_text", 
                                          mode = "plain_text", 
                                          theme = "chrome", 
                                          height = "200px",
                                          debounce = 500,
                                          wordWrap = TRUE)
                              ),
                              actionButton("save_summary", "Save Summary", class = "action-button")
                          ),
                          
                          #---------------------------------------------------#
                          ### keywords box ###
                          #---------------------------------------------------#
                          
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
                              aceEditor("keywords_text", 
                                        mode = "plain_text", 
                                        theme = "chrome", 
                                        height = "100px",
                                        debounce = 500,
                                        wordWrap = TRUE),
                              actionButton("save_keywords", "Save Keywords", class = "action-button")
                          )
                      ),
                      
                      #--------------------------------------------------------#
                      ### add BibTeX box ###
                      #--------------------------------------------------------#
                      
                      div(class = "add-bibtex",
                          div(class = "box-title", "Add BibTeX"),
                          selectInput("bib_file", "Select BibTeX File:", choices = c("", bib_file_names),
                                      selected = ""),
                          div(
                            tags$label("Paste BibTeX Entry Here:"),
                            aceEditor("bibtex_entry", mode = "plain_text", theme = "chrome", height = "150px")
                          ),
                          actionButton("add_bibtex", "Add BibTeX", class = "action-button")
                      )
                  ),
                  
                  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
                  ### home page   ~   bottom row ####
                  ### search box  ~   references table ####
                  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
                  
                  div(class = "bottom-row",
                      div(class = "search-box",
                          div(class = "box-title", "Search & Filter"),
                          textInput("search_title", "Search Title:", ""),
                          textInput("search_author", "Search Author:", ""),
                          selectInput("search_project", "Filter by Project:", 
                                      choices = c("All Projects" = "", all_projects), 
                                      selected = ""),
                          actionButton("reset_filters", "Reset Filters", class = "action-button")
                      ),
                      div(class = "references-box",
                          div(class = "box-title", "References"),
                          DTOutput("lit_table"), style = "height: 600px; overflow-y: auto;"
                      )
                  )
              )
      ),
      
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      ### summaries page ####
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      
      tabItem(tabName = "summaries",
              div(class = "summaries-container",
                  div(class = "box-title", "Summaries"),
                  selectInput("filter_project", "Filter by Project:", 
                              choices = c("All Projects" = "", all_projects), 
                              selected = ""),
                  uiOutput("summary_list")
              )
      ),
      
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      ### BibTeX errors page ####
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      
      tabItem(tabName = "bibtex_errors",
              fluidRow(
                column(width = 6,
                       div(class = "box-title", "BibTeX entries that failed to load"),
                       DTOutput("bibtex_errors"), style = "height: 600px; overflow-y: auto;"
                ),
                column(width = 6,
                       div(class = "box-title", "Click on Row to Edit BibTeX Entry"),
                       textOutput("project_display"),
                       aceEditor("bibtex_editor", mode = "r", theme = "textmate", height = "400px"),
                       actionButton("save_button", "Save Changes")
                )
              )
      ),
      
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      ### BibTeX editor page ####
      #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      
      tabItem(tabName = "bibtex_editor",
              fluidRow(
                column(width = 6,
                       div(class = "box-title", "Literature References"),
                       selectInput("project_filter", "Select Project:", choices = NULL, selected = "All"),  # Add this line
                       DTOutput("lit_table_editor"), style = "height: 600px; overflow-y: auto;"
                ),
                column(width = 6,
                       div(class = "box-title", "Edit BibTeX Entry"),
                       textOutput("bibtype_display"),
                       aceEditor("bibtex_text", mode = "plain_text", theme = "textmate", height = "400px"),
                       actionButton("save_bibtex", "Save BibTeX Entry", class = "action-button")
                )
              )
      )
    )
  )
)

##############################################################################
### Server ###
##############################################################################

server <- function(input, output, session) {
  
  #---------------------------------------------------------------------------#
  ### Define Reactive Values ####
  #---------------------------------------------------------------------------#
  
  addResourcePath("pdfs", "pdfs")               # make pdfs folder accessible
  
  current_ref <- reactiveVal(NULL)              # current reference
  current_projects <- reactiveVal(NULL)         # current project
  lit_df_reactive <- reactiveVal(lit_df)        # current lit_df
  errors_df_reactive <- reactiveVal(errors_df)  # current errors_df
  summary_text_reactive <- reactiveVal("")      # summary text panel home page
  keywords_text_reactive <- reactiveVal("")     # keywords text input
  
  observe({
    summary_text_reactive(input$summary_text)   # update summary text
  })
  observe({
    keywords_text_reactive(input$keywords_text) # update summary text
  })
  
  #---------------------------------------------------------------------------#
  ### define function to update reactive tables ###
  #---------------------------------------------------------------------------#
  
  update_references_tables <- function() {
    source(here("r","02_load_data.R"))
    lit_df_reactive(get("lit_df", envir = .GlobalEnv))
    errors_df_reactive(get("errors_df", envir = .GlobalEnv))
    showNotification("Errors & References tables updated!", type = "message")
  }
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  ### Home Page ####
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  
  #---------------------------------------------------------------------------#
  ### filter panel ###
  #---------------------------------------------------------------------------#
  
  # Reactive to filter the data frame
  filtered_data <- reactive({
    df <- lit_df_reactive()
    
    # Filter by title
    if (input$search_title != "") {
      df <- df[grepl(input$search_title, df$title, ignore.case = TRUE), ]
    }
    
    # Filter by author
    if (input$search_author != "") {
      df <- df[grepl(input$search_author, df$author, ignore.case = TRUE), ]
    }
    
    # Filter by project
    if (input$search_project != "") {
      df <- df[grepl(input$search_project, df$project, ignore.case = TRUE), ]
    }
    
    df
  })
  
  # Reset filters when the reset button is clicked
  observeEvent(input$reset_filters, {
    updateTextInput(session, "search_title", value = "")
    updateTextInput(session, "search_author", value = "")
    updateSelectInput(session, "search_project", selected = "")
  })
  
  #---------------------------------------------------------------------------#
  ### references table panel ###
  #---------------------------------------------------------------------------#
  
  # Render the data table
  output$lit_table <- renderDT({
    
    # Get the column indices for the desired columns
    visible_columns <- which(names(filtered_data()) %in% c("title", "author", "year", "project")) - 1
    
    # Create clickable links in the title column for PDFs
    filtered_data <- filtered_data() %>%
      mutate(title = paste0('<a href="pdfs/', key, '.pdf" target="_blank">', title, '</a>'))
    
    datatable(
      filtered_data,
      options = list(
        pageLength = 10,
        autoWidth = TRUE,
        columnDefs = list(
          list(visible = TRUE, targets = visible_columns),
          list(visible = FALSE, targets = "_all")
        ),
        dom = 'Bfrtip',
        buttons = c('colvis')
      ),
      escape = FALSE,  # Allow HTML rendering (for clickable links)
      rownames = FALSE,
      extensions = 'Buttons',
      selection = 'single'  # Enable single row selection
    )
  })
  
  # Observe row selection
  observeEvent(input$lit_table_rows_selected, {
    selected_row <- input$lit_table_rows_selected
    if (length(selected_row) > 0) {
      
      # Update to the newly selected reference
      selected_key <- filtered_data()$key[selected_row]
      current_ref(selected_key)  # Update the currently selected reference
      
      selected_title <- filtered_data()$title[selected_row]
      selected_author <- filtered_data()$author[selected_row]
      output$selected_summary_key <- renderText({ paste("Key:", selected_key) })
      output$selected_summary_title <- renderText({ paste("Title:", selected_title) })
      output$selected_summary_author <- renderText({ paste("Author(s):", selected_author) })
      
      # Load the summary for the newly selected reference
      summary_file <- file.path("summaries", "all_summaries", paste0(selected_key, ".txt"))
      if (file.exists(summary_file)) {
        summary_content <- readLines(summary_file)
        updateAceEditor(session, "summary_text", value = paste(summary_content, collapse = "\n"))
      } else {
        updateAceEditor(session, "summary_text", value = "")
      }
      
      # Load the keywords for the newly selected reference
      keywords_file <- file.path("keywords", 
                                 "all_keywords",
                                 paste0(selected_key, ".txt"))
      if (file.exists(keywords_file)) {
        keywords_content <- readLines(keywords_file)
        updateAceEditor(session, "keywords_text", value = paste(keywords_content, collapse = "\n"))
      } else {
        updateAceEditor(session, "keywords_text", value = "")
      }
    }
  })
  
  #---------------------------------------------------------------------------#
  ### summary panel ###
  #---------------------------------------------------------------------------#
  
  # Save summary when the save button is clicked
  observeEvent(input$save_summary, {
    req(current_ref())  # Ensure current_ref is not NULL
    
    isolate({
      # Capture the current values immediately
      captured_ref <- current_ref()
      captured_summary_text <- summary_text_reactive()  # Use the reactive value
      
      summary_file <- file.path("summaries", 
                                "all_summaries", 
                                paste0(captured_ref, ".txt"))
      
      writeLines(captured_summary_text, summary_file)
      showNotification("Summary saved successfully!", type = "message")
      
      combine_summaries(here("summaries"),"summaries.txt")
      showNotification("Summaries combined successfully!", type = "message")
    })
  })
  
  #---------------------------------------------------------------------------#
  ### add BibTeX entry panel ###
  #---------------------------------------------------------------------------#
  
  # Add BibTeX entry
  observeEvent(input$add_bibtex, {
    # Construct the file path
    bib_entry <- input$bibtex_entry
    file_path <- here("bibtex", input$bib_file)
    
    # Append the BibTeX entry to the selected file with a line break
    if (bib_entry != "") {
      tryCatch({
        # Open the file in append mode
        con <- file(file_path, "a")
        # Write the entry with a newline before it
        writeLines(paste0("\n\n", bib_entry), con)
        # Close the file connection
        close(con)
        showNotification("BibTeX entry added successfully!", type = "message")
        
        # Update the reactive data frames
        update_references_tables()
        
      }, error = function(e) {
        showNotification("An error occurred while adding the BibTeX entry.", type = "error")
      })
    } else {
      showNotification("Please select a BibTeX file and enter a BibTeX entry.", type = "error")
    }
  })
  
  #---------------------------------------------------------------------------#
  ### keywords panel ###
  #---------------------------------------------------------------------------#
  
  # Tool tip box
  shiny::observe({
    shinyjs::runjs('$(function () { $(\'[data-toggle="tooltip"]\').tooltip() })')
  })
  
  observeEvent(input$save_keywords, {
    req(current_ref())  # Ensure current_ref is not NULL
    
    isolate({
      # Capture the current values immediately
      captured_ref <- current_ref()
      captured_keywords_text <- keywords_text_reactive()  # Use the reactive value
      
      formatted_keywords_text <- format_keywords(captured_keywords_text)
      
      keyword_file <- file.path("keywords",
                                "all_keywords",
                                paste0(captured_ref, ".txt"))
      
      # Update individual .txt files
      writeLines(formatted_keywords_text, keyword_file)
      showNotification("Keyword(s) saved successfully!", type = "message")
      
      # Combine into keywords.txt
      combine_keywords(here("keywords"),"keywords.txt")
      showNotification("Keywords combined successfully!", type = "message")      
      
    })
  })
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  ### Summaries Page ###
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  
  # Render the summary list
  output$summary_list <- renderUI({
    summaries <- list.files(file.path("summaries", "all_summaries"), full.names = TRUE)
    
    filtered_summaries <- summaries
    if (input$filter_project != "") {
      filtered_keys <- lit_df %>% filter(project == input$filter_project) %>% pull(key)
      filtered_summaries <- summaries[basename(summaries) %in% paste0(filtered_keys, ".txt")]
    }
    
    summary_ui <- lapply(filtered_summaries, function(file) {
      key <- gsub(".txt$", "", basename(file))
      title <- lit_df %>% filter(key == !!key) %>% pull(title)
      author <- lit_df %>% filter(key == !!key) %>% pull(author)
      summary_content <- readLines(file)
      
      div(class = "summary-item",
          tags$h4(paste("Key:", key)),
          tags$p(paste("Title:", title)),
          tags$p(paste("Author(s):", author)),
          tags$details(
            tags$summary(
              tags$span(class = "indicator", "▶"),
              tags$span(" Summary")
            ),
            tags$pre(paste(summary_content, collapse = "\n"))
          )
      )
    })
    
    do.call(tagList, summary_ui)
  })
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  ### BibTeX Errors Page ###  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  
  #---------------------------------------------------------------------------#
  ### BibTeX table ###
  #---------------------------------------------------------------------------#
  
  # Render the datatable for BibTeX errors
  output$bibtex_errors <- renderDT({
    datatable(
      errors_df_reactive(),
      options = list(
        pageLength = 10,
        autoWidth = TRUE,
        dom = 'Bfrtip',
        buttons = c('colvis')
      ),
      escape = FALSE,  # Allow HTML rendering (for clickable links)
      rownames = FALSE,
      extensions = 'Buttons',
      selection = 'single'  # Enable single row selection
    )
  })
  
  #---------------------------------------------------------------------------#
  ### BibTeX correction box ###
  #---------------------------------------------------------------------------#
  
  # Load the selected .bib file into the aceEditor
  observeEvent(input$bibtex_errors_rows_selected, {
    selected_row <- input$bibtex_errors_rows_selected
    if (length(selected_row) > 0) {
      selected_key <- errors_df_reactive()$key[selected_row]  # Correctly access the reactive value as a data frame
      current_ref(selected_key)
      file_path <- file.path("bibtex", "all_bibtex", paste0(selected_key, ".bib"))
      
      if (file.exists(file_path)) {
        bib_content <- readLines(file_path, warn = FALSE)
        project_line <- bib_content[1]
        current_projects(sub("^% ", "", project_line))
        bib_content <- bib_content[-1]
        updateAceEditor(session, "bibtex_editor", value = paste(bib_content, collapse = "\n"))
      } else {
        updateAceEditor(session, "bibtex_editor", value = "File not found.")
      }
      showNotification(paste("Selected key:", selected_key), type = "message")
    }
  })
  
  # Display the projects above the text box
  output$project_display <- renderText({
    if (!is.null(current_projects())) {
      paste("Appears in projects: ", current_projects())
    } else {
      "Appears in projects: "
    }
  })
  
  # Save Changes to the individual .bib file and combine BibTeX files when the save button is clicked
  observeEvent(input$save_bibtex, {
    selected_ref <- current_ref()  # Assign the reactive value to a local variable
    showNotification(paste("Current ref:", selected_ref), type = "message")
    if (!is.null(selected_ref)) {
      # Save the current content of the bibtex_text to the individual .bib file
      summary_file <- file.path("bibtex", "all_bibtex", paste0(selected_ref, ".bib"))
      project_line <- paste0("% ", current_projects())
      bib_content <- c(project_line, strsplit(input$bibtex_text, "\n")[[1]])
      writeLines(bib_content, summary_file)
      showNotification("Individual BibTeX file updated successfully.", type = "message")
      
      # Combine all BibTeX files into the project files (assuming combine_bib_files is a predefined function)
      combine_bib_files("bibtex/all_bibtex", "bibtex")
      showNotification("BibTeX files combined successfully.", type = "message")
      
      # Update the reactive data frames
      update_references_tables()
    } else {
      showNotification("No BibTeX file selected to update.", type = "error")
    }
  })
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  ### BibTeX Editor Page ###  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  
  #---------------------------------------------------------------------------#
  ### filter references table ###
  #---------------------------------------------------------------------------#
  
  # Populate the project filter choices
  observe({
    updateSelectInput(session, "project_filter", choices = c("All", all_projects))
  })
  
  # Reactive to filter the data frame by project
  filtered_lit_df <- reactive({
    if (input$project_filter == "All") {
      lit_df_reactive()
    } else {
      lit_df_reactive()[grepl(input$project_filter, lit_df_reactive()$project), ]
    }
  })
  
  # Render the lit_table_editor DataTable
  output$lit_table_editor <- renderDT({
    datatable(
      filtered_lit_df(),
      selection = "single"
    )
  })
  
  #---------------------------------------------------------------------------#
  ### edit BibTeX box ###
  #---------------------------------------------------------------------------#
  
  # Load the selected .bib file into the aceEditor
  observeEvent(input$lit_table_editor_rows_selected, {
    selected_row <- input$lit_table_editor_rows_selected
    if (length(selected_row) > 0) {
      selected_key <- filtered_lit_df()$key[selected_row]
      current_ref(selected_key)
      file_path <- file.path("bibtex", "all_bibtex", paste0(selected_key, ".bib"))
      
      if (file.exists(file_path)) {
        bib_content <- readLines(file_path, warn = FALSE)
        project_line <- bib_content[1]
        current_projects(sub("^% ", "", project_line))
        bib_content <- bib_content[-1]
        updateAceEditor(session, "bibtex_text", value = paste(bib_content, collapse = "\n"))
      } else {
        updateAceEditor(session, "bibtex_text", value = "File not found.")
      }
      showNotification(paste("Selected key:", selected_key), type = "message")
    }
  })
  
  # Display the projects above the text box
  output$bibtype_display <- renderText({
    if (!is.null(current_projects())) {
      paste("Appears in projects: ", current_projects())
    } else {
      "Appears in projects: "
    }
  })
  
  # Save Changes to the individual .bib file and combine BibTeX files when the save button is clicked
  observeEvent(input$save_bibtex, {
    selected_ref <- current_ref()
    showNotification(paste("Current ref:", selected_ref), type = "message")
    
    if (!is.null(selected_ref)) {  # Fixed missing closing parenthesis
      # Save the current content of the bibtex_text to the individual .bib file
      summary_file <- file.path("bibtex", "all_bibtex", paste0(selected_ref, ".bib"))
      project_line <- paste0("% ", current_projects())
      bib_content <- c(project_line, strsplit(input$bibtex_text, "\n")[[1]])
      writeLines(bib_content, summary_file)
      showNotification("Individual BibTeX file updated successfully.", type = "message")
      
      # Combine all BibTeX files into the project files (assuming combine_bib_files is a predefined function)
      combine_bib_files("bibtex/all_bibtex", "bibtex")
      showNotification("BibTeX files combined successfully.", type = "message")
      
      # Update the reactive data frames
      update_references_tables()
    } else {
      showNotification("No BibTeX file selected to update.", type = "error")
    }
  })
}
