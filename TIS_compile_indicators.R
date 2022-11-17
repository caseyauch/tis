library(tidyverse)
library(readxl)

#import base file 
base <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/basefile.xls") %>% select(3:5) %>% rename("blockid" = 1, "town"= 2, "mpo"= 3) %>% mutate(blockid = as.numeric(blockid))
#import median income info
income <- read_csv("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/Demographics_2020_0810.csv") %>% mutate(median_income=as.numeric(median_income))
#infrastructure
bike_coverage <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/roadcoverage.xls") %>% select(3,6) %>% rename(bikefacility_p = "BikeFacilities_PCT") 
sidewalk_coverage <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/roadcoverage.xls") %>% select(3,7) %>% rename(sidewalk_p = "Sidewalk_PCT")
potential_walkbike <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/potentialwalkbike.xls") %>% select(2,4) %>% rename(potential = "SUM_Shape_Length") %>% mutate(potential = as.numeric(potential))
#safety
crashes <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/crashes.xls") %>% select("blockid", "Point_Count") %>% rename(crash_count = "Point_Count")
risk <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/risk.xls") %>% select(3,11) %>% rename(risk_ratio = "RiskRoadRatio")
#accessibility
destinations <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/destinations.xls") %>% select(2,11) %>% rename(blockid = "GEOID", cd_sum= "SUM")
jobs <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/jobs.xls") %>% select(2,6) %>% rename(blockid = "GEOID", job_mean = "MEAN")
#affordability
hcost <- read_csv("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/housingcosts_ma.csv") %>% select(1,10) %>% mutate(town = toupper(town))
tcost <- read_csv("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/htindex2019.csv") %>% select(blkgrp, t_80ami) %>% rename(blockid= "blkgrp", tcost_p="t_80ami") %>% mutate(tcost_p = tcost_p/100)
#environment
vmt <- read_excel("S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/vmt.xls") %>% select(2, 4) %>% rename(vmt_sum = "SUM_VMT")

##CREATE LIST OF DATAFRAMES
data <- list(bike_coverage, sidewalk_coverage, potential_walkbike, crashes, risk, destinations, jobs, tcost, vmt)

##BUILD INDICATOR TABLE
indicators <- base
for(i in 1:length(data)){
  if(any(names(data[[i]][1])=='blockid')){
    data[[i]]$blockid <- as.numeric(data[[i]]$blockid)
    indicators <- left_join(indicators, data[i], by='blockid', copy=TRUE)
    print(i)
  }
  else{
    print("na")
  }
}


#join other indicators with hcost 
indicators <- full_join(indicators, hcost, by="town")
print(indicators)
write_csv(indicators,"S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/indicators.csv")
