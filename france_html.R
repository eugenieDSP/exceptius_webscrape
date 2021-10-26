### Download all html pages provided by the crawler - France ###
# Preparation
options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/France/texts")
getwd()

# install.packages("webdriver")
# install_phantomjs()
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)
## Test 

require(webdriver)
pjs_instance <- run_phantomjs()
pjs_session <- Session$new(port = pjs_instance$port)
url <- "https://legifrance.gouv.fr/jorf/id/JORFTEXT000041686833"

# load URL to phantomJS session
pjs_session$go(url)
# retrieve the rendered source code of the page
rendered_source <- pjs_session$getSource()
# parse the dynamically rendered source code
html_document <- read_html(rendered_source)

title_xpath <- "//h1[contains(@class, 'main-title')]"
title_text <- html_document %>%
  html_node(xpath = title_xpath) %>%
  html_text(trim = T)

cat(title_text) # check: containts title

body_xpath <- "//div[contains(@class, 'page-content')]//p"
body_text <- html_document %>%
  html_nodes(xpath = body_xpath) %>%
  html_text(trim = T) %>%
  paste0(collapse = "\n")

cat(body_text) # check: contains text

legal_act <- data.frame(
  url = url,
  title = title_text,
  body = body_text
  ) # makes a data frame with three variables

## Now we import the dataset with all links
path_fr <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/France/France_links.xlsx"
normalizePath(path, winslash = "/", mustWork = NA)
texts_FR <- xlsx::read.xlsx(path_fr, sheetIndex = 1, encoding="UTF-8")
glimpse(texts_FR)
texts_FR <- texts_FR[1:646, 1:3]

all_links <- texts_FR[1:646, 3]

## Wrap all commands into a function
scrape_legal_text <- function(url){
  pjs_session$go(url)
  rendered_source <- pjs_session$getSource()
  html_document <- read_html(rendered_source)
  
  title_xpath <- "//h1[contains(@class, 'main-title')]"
  title_text <- html_document %>%
    html_node(xpath = title_xpath) %>%
    html_text(trim = T)
  
  body_xpath <- "//div[contains(@class, 'page-content')]//p"
  body_text <- html_document %>%
    html_nodes(xpath = body_xpath) %>%
    html_text(trim = T) %>%
    paste0(collapse = "\n")
  
  legal_act <- data.frame(
    url = url,
    title = title_text,
    body = body_text
    )
}

#split links into smaller chunks
all_links_1 <- all_links[1:150]
all_links_2 <- all_links[151:300]
all_links_3 <- all_links[301:450]
all_links_4 <- all_links[451:600]
all_links_5 <- all_links[601:646]
corpus_covid19_france <- data.frame()

for (i in 1:length(all_links_1)) {
  Sys.sleep(sample(1:10, 1))
  cat("Downloading", i, "of", length(all_links_1), "URL:", all_links[i], "\n")
  legal_act <- scrape_legal_text(all_links_1[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_covid19_france <- rbind(corpus_covid19_france, legal_act)
  }

for (i in 1:length(all_links_2)) {
  Sys.sleep(sample(1:10, 1))
  cat("Downloading", i, "of", length(all_links_2), "URL:", all_links[i], "\n")
  legal_act <- scrape_legal_text(all_links_2[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_covid19_france <- rbind(corpus_covid19_france, legal_act)
}

for (i in 1:length(all_links_3)) {
  Sys.sleep(sample(1:10, 1))
  cat("Downloading", i, "of", length(all_links_3), "URL:", all_links[i], "\n")
  legal_act <- scrape_legal_text(all_links_3[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_covid19_france <- rbind(corpus_covid19_france, legal_act)
}

for (i in 1:length(all_links_4)) {
  Sys.sleep(sample(1:10, 1))
  cat("Downloading", i, "of", length(all_links_4), "URL:", all_links[i], "\n")
  legal_act <- scrape_legal_text(all_links_1[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_covid19_france <- rbind(corpus_covid19_france, legal_act)
}

for (i in 1:length(all_links_5)) {
  Sys.sleep(sample(1:10, 1))
  cat("Downloading", i, "of", length(all_links_5), "URL:", all_links[i], "\n")
  legal_act <- scrape_legal_text(all_links_5[i])
  # Append current article data.frame to the data.frame of all articles
  corpus_covid19_france <- rbind(corpus_covid19_france, legal_act)
}


corpus_covid19_france[10,2]

testset <- corpus_covid19_france[1:15, ]
glimpse(testset)
testset$Date <- str_extract(testset$title, "\\d{1,2}\\s\\b(mars|avril|mai|juin|juillet)\\s\\d{4}")
glimpse(testset) # hooraaaaay

corpus_covid19_france$Date <- str_extract(corpus_covid19_france$title, "\\d{1,2}\\s\\b(mars|avril|mai|juin|juillet|août|septembre|octobre|novembre|décembre)\\s\\d{4}")
glimpse(corpus_covid19_france)

corpus_covid19_france$num_date <- dmy(corpus_covid19_france$Date, locale = "french_france")

# Check for NAs in num_date
corpus_covid19_france[!complete.cases(corpus_covid19_france),]

# Coerce num_date to numeric
corpus_covid19_france$num_date <- as.character(corpus_covid19_france$num_date)

# Manual entries of missing dates in rows 46, 48, 353, 496, 498
corpus_covid19_france[46,5] <- as.Date("2020-04-01")
corpus_covid19_france[48,5] <- as.Date("2020-04-01")
corpus_covid19_france[353,5] <- as.Date("2020-09-01")
corpus_covid19_france[496,5] <- as.Date("2020-04-01")
corpus_covid19_france[498,5] <- as.Date("2020-04-01")

# Concatenate title and body
corpus_covid19_france$full_text <- paste(corpus_covid19_france$title, corpus_covid19_france$body, sep = "\n")
corpus_covid19_france$full_text[1]

# Arrange by date
corpus_covid19_france <- corpus_covid19_france %>%
  arrange(ymd(corpus_covid19_france$num_date))

# Add No
corpus_covid19_france$case <- 1:nrow(corpus_covid19_france)

# Check for duplicated
duplicated(corpus_covid19_france[,1:3])
texts_FR <- corpus_covid19_france %>% 
  distinct(title, body, num_date, .keep_all = T)
# ID number
texts_FR <- texts_FR[,-7]
texts_FR$case <- 1:nrow(texts_FR)

# Write to text files
lapply(1:nrow(texts_FR), function(i) write.table(texts_FR[i,6],
                                                 file = paste0(texts_FR[i,7], "_FRA_", texts_FR[i,5], ".txt"),
                                                 row.names = FALSE, col.names = FALSE,
                                                 quote = FALSE,
                                                 fileEncoding="UTF-8"))

