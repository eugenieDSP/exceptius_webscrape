### Czechia scraping

## Downloading PDFs like with Cyprus

# Preparation
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/CZH")
getwd()

path_cz <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/CZH/czechia_links.xlsx"
normalizePath(path_cz, winslash = "/", mustWork = NA)
links_cz <- xlsx::read.xlsx(path_cz, sheetIndex = 1, encoding="UTF-8")
glimpse(links_cz)
links_cz[1,]

## 1. Set ID column
links_cz <- tibble::rowid_to_column(links_cz, "ID")
glimpse(links_cz)

## 2. Testing the download
url <- links_cz$URL[1]
destfile <- "myfile.pdf"
download.file(url, destfile, mode="wb")
download.file(links_cy$URL[1], destfile = basename(links_cy$URL[1]), mode="wb")

## 3. Looping the download

for (i in links_cz$ID) {
  Sys.sleep(sample(1:10, 1))
  cat("Downloading", i, "of", length(links_cz$ID), "files", "\n")
  download.file(links_cz$URL[i], destfile = basename(links_cz$URL[i]), mode="wb")
}
