bibtex_editor_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### filter references table ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    # Populate the project filter choices
    observe({
      updateSelectInput(session, "project_filter", choices = c("All", state$all_projects))
    })
    
    # Reactive to filter the data frame by project
    filtered_lit_df <- reactive({
      df <- state$lit_df_reactive()
      if (input$project_filter == "All") {
        df
      } else {
        df[grepl(input$project_filter, df$project), ]
      }
    })
    
    # Render the lit_table_editor DataTable
    output$lit_table_editor <- renderDT({
      datatable(
        filtered_lit_df(),
        selection = "single"
      )
    })
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### edit BibTeX box ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    # Load the selected .bib file into the aceEditor
    observeEvent(input$lit_table_editor_rows_selected, {
      selected_row <- input$lit_table_editor_rows_selected
      if (length(selected_row) > 0) {
        selected_key <- filtered_lit_df()$key[selected_row]
        state$current_ref(selected_key)
        file_path <- file.path("bibtex", "all_bibtex", paste0(selected_key, ".bib"))
        
        if (file.exists(file_path)) {
          bib_content <- readLines(file_path, warn = FALSE)
          project_line <- bib_content[1]
          state$current_projects(sub("^% ", "", project_line))
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
      if (!is.null(state$current_projects())) {
        paste("Appears in projects: ", state$current_projects())
      } else {
        "Appears in projects: "
      }
    })
    
    # Save BibTeX edits
    observeEvent(input$save_bibtex, {
      selected_ref <- state$current_ref()
      showNotification(paste("Current ref:", selected_ref), type = "message")
      
      if (!is.null(selected_ref)) {
        summary_file <- file.path("bibtex", "all_bibtex", paste0(selected_ref, ".bib"))
        project_line <- paste0("% ", state$current_projects())
        bib_content <- c(project_line, strsplit(input$bibtex_text, "\n")[[1]])
        writeLines(bib_content, summary_file)
        
        showNotification("Individual BibTeX file updated successfully.", type = "message")
        
        # Combine BibTeX files
        combine_bib_files("bibtex/all_bibtex", "bibtex")
        showNotification("BibTeX files combined successfully.", type = "message")
        
        # Update global reference tables
        state$update_references_tables()
      } else {
        showNotification("No BibTeX file selected to update.", type = "error")
      }
    })
  })
}
