### Hungary
### Scrape links, download text data, save to separate files

## 0. Load libraries
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

## 1. Scraping the links - test

url <- "https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/4/50"
pg <- read_html(url)
links_t <- html_attr(html_nodes(pg, "a"), "href")
links_vector_t <- str_extract(links_t, "\\jogszabaly.+")
links_vector_t <- links_vector_t[!is.na(links_vector_t)]
head(links_vector_t)
links_vector_full_t <- paste0("https://njt.hu/",links_vector_t)


## 2. Creating a loop
# Create a vector with links to be scraped
url_vector <- c("https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/1/50", "https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/2/50",
                "https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/3/50", "https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/4/50",
                "https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/5/50", "https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/6/50",
                "https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/7/50", "https://njt.hu/search/koronav%C3%ADrus:-:2020:-:-:-:-:-:-:1/8/50")
links_HU <- NULL
link_hu <- NULL


scrape_links_hu <- function(url) {
  
  html_document <- read_html(url)
  links <- html_attr(html_nodes(html_document, "a"), "href")
  links_vector <- str_extract(links, "\\jogszabaly.+")
  links_vector_na <- links_vector[!is.na(links_vector)]
  links_vector_full <- paste0("https://njt.hu/",links_vector_na)
}

link_hu <- scrape_links_hu(url_vector[8])
links_HU <- c(links_HU, link_hu)

links_HU_unique <- unique(links_HU)
head(links_HU_unique)

### Now we extract text and title
title_xpath <- //*[@id="dynamic"]/div/div/div[1]/section/div/div[4]




