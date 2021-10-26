### Latvia document scraping

## Load libraries
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

## Set working directory

options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/LTV")
getwd()

## 1. Load excel file with all the links
path_lv <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/LTV/latvia_links.xlsx"
normalizePath(path_lv, winslash = "/", mustWork = NA)
links_lv <- xlsx::read.xlsx(path_lv, sheetIndex = 1, encoding="UTF-8")
glimpse(links_lv)
links_lv[1,2]

## 2. Test
# set URL for test
url <- links_lv[1,2]
print(url)
# load URL to phantomJS session
require(webdriver)
pjs_instance <- run_phantomjs()
pjs_session <- Session$new(port = pjs_instance$port)

# Load URL
pjs_session$go(url)
# retrieve the rendered source code of the page
rendered_source <- pjs_session$getSource()
# parse the dynamically rendered source code
html_document <- read_html(rendered_source)

#test_xpath <- "/html/body/div[6]/div[4]/div[2]/div/table/tbody/tr/td[1]/div[6]"
#test_link <- html_document %>%
#  html_node(xpath = test_xpath) %>%
#  html_text2(preserve_nbsp = FALSE)
#print(test_link) # Seems to scrape all the text. Need to extract title and date later.

#latvia_corpus <- data.frame(
#  text = test_link
#)

  ## 3. Creating a function to download text.
#scrape_latvia <- function(url) {
 # pjs_session$go(url)
  #rendered_source <- pjs_session$getSource()
  #html_document <- read_html(rendered_source)
  
  #xpath <- "/html/body/div[6]/div[4]/div[2]/div/table/tbody/tr/td[1]/div[6]" # does not work for all documents
  #text <- html_document %>%
   # html_node(xpath = xpath) %>%
    #html_text2(preserve_nbsp = FALSE)
  
#  corpus <- data.frame(
 #   text = text
#  )
# }

#xpath2 <- '//*[contains(concat( " ", @class, " " ), concat( " ", "tool-1-3", " " ))]'
#text_2 <- html_document %>%
#  html_nodes(xpath = xpath2) %>%
#  html_attr("onclick") # contains string with the link

scrape_latvia <- function(url) {
 pjs_session$go(url)
 rendered_source <- pjs_session$getSource()
 html_document <- read_html(rendered_source)

xpath <- "/html/body/div[6]/div[4]/div[2]/div/table/tbody/tr/td[1]/div[6]" # does not work for all documents
 text <- html_document %>%
 html_node(xpath = xpath) %>%
 html_text2(preserve_nbsp = FALSE)
 
 xpath2 <- '//*[contains(concat( " ", @class, " " ), concat( " ", "tool-1-3", " " ))]'
 text_2 <- html_document %>%
   html_nodes(xpath = xpath2) %>%
   html_attr("onclick")
 
   corpus_links <- data.frame(
   link = text_2,
   text = text
  )
 }

## 4. Testing with 20 links
corpus_latvia <- data.frame()

#test_links <- links_lv[1:20,2]
#for (i in 1:length(test_links)) {
#  Sys.sleep(sample(1:10, 1))
#  cat("Downloading", i, "of", length(test_links), "URL:", test_links[i], "\n")
#  legal_act <- scrape_latvia(test_links[i])
#  corpus_latvia <- rbind(corpus_latvia, legal_act)
#}
# extract links
#latvia_links_c <- str_extract(corpus_latvia_links$link, "'(.*?)'")
#latvia_links_c <- str_remove(latvia_links_c, "'")
#latvia_links_c <- str_remove(latvia_links_c, "'")
#str(latvia_links_c)

# now we download everything
links_1 <- links_lv[,2]
corpus_latvia_links <- data.frame()

for (i in 1:length(links_1)) {
  Sys.sleep(sample(1:10, 1))
  cat("Downloading", i, "of", length(links_1), "URL:", links_1[i], "\n")
  legal_act <- scrape_latvia(links_1[i])
  corpus_latvia_links <- rbind(corpus_latvia_links, legal_act)
}

head(corpus_latvia_links, 10)

# Cleaning up links and saving them to URLs
for (url in corpus_latvia_links){
  corpus_latvia_links$url <- str_extract(corpus_latvia_links$link, "'(.*?)'")
  corpus_latvia_links$url <- str_remove_all(corpus_latvia_links$url, "'")
}

## 5. Downloading the text from the links.
# Don't forget about those cells where text already exists.

corpus_backup <- corpus_latvia_links

# scraping text from the page
url <- "https://m.likumi.lv/doc.php?id=89648"
body_xpath <- '//*[contains(concat( " ", @class, " " ), concat( " ", "doc-body", " " ))]'

scrape_text_lv <- function(url){
  pjs_session$go(url)
  rendered_source <- pjs_session$getSource()
  html_document <- read_html(rendered_source)
  
body_text <- html_document %>%
  html_node(xpath = body_xpath) %>%
  html_text(trim = T)
}


for (i in 1:length(corpus_latvia_links$url)) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", length(corpus_latvia_links$url), "URL:", corpus_latvia_links$url[i], "\n")
  corpus_latvia_links$text[i] <- scrape_text_lv(corpus_latvia_links$url[i])
  #texts_lv <- rbind(texts_lv, text)
}

corpus_lv <- save(corpus_latvia_links, file = "corpus_lv.Rda")

###ARARARRARARARA

corpus_latvia_links$id <- NULL
corpus_latvia_links$id <- seq(1:nrow(corpus_latvia_links))

corpus_latvia_links$fileid <- str_extract(corpus_latvia_links$url, "\\d+")

lapply(1:nrow(corpus_latvia_links), function(i) write.table(corpus_latvia_links[i,2],
                                                 file = paste0(corpus_latvia_links[i,4], "_LTV_", corpus_latvia_links[i,5], ".txt"),
                                                 row.names = FALSE, col.names = FALSE,
                                                 quote = FALSE,
                                                 fileEncoding="UTF-8"))
