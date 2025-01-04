# Load required libraries
library(shiny)
library(DT)  # For interactive tables
library(dplyr)

# Define the UI
ui <- fluidPage(
  titlePanel("Bibliographic Search and PDF Links"),
  
  # Search bar
  sidebarLayout(
    sidebarPanel(
      textInput("search", "Search:", value = ""),
      p("Type in the search box to filter the table.")
    ),
    
    mainPanel(
      DTOutput("bib_table")  # Display the table with search functionality
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # Assuming your combined_df is already loaded and contains the 'project' and other fields
  # Add the PDF links to the data frame
  combined_df <- combined_df %>%
    mutate(pdf_link = paste0('<a href="pdfs/', gsub(" ", "_", tolower(title)), '.pdf" target="_blank">View PDF</a>'))
  
  # Reactive expression to filter the data frame based on search input
  filtered_data <- reactive({
    if (input$search == "") {
      return(combined_df)
    } else {
      combined_df %>%
        filter(grepl(input$search, title, ignore.case = TRUE) | 
                 grepl(input$search, author, ignore.case = TRUE) |
                 grepl(input$search, journal, ignore.case = TRUE) |
                 grepl(input$search, project, ignore.case = TRUE))
    }
  })
  
  # Render the filtered data as a table with PDF links
  output$bib_table <- renderDT({
    datatable(filtered_data(), escape = FALSE, options = list(pageLength = 10))
  })
}

# Run the Shiny app
shinyApp(ui, server)