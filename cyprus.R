### Cyprus
## Downloading PDFs

# Preparation
library(webdriver)
library(rvest)
library(tidyverse)
library(lubridate)

options(stringsAsFactors = F)
setwd("~/RUG_EXCEPTIUS/EXCEPTIUS/CPR")
getwd()

path_cy <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/CPR/cyprus_links.xlsx"
normalizePath(path_cy, winslash = "/", mustWork = NA)
links_cy <- xlsx::read.xlsx(path_cy, sheetIndex = 1, encoding="UTF-16")
glimpse(links_cy)
links_cy[1,] # title obvs does not work

#set ID column
links_cy <- tibble::rowid_to_column(links_cy, "ID")
glimpse(links_cy)

# try to extract law numbers
print(head(links_cy$Name))
links_cy$numid <- str_extract(links_cy$Name, "(\\d{1,3}\\/\\d{4})")
links_cy$numid[1:20] # NAs but because these laws don't have number
links_cy$date <- str_extract(links_cy$Name, "(\\d{1,3}\\/\\d{1,2}\\/\\d{4})")
links_cy$date <- str_replace_all(links_cy$date, "/", "_")

links_cy$Name[134] # for those who do not nave dates or names
links_cy$date <- ifelse(is.na(links_cy$date),
                      str_extract(links_cy$Name, "(\\d{1,2}\\(.\\)\\/\\d{4})"),
                      links_cy$date) # it worked!

links_cy$date[253] <- "001"
links_cy$date[235] <- "002"
links_cy$date[236] <- "003"
links_cy$date[271] <- "004"
links_cy$date[317] <- "005"
links_cy$date[318] <- "006"
links_cy$date[319] <- "007"

# Now downloading and assigning names
# testing how to download so that files are not corrupted
url <- links_cy$URL[1]
destfile <- "myfile.pdf"
download.file(url, destfile, mode="wb")
download.file(links_cy$URL[1], destfile = basename(links_cy$URL[1]), mode="wb")

for (i in links_cy$ID) {
  Sys.sleep(sample(1:15, 1))
  cat("Downloading", i, "of", length(links_cy$ID), "files", "\n")
  download.file(links_cy$URL[i], destfile = basename(links_cy$URL[i]), mode="wb")
}

## Clean up extensions
startingDir <- "~/RUG_EXCEPTIUS/EXCEPTIUS/CPR"
old_files <- list.files(startingDir,
                 pattern = "\\.pdf&qstring=covid-19",
                 full.names = TRUE)

new_files <- gsub(".pdf&qstring=covid-19", ".pdf", old_files )
file.rename(old_files, new_files)

# now for htm files
old_htm <- list.files(startingDir,
                      pattern = "\\.htm&qstring=covid-19",
                      full.names = TRUE)

new_htm <- gsub(".htm&qstring=covid-19", ".htm", old_htm )
file.rename(old_htm, new_htm)

# and finally html
old_html <- list.files(startingDir,
                      pattern = "\\.html&qstring=covid-19",
                      full.names = TRUE)

new_html <- gsub(".html&qstring=covid-19", ".html", old_html )
file.rename(old_html, new_html)

html_to_pdf <- function(html_file, pdf_file) {
  cmd <- sprintf("pandoc %s -t latex -o %s", html_file, pdf_file)
  system(cmd)
}

path <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/CPR/28-2020.html"
normalizePath(path, winslash = "/", mustWork = NA)
html_to_pdf(path, "out.pdf" )
## Add numbering and country code
