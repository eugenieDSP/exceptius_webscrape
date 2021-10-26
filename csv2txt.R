library("readxl")
library("dplyr")
library("tidyverse")

setwd('C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS')
path <- "C:/Users/Evgeniya Shtyrkova/Documents/RUG_EXCEPTIUS/EXCEPTIUS/dataset_BE_texts.xlsx"
normalizePath(path, winslash = "/", mustWork = NA)
col.names <- c("NO", "DATE", "CCODE", "TEXT")
texts_BE <- xlsx::read.xlsx(path, sheetIndex = 1, encoding="UTF-8")
glimpse(texts_BE)

texts_BE <- texts_BE %>%
  rename(
    no = NO,
    date = DATE,
    ccode = COUNTRYACR,
    text = LEGAL.TEXT..EN.
  )

enc2utf8(as(texts_BE$Text, "character"))
Encoding(texts_BE$text) <- "UTF-8"

library(lubridate)
class(texts_BE$date)
texts_BE$date <- ymd(texts_BE$date)
texts_BE$date <- format(as.Date(texts_BE$date, '%Y/%m/%d'), '%d/%m/%Y')
texts_BE$date <- as.character(texts_BE$date)
texts_BE$date <- str_remove_all(texts_BE$date, "/")

lapply(1:nrow(texts_BE), function(i) write.table(texts_BE[i,4], file = paste0(texts_BE[i,1], "_BEL_", texts_BE[i,2], ".txt"),
                                                             row.names = FALSE, col.names = FALSE,
                                                             quote = FALSE,
                                                            fileEncoding="UTF-8"))



