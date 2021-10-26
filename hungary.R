### Hungary

# '//*[@id="orig"]/div/div[1]/div/div/ul/li[4]/a' - for ELI link_text

## Load libraries
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

## Set working directory

options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/HUN")
getwd()

## 1. Load Excel file with links
path_hu <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/HUN/hungary_links.xlsx"
normalizePath(path_hu, winslash = "/", mustWork = NA)
links_hu <- xlsx::read.xlsx(path_hu, sheetIndex = 1, encoding="UTF-8")
glimpse(links_hu)
links_hu[1,2]

## Test for scraping the actual link

url <- "https://www.njt.hu/jogszabaly/2020-7-20-6Q.4"
# start phantomJS session
require(webdriver)
pjs_instance <- run_phantomjs()
pjs_session <- Session$new(port = pjs_instance$port)

# Load URL to the session
pjs_session$go(url)
# retrieve the rendered source code of the page
rendered_source <- pjs_session$getSource()
# parse the dynamically rendered source code
html_document <- read_html(rendered_source)

# scrape the link
xpath <- '//*[@id="orig"]/div/div[1]/div/div/ul/li[4]/a'
link <- html_document %>%
  html_node(xpath = xpath) %>%
  html_attr("onclick")
print(link) ## gives the text, but now we need the link

# but can I actually scrape all text from the link?
full_xpath <- '//*[@id="orig"]/div/div[1]/section/div/div[4]'
full_text <- html_document %>%
  html_node(xpath = full_xpath) %>%
  html_text(trim = T)
print(full_text) # yes!

# retrieve date separately
date_path <- '//*[contains(concat( " ", @class, " " ), concat( " ", "hatalyText", " " ))]'
date_text <- html_document %>%
  html_node(xpath = date_path) %>%
  html_text(trim = T)
cat(date_text) # needs cleaning, but works well

legal_act <- data.frame(
  url = url,
  date = date_text,
  body = full_text
)
# wrap in a function
scrape_text_hu <- function(url){
  
  pjs_session$go(url)
  Sys.sleep(7)
  rendered_source <- pjs_session$getSource()
  html_document <- read_html(rendered_source)
  
  full_text <- html_document %>%
    html_node(xpath = full_xpath) %>%
    html_text(trim = T)
  
  legal_act <- data.frame(
    url = url,
    body = full_text
  )
}

## testing on a chunk of urls
links_test <- links_hu[10:20,2]
head(links_test)
corpus_hu_test <- data.frame()

for (i in 1:length(links_test)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(links_test), "URL:", links_test[i], "\n")
  legal_act <- scrape_text_hu(links_test[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_hu_test <- rbind(corpus_hu_test, legal_act)
}

glimpse(corpus_hu_test)
view(corpus_hu_test)

url <- "https://www.njt.hu/jogszabaly/2020-7-20-6Q.0"

## Full test
links_1 <- links_hu[1:100,2]
links_2 <- links_hu[101:197,2]
corpus_hu <- data.frame()

for (i in 1:length(links_1)) {
  Sys.sleep(sample(1:3, 1))
  cat("Downloading", i, "of", length(links_1), "URL:", links_1[i], "\n")
  legal_act <- scrape_text_hu(links_1[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_hu <- rbind(corpus_hu, legal_act)
}

for (i in 1:length(links_2)) {
  Sys.sleep(sample(1:3, 1))
  cat("Downloading", i, "of", length(links_2), "URL:", links_2[i], "\n")
  legal_act <- scrape_text_hu(links_2[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_hu <- rbind(corpus_hu, legal_act)
}

view(corpus_hu)

## check for duplicates
duplicated(corpus_hu)
corpus_hu_clean <- corpus_hu %>% 
  distinct(url, body, .keep_all = T)
view(corpus_hu_clean)
glimpse(corpus_hu_clean)

# downloading missing text
url23 <- corpus_hu$url[23]
url46 <- corpus_hu$url[46]
url54 <- corpus_hu$url[54]
url63 <- corpus_hu$url[63]
url80 <- corpus_hu$url[80]
url98 <- corpus_hu$url[98]
url138 <- corpus_hu$url[138]
url148 <- corpus_hu$url[148]

scrape_text_only <- function(url){
  pjs_session$go(url)
  Sys.sleep(7)
  rendered_source <- pjs_session$getSource()
  html_document <- read_html(rendered_source)
  
  full_text <- html_document %>%
    html_node(xpath = full_xpath) %>%
    html_text(trim = T)
}

corpus_hu_clean$body[23] <- scrape_text_only(url23)
corpus_hu_clean$body[46] <- scrape_text_only(url46)
corpus_hu_clean$body[54] <- scrape_text_only(url54)
corpus_hu_clean$body[63] <- scrape_text_only(url63)
corpus_hu_clean$body[80] <- scrape_text_only(url80)
corpus_hu_clean$body[98] <- scrape_text_only(url98)
corpus_hu_clean$body[138] <- scrape_text_only(url138)
corpus_hu_clean$body[148] <- scrape_text_only(url148)

# Add ID column
corpus_hu_clean <- tibble::rowid_to_column(corpus_hu_clean, "ID")

## Extracting dates
corpus_hu_clean[1,3]
pattern <- "\\d{4}\\.\\s\\d{2}\\.\\s\\d{1,2}"
corpus_hu_clean$date <- str_extract(corpus_hu_clean$body, pattern)
corpus_hu_clean$date[1] # dates extracted
view(corpus_hu_clean)

corpus_hu_clean$body <- as.character(corpus_hu_clean$body)
corpus_hu_clean$date <- str_replace_all(corpus_hu_clean$date, ". ", "_")

## Writing into files
lapply(1:nrow(corpus_hu_clean), function(i) write.table(corpus_hu_clean[i,3],
                                                        file = paste0(corpus_hu_clean[i,1], "_HUN_", corpus_hu_clean[i,4], ".txt"),
                                                        row.names = FALSE, col.names = FALSE,
                                                        quote = FALSE,
                                                        fileEncoding="UTF-8"))
