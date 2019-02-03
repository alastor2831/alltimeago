library(httr)
library(jsonlite)
#setlist_key <- "66b0602a-9d13-41e8-a5f0-721bd9dfad35"

#setlist_root <- "https://api.setlist.fm"

setlist_url <- modify_url(setlist_root, path = "rest/1.0/search/setlists",
                          query = list(artistName = "All Time Low", date = "16-03-2018", p = 1))

setlist_response <- GET(setlist_url, add_headers(`x-api-key` = setlist_key, Accept = "application/json"))
 
 raw_concerts <- content(setlist_response, as = "text", encoding = "UTF-8")
 concerts <- fromJSON(raw_concerts, flatten = TRUE)
 
 result <- c(date = concerts$setlist$eventDate,
             venue = concerts$setlist$venue.name,
             city = concerts$setlist$venue.city.name,
             state = concerts$setlist$venue.city.state,
             country = concerts$venue.city.country.name)
 
# 
# 
# 
# concerts <- concerts %>% mutate(date = dmy(date))