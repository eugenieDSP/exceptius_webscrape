## Austria - downloading and saving
## First we need to download rtfs and save them to the working directory;
## Second, we need to convert them to plain text with good encoding.

# Preparation
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/AUT")
getwd()

### Import the excel file with rtf links
path_au <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/AUT/austria_links.xlsx"
normalizePath(path_au, winslash = "/", mustWork = NA)
texts_au <- xlsx::read.xlsx(path_au, sheetIndex = 1, encoding="UTF-8")
glimpse(texts_au)
texts_au[1,]

# extract short names and dates to name the files automatically
texts_au$name <- str_extract(texts_au$URL, "/.(?:.(?!/.))+$")
# delete forward slash
texts_au$name <- gsub("/", "", texts_au$name)

texts_au$URL[5]
length(texts_au)

##now download all files
for (i in texts_au$NO) {
  Sys.sleep(sample(1:5, 1))
  cat("Downloading", i, "of", texts_au$NO[i], "files", "\n")
  download.file(texts_au$URL[i], destfile = texts_au$name[i])
}
