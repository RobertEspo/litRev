# One rep max shiny app -------------------------------------------------------
#
# - A shiny app to find your one rep max
# - and create warm up sets to attempt it
# 
# -----------------------------------------------------------------------------

ui <- fluidPage(
  # title
  titlePanel("Warm-up Sets Generator for One Rep Max"),
  # lil info box
  fluidRow(
    # 12 = width
    column(12,
           wellPanel(
             p("This app allows you to input weights and reps completed
                to determine what your one rep max may be.",
               br(),
               "It genereates your 1RM based on the Epley formula
               and the Bryzcki formula.",
               br(),
               "It automatically generates warm up sets for you based 
                on your predicted 1RM from each formula.",
               br(),
               "As this app currently is, you can enter multiple sets.
               However, it is recommended to enter only the most
               relevant set or sets (e.g. your most recent lift(s)
               that is close to your submaximal with at least 8 reps.",
               br(),
               "If you already have a 1RM goal, enter the target weight and
               1 rep, which will generate warm-up sets based on that.
               It is recommended that you follow the warm-up sets 
               based on Bryzcki's formula in this case.")
           ))
  ),
  # sectioning
  sidebarLayout(
    sidebarPanel(
      # p for paragraph (ie <p> html tag)
      p("Enter the weight and number of reps for however many sets
           you have recorded. The weight can be in any unit as long as
           you are consistent."),
      numericInput("wt", "Weight",
                   value = 0,
                   min = 0),
      numericInput("reps", "Number of reps completed",
                   value = 1,
                   min = 1),
      actionButton("addSet", "Add Set"),
      actionButton("clearSets", "Clear Sets"),
      tableOutput("inputTable")
    ),
    mainPanel(
      h3("Warm Up Sets (Epley formula for 1RM)"),
      tableOutput("warmUpTable_e"),
      h3("Warm up Sets (Brzycki formula for 1RM)"),
      tableOutput("warmUpTable_b")
    )
  )
)


server <- function(input, output, session) {
  
  # stores wt and rep data
  sets <- reactiveValues(data = data.frame(
    Weight = numeric(0), 
    Reps = integer(0)
  ))
  
  # appends row to df sets
  observeEvent(input$addSet, {
    new_set <- data.frame(
      Weight = input$wt,
      Reps = input$reps
    )
    sets$data <- rbind(sets$data, new_set)
  })
  
  # clears sets df
  observeEvent(input$clearSets, {
    sets$data <- data.frame(Weight = numeric(0), Reps = integer(0))
  })
  
  # creates table from sets df
  output$inputTable <- renderTable({
    sets$data
  }, rownames = FALSE)
  
  # predict one rep max using Epley formula for each row in df
  # average entire col
  predicted_max_e <- reactive({
    if (nrow(sets$data) == 0) return(0)
    predicted_max_values_e <- (sets$data$Reps * sets$data$Weight * 0.0333) + sets$data$Weight
    mean(predicted_max_values_e)
  })
  
  # predict 1RM using Bryzcki formula for each row in df
  # average entire col
  predicted_max_b <- reactive({
    if (nrow(sets$data) == 0) return(0)
    predicted_max_values_b <- sets$data$Weight / (1.0278 - 0.0278 * sets$data$Reps)
    mean(predicted_max_values_b)
  })
  
  # generate warm-up sets df based on Epley
  warm_up_sets_e <- reactive({
    if (predicted_max_e() == 0) return(NULL)
    data.frame(
      Set = as.factor(seq(1, 5, length.out = 5)),
      Weight = c(0.5 * predicted_max_e(), 
                 0.6 * predicted_max_e(),
                 0.75 * predicted_max_e(),
                 0.85 * predicted_max_e(),
                 predicted_max_e()),
      Reps = factor(c(10, 5, 3, 2, 1))
    )
  })
  
  warm_up_sets_b <- reactive({
    if (predicted_max_b() == 0) return(NULL)
    data.frame(
      Set = as.factor(seq(1, 5, length.out = 5)),
      Weight = c(0.5 * predicted_max_b(), 
                 0.6 * predicted_max_b(),
                 0.75 * predicted_max_b(),
                 0.85 * predicted_max_b(),
                 predicted_max_b()),
      Reps = factor(c(10, 5, 3, 2, 1))
    )
  })
  
  # render warm-up sets df for Epley
  output$warmUpTable_e <- renderTable({
    warm_up_sets_e()
  }, rownames = FALSE)
  
  # render warm-up sets df for Brzycki
  output$warmUpTable_b <- renderTable({
    warm_up_sets_b()
  }, rownames = FALSE)
  
}

# execute app
shinyApp(ui, server)
