bibtex_errors_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    
    # Initialize local reactive (if needed)
    status_message <- reactiveVal("")
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### BibTeX table ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    # Render BibTeX errors table
    output$bibtex_errors <- renderDT({
      datatable(
        state$errors_df_reactive(),
        options = list(
          pageLength = 10,
          autoWidth = TRUE,
          dom = 'Bfrtip',
          buttons = c('colvis')
        ),
        escape = FALSE,
        rownames = FALSE,
        extensions = 'Buttons',
        selection = 'single'
      )
    })
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### BibTeX correction box ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    # Load selected .bib file into editor
    observeEvent(input$bibtex_errors_rows_selected, {
      selected_row <- input$bibtex_errors_rows_selected
      if (length(selected_row) > 0) {
        selected_key <- state$errors_df_reactive()$key[selected_row]
        state$current_ref(selected_key)
        file_path <- file.path("bibtex", "all_bibtex", paste0(selected_key, ".bib"))
        
        if (file.exists(file_path)) {
          bib_content <- readLines(file_path, warn = FALSE)
          project_line <- bib_content[1]
          state$current_projects(sub("^% ", "", project_line))
          bib_content <- bib_content[-1]
          updateAceEditor(session, "bibtex_editor", value = paste(bib_content, collapse = "\n"))
        } else {
          updateAceEditor(session, "bibtex_editor", value = "File not found.")
        }
        showNotification(paste("Selected key:", selected_key), type = "message")
      }
    })
    
    # Display current project name above editor
    output$project_display <- renderText({
      if (!is.null(state$current_projects())) {
        paste("Appears in projects: ", state$current_projects())
      } else {
        "Appears in projects: "
      }
    })
    
    # Save edits and update all BibTeX files
    observeEvent(input$save_button, { 
      selected_ref <- state$current_ref()
      showNotification(paste("Current ref:", selected_ref), type = "message")
      
      if (!is.null(selected_ref)) {
        file_path <- file.path("bibtex", "all_bibtex", paste0(selected_ref, ".bib"))
        project_line <- paste0("% ", state$current_projects())
        bib_content <- c(project_line, strsplit(input$bibtex_editor, "\n")[[1]])
        writeLines(bib_content, file_path)
        
        showNotification("Individual BibTeX file updated successfully.", type = "message")
        
        combine_bib_files("bibtex/all_bibtex", "bibtex")
        showNotification("BibTeX files combined successfully.", type = "message")
        
        state$update_references_tables()
      } else {
        showNotification("No BibTeX file selected to update.", type = "error")
      }
    })
  })
}
