## Web app created almost completely by Claude Sonnet 4:
## https://claude.ai/share/04f7be83-a18a-4c8a-a4a9-25be43da27b1

library(shiny)
library(sortable)
library(digest)
library(tibble)
library(readr)

# Prompt
prmpt <- "Rank these café orders from most to least preferred."

# Items to vote for.
items <- c(
  "Latte",
  "Iced latte",
  "Flat white",
  "Black coffee",
  "Cold brew",
  "Matcha",
  "Tea (coffee has too much caffeine)"
)

# CSV file to record responses
datafile <- "/data/responses.csv"

# Read responses
load_responses <- function() {
  if (file.exists(datafile)) {
    responses <- read_csv(datafile, show_col_types = FALSE)
  } else {
    responses <- tibble(
      timestamp = double(0L),
      device_hash = character(0L),
      rank = integer(0L),
      item = character(0L)
    )
    write_csv(responses, datafile)
  }
  responses
}
# Write response
add_response <- function(response) {
  load_responses() |>
    rbind(response) |>
    write_csv(datafile)
}


ui <- fluidPage(
  titlePanel("Place your vote!"),
  br(),
  h2(prmpt),
  br(),
  p("Rank items from most preferred (top) to least preferred (bottom)."),
  
  # Hidden input to capture browser info
  tags$script(HTML("
    $(document).on('shiny:connected', function() {
      // Now Shiny is ready
      var fingerprint = {
        userAgent: navigator.userAgent,
        language: navigator.language,
        platform: navigator.platform,
        screen: screen.width + 'x' + screen.height,
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
        cookieEnabled: navigator.cookieEnabled
      };
      
      Shiny.setInputValue('browser_info', JSON.stringify(fingerprint));
    });
  ")),
  # Survey content
  rank_list(
    text = "Drag to rank your preferences:",
    labels = items,
    input_id = "ranking"
  ),
  
  br(),
  actionButton("submit", "Submit Ranking"),
  br(), br(),
  p("Submissions are anonymous and responses will be used for demonstration purposes only."),
  verbatimTextOutput("results"),
  verbatimTextOutput("status"),
  br(), br(),
  a("Check out the code on GitHub", href="https://github.com/fleverest/shiny-preferential-voting")
)

server <- function(input, output) {
  responses <- reactiveValues(data = data.frame())

  # Load existing responses
  observe({responses$data <- load_responses()})

  observeEvent(input$submit, {
    req(input$ranking, input$browser_info)
    
    # Create device hash
    device_hash <- digest(input$browser_info, algo = "sha256")
    
    # Check if this device already voted
    if(device_hash %in% responses$data$device_hash) {
      showNotification("You have already submitted a response from this device!", 
                      type = "warning", duration = 5)
      return()
    }
    
    # Add new response
    ranking_order <- input$ranking
    new_response <- tibble(
      timestamp = Sys.time(),
      device_hash = device_hash,
      rank = seq_along(input$ranking),
      item = input$ranking
    )
    # Update dataset
    responses$data <- add_response(new_response)
    
    showNotification("Response submitted successfully!", type = "message")
  })

  output$results <- renderText({
    paste("Total responses:", length(unique(responses$data$device_hash)))
  })

  output$status <- renderText({
    if(!is.null(input$browser_info)) {
      device_hash <- digest(input$browser_info, algo = "sha256")
      if(device_hash %in% responses$data$device_hash) {
        "Status: You have already voted from this device"
      } else {
        "Status: Ready to vote"
      }
    }
  })
}

shinyApp(ui = ui, server = server)
