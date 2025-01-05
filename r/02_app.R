# Load required libraries
source(here::here("r", "00_libs.R"))
source(here::here("r","01_load_data.R"))

# Function to load and split summaries.txt
split_summaries <- function(file_path, output_dir) {
  summaries <- readLines(file_path)
  key <- NULL
  summary_content <- NULL
  
  for (line in summaries) {
    if (startsWith(line, "#")) {  # Check if it's a heading
      if (!is.null(key)) {
        # Save the previous summary content to a file
        writeLines(summary_content, file.path(output_dir, paste0(key, ".txt")))
      }
      # Update key and reset summary_content
      key <- gsub("^#\\s*", "", line)
      summary_content <- NULL
    } else {
      summary_content <- c(summary_content, line)
    }
  }
  
  # Save the last summary
  if (!is.null(key)) {
    writeLines(summary_content, file.path(output_dir, paste0(key, ".txt")))
  }
}

# Define the UI
ui <- dashboardPage(
  dashboardHeader(title = "Literature Review", titleWidth = 300),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .grid-container {
          display: grid;
          grid-template-columns: 1fr 2fr;
          grid-template-rows: auto 1fr;
          gap: 20px;
          height: calc(100vh - 50px);
        }
        .search-box, .references-box, .summary-box {
          background-color: #FFFFFF;
          border-radius: 10px;
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
          padding: 15px;
        }
        .search-box {
          grid-column: 1 / 2;
          grid-row: 2 / 3;
        }
        .references-box {
          grid-column: 2 / 3;
          grid-row: 2 / 3;
        }
        .summary-box {
          grid-column: 1 / 3;
          grid-row: 1 / 2;
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
        .summary-box textarea {
          width: 100%;
          box-sizing: border-box;
        }
        body, label, input, button, select, textarea, .box-title, .dataTables_wrapper {
          color: #000000;
        }
        /* Header styling */
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
        ),
        div(class = "summary-box",
            div(class = "box-title", "Summary"),
            textOutput("selected_summary_title"),
            textAreaInput("summary_text", "", "", rows = 10),  # Removed the label "Summary:"
            actionButton("save_summary", "Save Summary", class = "action-button"),
            actionButton("combine_summaries", "Combine Summaries", class = "action-button"),
            downloadButton("download_summaries", "Download Summaries", 
                           style = "margin-top: 10px; background-color: #CC0033; color: white; border: none; border-radius: 5px; padding: 10px 20px;")
        )
    )
  )
)

# Define the server
server <- function(input, output, session) {
  
  # Run split_summaries() to split summaries.txt into individual files in the "all_summaries" folder
  split_summaries(here::here("summaries", "summaries.txt"), here::here("summaries", "all_summaries"))
  
  # Make the "pdfs" folder accessible via the URL "/pdfs"
  addResourcePath("pdfs", "pdfs")
  
  # Reactive value to keep track of the currently selected reference
  current_ref <- reactiveVal(NULL)
  
  # Reactive to filter the data frame
  filtered_data <- reactive({
    df <- lit_df
    
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
  
  # Render the data table
  output$lit_table <- renderDT({
    
    # Get the column indices for the desired columns
    visible_columns <- which(names(filtered_data()) %in% c("title", "author", "year", "project")) - 1
    
    # Create clickable links in the title column
    filtered_data <- filtered_data() %>% 
      mutate(title = paste0('<a href="pdfs/', key, '.pdf" target="_blank">', title, '</a>'))
    
    datatable(
      filtered_data,
      options = list(
        pageLength = 10,
        autoWidth = TRUE,
        columnDefs = list(
          # Hide the key column
          list(visible = TRUE, targets = visible_columns),
          list(visible = FALSE, targets = "_all")  # Hide all other columns
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
      # Save the current summary before switching to a new one
      if (!is.null(current_ref())) {
        summary_file <- file.path("summaries", "all_summaries", paste0(current_ref(), ".txt"))
        writeLines(input$summary_text, summary_file)
      }
      
      selected_ref <- filtered_data()[selected_row, "key"]
      current_ref(selected_ref)  # Update the currently selected reference
      output$selected_summary_title <- renderText({ paste("Summary for:", selected_ref) })
      
      summary_file <- file.path("summaries", "all_summaries", paste0(selected_ref, ".txt"))
      if (file.exists(summary_file)) {
        summary_content <- readLines(summary_file)
        updateTextAreaInput(session, "summary_text", value = paste(summary_content, collapse = "\n"))
      } else {
        updateTextAreaInput(session, "summary_text", value = "")
      }
    }
  })
  
  # Save summary when the save button is clicked
  observeEvent(input$save_summary, {
    if (!is.null(current_ref())) {
      summary_file <- file.path("summaries", "all_summaries", paste0(current_ref(), ".txt"))
      writeLines(input$summary_text, summary_file)
      showNotification("Summary saved successfully!", type = "message")
    }
  })
  
  # Combine summaries
  observeEvent(input$combine_summaries, {
    summary_files <- list.files(file.path("summaries", "all_summaries"), full.names = TRUE)
    combined_summaries <- lapply(summary_files, function(file) {
      key <- gsub(".txt$", "", basename(file))
      c(paste0("# ", key), readLines(file), "")
    })
    combined_summaries <- unlist(combined_summaries)
    writeLines(combined_summaries, here::here("summaries", "summaries.txt"))
    showNotification("Summaries combined successfully!", type = "message")
  })
  
  # Download summaries
  output$download_summaries <- downloadHandler(
    filename = function() { "summaries.txt" },
    content = function(file) {
      file.copy(here::here("summaries", "summaries.txt"), file)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)