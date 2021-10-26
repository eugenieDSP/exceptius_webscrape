### Slovenia

## Load libraries
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

## Set working directory

options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/SLV")
getwd()

## 1. Load Excel lfile with links
path_sv <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/SLV/slovenia_links.xlsx"
normalizePath(path_sv, winslash = "/", mustWork = NA)
links_sv <- xlsx::read.xlsx(path_sv, sheetIndex = 1, encoding="UTF-8")
glimpse(links_sv)
links_sv[1,2]

## 2. Test of the HTML page scraping
# set URL for the test
url_sv <- links_sv[1,2]
print(url_sv)
is_character(url_sv)

# start phantomJS session
require(webdriver)
pjs_instance <- run_phantomjs()
pjs_session <- Session$new(port = pjs_instance$port)

# Load URL to the session
pjs_session$go(url_sv)
# retrieve the rendered source code of the page
rendered_source <- pjs_session$getSource()
# parse the dynamically rendered source code
html_document <- read_html(rendered_source)

title_path <- "//h1"
body_path <- '//*[(@id = "docFile")]'
date_path <- '//*[@id="datumi"]/tbody/tr/td/table/tbody/tr/td[1]/table/tbody/tr[2]/td[2]/text()'

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

legal_act <- data.frame(
  url = url_sv,
  title = title_text,
  date = date_text,
  body = body_text
)

## 3. Wrap up in a function.

scrape_text_sv <- function(url){
  
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

## 4. Scrape the texts. Since we have >1000 URLs, divide them in chunks.

links_1 <- links_sv[1:250,2]
links_2 <- links_sv[251:500,2]
links_3 <- links_sv[501:750,2]
links_4 <- links_sv[751:1002,2]

# Let's test on a smaller chunk
links_test <- links_sv[100:120,2]
cat(links_test)
corpus_sv_test <- data.frame()

for (i in 1:length(links_test)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_test), "URL:", links_test[i], "\n")
  legal_act <- scrape_text_sv(links_test[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_sv_test <- rbind(corpus_sv_test, legal_act)
}
glimpse(corpus_sv_test) # parse dates into date format

# Now let's scrape all
corpus_sv <- data.frame()

for (i in 1:length(links_1)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_1), "URL:", links_1[i], "\n")
  legal_act <- scrape_text_sv(links_1[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_sv <- rbind(corpus_sv, legal_act)
}

for (i in 1:length(links_2)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_2), "URL:", links_2[i], "\n")
  legal_act <- scrape_text_sv(links_2[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_sv <- rbind(corpus_sv, legal_act)
}

for (i in 1:length(links_3)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_3), "URL:", links_3[i], "\n")
  legal_act <- scrape_text_sv(links_3[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_sv <- rbind(corpus_sv, legal_act)
}

for (i in 1:length(links_4)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_4), "URL:", links_4[i], "\n")
  legal_act <- scrape_text_sv(links_4[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_sv <- rbind(corpus_sv, legal_act)
}

## 5. Prepare for writing the files
# Check for NAs
NA_corpus <- corpus_sv[rowSums(is.na(corpus_sv)) > 0,]
corpus_sv$url[360]

corpus_sv_full <- na.omit(corpus_sv)
# check again
NA_corpus_1 <- corpus_sv_full[rowSums(is.na(corpus_sv_full)) > 0,]

# Prepare for writing the files - add ID column
corpus_sv_full <- tibble::rowid_to_column(corpus_sv_full, "ID")
# Change date format
corpus_sv_full$date <- as.Date.character(corpus_sv_full$date, tryFormats = "%d.%m.%Y")
corpus_sv_full$date[1]
# Paste title, date, and body together
corpus_sv_full$fulltext <- paste(corpus_sv_full$title,corpus_sv_full$date, corpus_sv_full$body, sep ="\n")
print(corpus_sv_full$fulltext[1])

## 6. Saving files to documents
lapply(1:nrow(corpus_sv_full), function(i) write.table(corpus_sv_full[i,6],
                                                        file = paste0(corpus_sv_full[i,1], "_SLV_", corpus_sv_full[i,3], ".txt"),
                                                        row.names = FALSE, col.names = FALSE,
                                                        quote = FALSE,
                                                        fileEncoding="UTF-8"))
