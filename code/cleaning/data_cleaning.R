#' @title This script import different source of data and unify the format

rm(list = ls())

library(openxlsx)
library(readr)
library(dplyr)
library(lubridate)
library(stringr)

df <- openxlsx::read.xlsx("./data/cleaned_data/data.xlsx", 
                          startRow = 2, detectDates = T)


# # Covert monthly data into quarter data
# mortgage_rate <- read.xlsx("./data/raw/EH45M01.xlsx", 
#                            startRow = 2, detectDates = T)
# 
# # cleaning
# df.mr <- mortgage_rate %>% 
#   select(date = 1,
#          mr = 2 # mortgagte_rate
#          ) %>% 
#   # covert monthly data into quarter data
#   mutate(date = str_replace(date, "M", "-")) %>% 
#   mutate(date = paste0(date, "-01")) %>% 
#   mutate(date = ymd(date)) %>% 
#   # create year and quarter indicator
#   mutate(year = year(date),
#          season = quarter(date)) %>% 
#   group_by(year, season) %>% 
#   summarize(mr = mean(mr),
#             date = head(date, 1)) %>% 
#   ungroup() %>% 
#   select(date, mr) 
#   
# str(df.mr)
# 
# # combine data
# df %>% 
#   left_join(df.mr, by = "date") %>% 
#   View


#' @section Create processed time series to feed the model
#' yt = [Rt rgdpt rmrt, loant ccostt sentt hpt]′
#' `R`    : interbank overnight rate
#' `rgdp` : real GDP
#' `rmr`  : real mortgage rate ~= mr - \Delta CPI
#'          more precisely, rmr = (1 + mr)/(1 + inflation rate) - 1
#' `loan` : the home purchase loans (loan 1) / real GDP
#' `ccost`: the variable construct
#' `sent` : sentiment index
#' `hp`   : house price index


data_claen <- df %>% 
  # find inflation rate
  mutate(CPI_chg = (CPI/lag(CPI) - 1)) %>% 
  # calculate real mortgage rate = (1 + nominal)/(1 + inflation rate) - 1
  mutate(rmr = (mr + 1) / (CPI_chg + 1) - 1) %>% 
  # a rough calc
  mutate(rmr2 = mr - CPI_chg) %>% 
  # find loan to GDP ratio (what is the unit?)
  mutate(loan = loan1 / rGDP,
         loan_nominal = loan1 / nominalGDP) %>% 
  select(date, R, rGDP, rmr, rmr2,
         loan, loan_nominal, ccost = construct, sent, hp = hp_tw1)


# Save RDS file
saveRDS(data_claen, "./data/cleaned_data/data.RDS")
