### Croatia

## Load libraries
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

## Set working directory

options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/HRV")
getwd()

## 1. Load Excel file with links
path_hr <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/HRV/Croatia_links.xlsx"
normalizePath(path_hr, winslash = "/", mustWork = NA)
links_hr <- xlsx::read.xlsx(path_hr, sheetIndex = 1, encoding="UTF-8")
glimpse(links_hr)
links_hr[1,2]

## 2. Test
# set URL for the test
url_hr <- links_hr[1,2]
print(url_hr)
is_character(url_hr)

# start phantomJS session
require(webdriver)
pjs_instance <- run_phantomjs()
pjs_session <- Session$new(port = pjs_instance$port)

# Load URL to the session
pjs_session$go(url_hr)
# retrieve the rendered source code of the page
rendered_source <- pjs_session$getSource()
# parse the dynamically rendered source code
html_document <- read_html(rendered_source)

title_path <- '//*[contains(concat( " ", @class, " " ), concat( " ", "docTitle", " " ))]'
date_path <- "/html/body/div[3]/table/tbody/tr/td[2]/div[1]/ul/li/text()"
body_path <- "/html/body/div[4]"

title_text <- html_document %>%
  html_node(xpath = title_path) %>%
  html_text(trim = T)
cat(title_text) # Delete everything after )

date_text <- html_document %>%
  html_node(xpath = date_path) %>%
  html_text(trim = T)
cat(date_text) # Retreive date later

body_text <- html_document %>%
  html_nodes(xpath = body_path) %>%
  html_text(trim = T) %>%
  paste0(collapse = "\n")
cat(body_text) # retrives text

legal_act <- data.frame(
  url = url_hr,
  title = title_text,
  date = date_text,
  body = body_text
)

## 3. Wrap in a function. Take name of the act and URL from initial file, and body&date texts from downloaded

scrape_text_hr <- function(url){
  
  pjs_session$go(url)
  rendered_source <- pjs_session$getSource()
  html_document <- read_html(rendered_source)
  
  title_text <- html_document %>%
    html_node(xpath = title_path) %>%
    html_text(trim = T)
  
  date_text <- html_document %>%
    html_node(xpath = date_path) %>%
    html_text(trim = T)

  
  body_text <- html_document %>%
    html_nodes(xpath = body_path) %>%
    html_text(trim = T) %>%
    paste0(collapse = "\n")
  
  legal_act <- data.frame(
    url = url,
    date = date_text,
    body = body_text,
    title = title_text
  )
}

# Now test with a chunk of the data
links_test <- links_hr[20:30,2]
glimpse(links_test)
corpus_hr_test <- data.frame()

for (i in 1:length(links_test)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_test), "URL:", links_test[i], "\n")
  legal_act <- scrape_text_hr(links_test[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_hr_test <- rbind(corpus_hr_test, legal_act)
}

corpus_hr_test$title[1]

## 4. Now do it for all the documents
hr_links_1 <- links_hr[1:200,2]
hr_links_2 <- links_hr[201:400,2]
hr_links_3 <- links_hr[400:578,2]
head(hr_links_1)

corpus_hr <- data.frame()

for (i in 1:length(hr_links_1)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(hr_links_1), "URL:", hr_links_1[i], "\n")
  legal_act <- scrape_text_hr(hr_links_1[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_hr <- rbind(corpus_hr, legal_act)
}

for (i in 1:length(hr_links_2)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(hr_links_2), "URL:", hr_links_2[i], "\n")
  legal_act <- scrape_text_hr(hr_links_2[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_hr <- rbind(corpus_hr, legal_act)
}

for (i in 1:length(hr_links_3)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(hr_links_3), "URL:", hr_links_3[i], "\n")
  legal_act <- scrape_text_hr(hr_links_3[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_hr <- rbind(corpus_hr, legal_act)
}

corpus_hr_file <- save(corpus_hr, file = "corpus_hr_file.Rda")

## 5. Clean up.
# Clean up titles - delete everything after )
corpus_hr$title[1]
corpus_hr_clean <- corpus_hr
corpus_hr_clean$title <- str_remove(corpus_hr$title, "\\)(.*)")
corpus_hr_clean$title[1]

# Clean up dates - parse strings for dates
library(parsedate)
corpus_hr_clean$date[1]
parse_date(corpus_hr_clean$date[1]) #recognizes the date
corpus_hr_clean$date <- parse_date(corpus_hr$date)
corpus_hr_clean$date <- as.Date(corpus_hr_clean$date)
glimpse(corpus_hr_clean)

# Delete unneccesary column
corpus_hr_clean$fulltitle <- NULL

# check for duplicated
duplicated(corpus_hr_clean[,3:4]) # there are duplicates
corpus_hr_clean <- corpus_hr_clean %>% 
  distinct(date, body, title, .keep_all = T)

# Add ID column
corpus_hr_clean <- tibble::rowid_to_column(corpus_hr_clean, "ID")
#df <- df %>% mutate(id = row_number())
#corpus_hr_final <- corpus_hr %>%
#  select(ID, everything())

# column for full text
corpus_hr_clean$fulltext <- paste(corpus_hr_clean$title,corpus_hr_clean$date, corpus_hr_clean$body, sep ="\n")
print(corpus_hr_clean$fulltext[1])

## 6. Saving files to documents
lapply(1:nrow(corpus_hr_clean), function(i) write.table(corpus_hr_clean[i,6],
                                                 file = paste0(corpus_hr_clean[i,1], "_HRV_", corpus_hr_clean[i,3], ".txt"),
                                                 row.names = FALSE, col.names = FALSE,
                                                 quote = FALSE,
                                                 fileEncoding="UTF-8"))
