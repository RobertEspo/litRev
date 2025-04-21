output_page_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    status_message <- reactiveVal("")
    
    observeEvent(input$generate_output, {
      req(input$selected_project)
      
      project_name <- input$selected_project
      project_name_wo_ext <- tools::file_path_sans_ext(project_name)
      output_folder_path <- here::here(project_name_wo_ext)
      
      if (!dir.exists(output_folder_path)) {
        dir.create(output_folder_path)
      }
      
      # Output .bib file
      bib_file_source <- here::here("bibtex", project_name)
      if (file.exists(bib_file_source)) {
        file.copy(bib_file_source, output_folder_path, overwrite = TRUE)
        status_message(paste("Folder and .bib file created for project:", project_name))
      } else {
        status_message(paste("Bib file not found for project:", project_name))
      }
      
      # Output summaries
      project_lit_df <- lit_df %>% filter(project == project_name)
      bib_keys <- project_lit_df$key
      summary_source <- here::here("summaries", "all_summaries")
      
      summary_contents <- lapply(bib_keys, function(key) {
        summary_file <- file.path(summary_source, paste0(key, ".txt"))
        title <- lit_df %>% filter(key == !!key) %>% pull(title)
        author <- lit_df %>% filter(key == !!key) %>% pull(author)
        
        title <- ifelse(length(title) > 0, title, "Unknown Title")
        author <- ifelse(length(author) > 0, author, "Unknown Author")
        
        if (file.exists(summary_file)) {
          c(paste0("# ", key), paste0("Title: ", title), paste0("Author: ", author), readLines(summary_file), "")
        } else {
          paste0("[Missing summary for ", key, "]")
        }
      })
      
      combined_summary <- unlist(lapply(summary_contents, function(x) c(x, "", "")))
      writeLines(combined_summary, here::here(output_folder_path, paste0(project_name_wo_ext, "_summaries.txt")))
      
      # Output PDFs
      pdf_folder_name <- paste0(project_name_wo_ext, "_pdfs")
      pdf_folder_path <- here::here(output_folder_path, pdf_folder_name)
      if (!dir.exists(pdf_folder_path)) {
        dir.create(pdf_folder_path)
      }
      
      lapply(bib_keys, function(key) {
        pdf_source <- here::here("pdfs", paste0(key, ".pdf"))
        pdf_destination <- file.path(pdf_folder_path, paste0(key, ".pdf"))
        if (file.exists(pdf_source)) {
          file.copy(pdf_source, pdf_destination, overwrite = TRUE)
        } else {
          message(paste("Missing PDF for", key))
        }
      })
      
      status_message(paste("Folder, summaries, and PDFs created for project:", project_name_wo_ext))
    })
    
    output$output_status <- renderText({
      status_message()
    })
    
  })
}
