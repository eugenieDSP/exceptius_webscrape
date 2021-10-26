### Spain

## Load libraries
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

## Set working directory

options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/ESP")
getwd()

## 1. Load Excel file with links
path_es <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/ESP/spain_links.xlsx"
normalizePath(path_es, winslash = "/", mustWork = NA)
links_es <- xlsx::read.xlsx(path_es, sheetIndex = 1, encoding="UTF-8")
glimpse(links_es)
links_es[1,2]

## 2. Test of the HTML page scraping
# set URL for the test
url_es <- links_es[1,2]
print(url_es)
is_character(url_es)

# start phantomJS session
require(webdriver)
pjs_instance <- run_phantomjs()
pjs_session <- Session$new(port = pjs_instance$port)

# Load URL to the session
pjs_session$go(url_es)
# retrieve the rendered source code of the page
rendered_source <- pjs_session$getSource()
# parse the dynamically rendered source code
html_document <- read_html(rendered_source)

title_path <- '//*[@id="barraSep"]/h3/text()'
body_path <- '//*[(@id = "DOdocText")]'
permalink_path <- '//*[@id="barraSep"]/div/div/dl/dd[5]/a'
date_path <- '//*[@id="barraSep"]/div/div/dl/dd[1]/text()[3]'

title_text <- html_document %>%
  html_node(xpath = title_path) %>%
  html_text(trim = T)
cat(title_text) # Works perfectly

date_text <- html_document %>%
  html_node(xpath = date_path) %>%
  html_text(trim = T)
cat(date_text) # Again, perfectly

body_text <- html_document %>%
  html_nodes(xpath = body_path) %>%
  html_text(trim = T) %>%
  paste0(collapse = "\n")
cat(body_text) # retrives text

link_text <- html_document %>%
  html_node(xpath = permalink_path) %>%
  html_text(trim = T)
cat(link_text) #retrieves link

legal_act <- data.frame(
  url = url_sv,
  title = title_text,
  date = date_text,
  body = body_text,
  link = link_text
)

## 3. Wrap up in a function.

scrape_text_es <- function(url){
  
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
  
  link_text <- html_document %>%
    html_node(xpath = permalink_path) %>%
    html_text(trim = T)
  cat(link_text)
  
  legal_act <- data.frame(
    url = url,
    date = date_text,
    body = body_text,
    title = title_text,
    link = link_text
  )
}

## 4. Testing the function on a smaller chunk
links_test <- links_es[10:20,2]
head(links_test)
corpus_es_test <- data.frame()

for (i in 1:length(links_test)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_test), "URL:", links_test[i], "\n")
  legal_act <- scrape_text_es(links_test[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_es_test <- rbind(corpus_es_test, legal_act)
}
glimpse(corpus_es_test)

## 5. Now let's scrape all
corpus_es <- data.frame()
links_1 <- links_es[1:150,2]
links_2 <- links_es[151:300,2]
links_3 <- links_es[301:450,2]
links_4 <- links_es[451:668,2]

for (i in 1:length(links_1)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_1), "URL:", links_1[i], "\n")
  legal_act <- scrape_text_es(links_1[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_es <- rbind(corpus_es, legal_act)
}

for (i in 1:length(links_2)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_2), "URL:", links_2[i], "\n")
  legal_act <- scrape_text_es(links_2[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_es <- rbind(corpus_es, legal_act)
}

for (i in 1:length(links_3)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_3), "URL:", links_3[i], "\n")
  legal_act <- scrape_text_es(links_3[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_es <- rbind(corpus_es, legal_act)
}

for (i in 1:length(links_4)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_4), "URL:", links_4[i], "\n")
  legal_act <- scrape_text_es(links_4[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_es <- rbind(corpus_es, legal_act)
}

corpus_es$title[6]
corpus_es$date[3]

## 6. Extracting date
# Extract year from date column and date from the title
corpus_es_full$url[124]
corpus_es_full <- corpus_es
corpus_es_full$year <- str_extract(corpus_es$date, "\\d{4}")
corpus_es_full$date <- str_extract(corpus_es$link, "\\d{4}\\/\\d{2}\\/\\d{2}")
corpus_es_full$md <- str_extract(corpus_es$title, "\\d{1,2}\\s(de)\\s(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)\\s(de)\\s\\d{4}")

## Now cleaning up the extracted dmy
corpus_es_full$dmy <- str_remove_all(corpus_es_full$md, "de\\s")
## parse the string
Sys.setlocale("LC_TIME", "Spanish")
my_stamp <- stamp("20-02-2019", orders = "dmy") 
corpus_es_full <- corpus_es_full %>%
  mutate_at(vars(dmy), function(x) dmy(x)) %>%
  mutate(formattedDate = my_stamp(dmy))

corpus_es_full$formattedDate <- format(as.Date(corpus_es_full$formattedDate, format = "%d-%m-%Y"), "%Y/%m/%d")

corpus_es_full$date <- ifelse(is.na(corpus_es_full$date), corpus_es_full$formattedDate, corpus_es_full$date)
corpus_es_full$date <- format(as.Date(corpus_es_full$date, format = "%Y/%m/%d"), "%Y-%m-%d")
corpus_es_full$date <- ifelse(is.na(corpus_es_full$date), corpus_es_full$year, corpus_es_full$date)

is.na(corpus_es_full$date)

### 7. Cleaning up and preparing to write in
corpus_es_full <- tibble::rowid_to_column(corpus_es_full, "ID")
corpus_es_final <- corpus_es_full[ ,1:6]
corpus_es_final$fulltext <- paste(corpus_es_final$title,corpus_es_final$date, corpus_es_final$body, sep ="\n")
print(corpus_es_final$fulltext[1])

lapply(1:nrow(corpus_es_final), function(i) write.table(corpus_es_final[i,7],
                                                       file = paste0(corpus_es_final[i,1], "_ESP_", corpus_es_final[i,3], ".txt"),
                                                       row.names = FALSE, col.names = FALSE,
                                                       quote = FALSE,
                                                       fileEncoding="UTF-8"))
