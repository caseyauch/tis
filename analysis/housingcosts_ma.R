#for the TIS Score, I collected six months of data (January, February, March 2016 and 2022) for single-family homes and condominiums
library(htmltab)
library(XML)
library(RCurl)
library(rvest)
library(tidyverse)

#create list of relevant data source urls
urls<- list(
  "https://s3.amazonaws.com/marketstatsreports.showingtime.com/MAR_z4jps/sst/201601/00sf.htm", #january 2016
  "https://s3.amazonaws.com/marketstatsreports.showingtime.com/MAR_z4jps/sst/201602/00sf.htm", #february 2016
  "https://s3.amazonaws.com/marketstatsreports.showingtime.com/MAR_z4jps/sst/201603/00sf.htm", #march 2016
  "http://marketstatsreports.showingtime.com/MAR_z4jps/sst/202201/00sf.htm", #january 2022
  "http://marketstatsreports.showingtime.com/MAR_z4jps/sst/202202/00sf.htm", #february 2022
  "http://marketstatsreports.showingtime.com/MAR_z4jps/sst/202203/00sf.htm") #march 2022

#create new df with town names
url_parsed <- htmlParse(getURL(urls[1]), asText=TRUE)
doc <- getNodeSet(url_parsed, c('//*[@id="MAR_Sortable_17354"]')) #select html div for data table 
towns <- readHTMLTable(doc[[1]]) %>% select(c(2,5)) %>% rename(town="V2") #select columns for town and median sales price
towns <- towns[-c(1:5,357:406),] %>% select(-c(2))
rownames(towns) <- NULL #reset row names
head(towns)

x = 1
#add monthly median sales price data to towns df
while(x <7){
  names = list('jan16', 'feb16', 'mar16', 'jan22', 'feb22', 'mar22') 
  c = toString(names[x])
  url_parsed <- htmlParse(getURL(urls[x]), asText=TRUE)
  doc <- getNodeSet(url_parsed, c('//*[@id="MAR_Sortable_17354"]')) 
  month <- readHTMLTable(doc[[1]]) %>% select(c(2, 5))
  month$V5 <- gsub("[$,]", "", month$V5) #drop price formatting
  month$V5 <- as.numeric(month$V5) #price as number
  month <- month[-c(1:5,357:406),] #slice empty rows
  month <- month %>% select(-c(1)) %>% rename(!!c:="V5") #drop towns column and rename price col as month-year date
  rownames(month) <- NULL #reset row names
  towns[,ncol(towns)+1] <- month #append to towns df
  x = x+1
  print(x)
}

#calculate yearly average median sales price
towns$mean16 <- rowMeans(towns[,c(2,3,4)], na.rm=TRUE)
towns$mean22 <- rowMeans(towns[,c(5,6,7)], na.rm=TRUE)

#calculate percent change between 2016 and 2022
towns$hcost_p <- (towns[,9]-towns[,8])/towns[,8]

#write csv
write_csv(towns,"S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/housingcosts_ma.csv")

