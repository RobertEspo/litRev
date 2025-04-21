##############################################################################
### Source libs, functions, data, and ui/server modules ###
##############################################################################

source(here::here("r", "00_libs.R"))
source(here("r", "01_functions.R"))
source(here("r","02_load_data.R"))
module_files <- list.files(here("r", "modules"), 
                           pattern = "\\.R$", 
                           recursive = TRUE, 
                           full.names = TRUE)
sapply(module_files, source)

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
      menuItem("Output", tabName = "output_page", icon = icon("folder"))
    )
  ),
  dashboardBody(
      
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### load custom scripts & styles ###
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      
    includeCSS(here("r","www","styles.css")),
    includeCSS(here("r","www","custom.css")),
    tags$head(
      tags$script(src = "www/custom.js")
    ),
    
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
    ### ui modules ####
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

    tabItems(
      
      tabItem(tabName = "home",
              home_page_ui("home1")
      ),
      
      tabItem(tabName = "summaries",
              summaries_page_ui("summaries1")
              ),
      
      tabItem(tabName = "bibtex_errors",
              bibtex_errors_ui("bibtex_errors1")
              ),
      
      tabItem(tabName = "bibtex_editor", 
              bibtex_editor_ui("bibtex_editor1")
              ),
      
      tabItem(tabName = "output_page",
              output_page_ui("output1")
      )
    )
  )
)

##############################################################################
### SERVER ###
##############################################################################

server <- function(input, output, session) {
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  ### define reactive values ###
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  
  addResourcePath("pdfs", "pdfs")
  
  state <- list(
    current_ref = reactiveVal(NULL),
    current_projects = reactiveVal(NULL),
    lit_df_reactive = reactiveVal(lit_df),
    errors_df_reactive = reactiveVal(errors_df),
    summary_text_reactive = reactiveVal(""),
    keywords_text_reactive = reactiveVal(""),
    update_references_tables = function() {
      source(here("r", "02_load_data.R"))
      state$lit_df_reactive(lit_df)
      state$errors_df_reactive(errors_df)
      showNotification("Errors & References tables updated!", type = "message")
    }
  )
  
  # Update reactive values
  observe({ state$summary_text_reactive(input$summary_text) })
  observe({ state$keywords_text_reactive(input$keywords_text) })
  
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  ### server modules ###
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
  
  home_page_server("home1", state = state)
  
  summaries_page_server("summaries1")
  
  bibtex_errors_server("bibtex_errors1", state = state)
  
  bibtex_editor_server("bibtex_editor1", state = state)

  output_page_server("output1")

  }