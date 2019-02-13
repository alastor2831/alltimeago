library(shiny)
library(httr)
library(jsonlite)
library(shinyWidgets)
library(readr)
setlist_key <- read_file(file = "key.txt")
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
            h3("Just pick the date of your last concert and press GO!"),
            div(class = "input_area",
                airDatepickerInput(inputId = "date",
                         label = NULL,
                         dateFormat = "dd-mm-yyyy",
                         view = "years",
                         inline = TRUE,
                         value = "2018-12-22"
                         )
            ),
          
               actionBttn(inputId = "button1",
                          label = "Go!",
                          style = "material-flat",
                          color = "danger",
                          size = "lg",
                          block = TRUE),
            uiOutput(outputId = "value", inline = TRUE)

            )
        ),
          div(class = "footer",
            p('Concerts data from', strong('setlist.fm')),
            HTML('<p>Developed by <a href="https://twitter.com/nickeatingpizza">Nick</a> with <img class="shiny-logo" alt="Shiny" src="shiny-logo.png"> ~2018')
        )
)

# Define server logic 
server <- function(input, output) {
   
   num_days_html <- eventReactive(input$button1, {

     
     setlist_url <- paste(setlist_root, "/rest/1.0/search/setlists?",
           "artistName=All%20Time%20Low&",
           "date=", format(input$date, '%d-%m-%Y'), "&p=1", sep = "")
     
     setlist_response <- GET(setlist_url, add_headers(`x-api-key` = setlist_key, Accept = "application/json"))
     
     if(setlist_response[2] == "200"){
       
       gig_raw <- content(setlist_response, as = "text", encoding = "UTF-8")
       gig <- fromJSON(gig_raw, flatten = TRUE)
       
       gig_df <- c(date = gig$setlist$eventDate[1],
                   venue = gig$setlist$venue.name[1],
                   city = gig$setlist$venue.city.name[1],
                   state = gig$setlist$venue.city.state[1],
                   url = gig$setlist$url[1])
       num_days <- Sys.Date() - input$date
       
       gig_text <- HTML(paste("<p class='days'>It has been <span style='color:#ff5964'>", num_days,
                         "</span> days since you last saw All Time Low at",
                         gig_df[['venue']], "in ", gig_df[["city"]], ", ", gig_df[["state"]], "</p>",
                         "<p class='setlist'>Feeling nostalgic? Check out the full <a href='", gig_df[['url']],
                         "'><img class='setlist-logo' src='setlist-logo.png' alt='setlist'></a>")
                        )
       
       tweet_text <- HTML(paste0('<p class="tweet">Also, tell your friends with a <a class="twitter-share-button" href=https://twitter.com/intent/tweet" data-size="large" data-text="It has been ',
                           num_days, ' since I last saw @AllTimeLow at ', gig_df[['venue']],
                           " in ", gig_df[["city"]], ", ", gig_df[["state"]], '" url="" data-hashtags="AllTimeAgo" data-show-count="false">Tweet</a><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script></p>')
       )
   
  
       return(list(gig_text, tweet_text))
       
     }
     
     else h3("Mayday situation! We have no record of an All Time Low show on this day! Try again maybe? (if you don't know a date, just use the default one)")
     
    
})
   
   output$value <-  renderUI({
     num_days_html()
   }) 

   
}

# Run the application 
shinyApp(ui = ui, server = server)

