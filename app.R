library(shiny)
library(httr)
library(jsonlite)
setlist_key <- read.delim(file = "key.txt", header = F, nrows = 1)
setlist_root <- "https://api.setlist.fm"

# Define UI
ui <- tagList(
      
        tags$head(
          tags$link(href = "app.css", rel = "stylesheet", type = "text/css")
        ),
        
        fluidPage(
          verticalLayout(
            h1("All Time Ago"),
            h2("A web app that tells you how long it has been since your last All Time Low concert"),
            h3("Simply enter the date of the last concert you went to and press GO!"),
            div(class = "input_area",
                dateInput(inputId = "date",
                         label = NULL,
                         format = "dd-mm-yyyy",
                         value = "2017-05-09")
            ),
          
               tags$button(id = "button1",
                           type = "button",
                           class = "action-button",
                           "Submit"),
            uiOutput(outputId = "value", inline = TRUE),
            HTML('<a href="https://twitter.com/share?ref_src=twsrc%5
                       Etfw" class="twitter-share-button" data-size="large" 
                       data-show-count="false">Tweet</a><script async
                       src="https://platform.twitter.com/widgets.js" 
                       charset="utf-8"></script>')    
            )
        )
    )

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   re <- eventReactive(input$button1, {

     
     setlist_url <- paste(setlist_root, "/rest/1.0/search/setlists?",
           "artistName=All%20Time%20Low&",
           "date=", format(input$date, '%d-%m-%Y'), "&p=1", sep = "")
     
     setlist_response <- GET(setlist_url, add_headers(`x-api-key` = setlist_key, Accept = "application/json"))
     
     if(setlist_response[2] == "200"){
       
       raw_gig <- content(setlist_response, as = "text", encoding = "UTF-8")
       gig <- fromJSON(raw_gig, flatten = TRUE)
       
       result <- c(date = gig$setlist$eventDate[1],
                   venue = gig$setlist$venue.name[1],
                   city = gig$setlist$venue.city.name[1],
                   state = gig$setlist$venue.city.state[1],
                   country = gig$venue.city.country.name[1])
       
       h3(paste("It has been ", Sys.Date() - input$date,
                "days since you last saw All Time Low at",
                result[['venue']], "in ", result[["city"]], ", ", result[["state"]]))
       
       }
     else h4("Mayday situation! We have no record of an All Time Low show on this day! Try again maybe?")
})
   
   output$value <-  renderUI({
     re()
   }) 

   
}

# Run the application 
shinyApp(ui = ui, server = server)

