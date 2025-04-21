summaries_page_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
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
    
  })
}