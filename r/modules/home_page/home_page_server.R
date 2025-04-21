home_page_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### filter panel ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    # Reactive to filter the data frame
    filtered_data <- reactive({
      df <- state$lit_df_reactive()
      
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
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### references table panel ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
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
        state$current_ref(selected_key)  # Update the currently selected reference
        
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
        keywords_file <- file.path("keywords", "all_keywords", paste0(selected_key, ".txt"))
        if (file.exists(keywords_file)) {
          keywords_content <- readLines(keywords_file)
          updateAceEditor(session, "keywords_text", value = paste(keywords_content, collapse = "\n"))
        } else {
          updateAceEditor(session, "keywords_text", value = "")
        }
      }
    })
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### summary panel ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    # Save summary when the save button is clicked
    observeEvent(input$save_summary, {
      req(state$current_ref())  # Ensure current_ref is not NULL
      
      isolate({
        # Capture the current values immediately
        captured_ref <- state$current_ref()
        captured_summary_text <- input$summary_text  # Use the reactive value
        
        summary_file <- file.path("summaries", "all_summaries", paste0(captured_ref, ".txt"))
        
        writeLines(captured_summary_text, summary_file)
        showNotification("Summary saved successfully!", type = "message")
        
        # Combine summaries if needed
        combine_summaries(here("summaries"), "summaries.txt")
        showNotification("Summaries combined successfully!", type = "message")
      })
    })
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### add BibTeX entry panel ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    # Add BibTeX entry
    observeEvent(input$add_bibtex, {
      bib_entry <- input$bibtex_entry
      file_path <- here("bibtex", input$bib_file)
      
      if (bib_entry != "") {
        tryCatch({
          con <- file(file_path, "a")
          writeLines(paste0("\n\n", bib_entry), con)
          close(con)
          showNotification("BibTeX entry added successfully!", type = "message")
          
          # Update references table or related components
          update_references_tables()
          
        }, error = function(e) {
          showNotification("An error occurred while adding the BibTeX entry.", type = "error")
        })
      } else {
        showNotification("Please select a BibTeX file and enter a BibTeX entry.", type = "error")
      }
    })
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### keywords panel ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    
    # Save keywords when the save button is clicked
    observeEvent(input$save_keywords, {
      req(state$current_ref())  # Ensure current_ref is not NULL
      
      isolate({
        captured_ref <- state$current_ref()
        captured_keywords_text <- input$keywords_text
        
        formatted_keywords_text <- format_keywords(captured_keywords_text)
        
        keyword_file <- file.path("keywords", "all_keywords", paste0(captured_ref, ".txt"))
        
        writeLines(formatted_keywords_text, keyword_file)
        showNotification("Keyword(s) saved successfully!", type = "message")
        
        # Combine keywords if needed
        combine_keywords(here("keywords"), "keywords.txt")
        showNotification("Keywords combined successfully!", type = "message")
      })
    })
    
    # Tooltip for info about keywords box
    shiny::observe({
      shinyjs::runjs('$(function () { $(\'[data-toggle="tooltip"]\').tooltip() })')
    })
    
  })
}
