# Transportation Is Supportive 
This repository contains data and methodology to support a project that analyzes the impact of transportation across the 13 Metropolitan Planning Organizations (MPO) regions. The Transportation Is Supportive (TIS) Score is a relative measure of the transportation system’s support of a high quality of life. A higher TIS denotes a transportation system that supports a higher quality of life. The geography is census block groups (ACS 2020) and unit of analysis is a combined index score.
## Prepare Data
For this analysis, we determined ten indicators that represent five categories of transportation impact: infrastructure, safety, accessibility, affordability, and environment. 
### Infrastructure
This project measures infrastructure in three ways: bicycle facility coverage, sidewalk coverage, and high potential for everyday walking. Data are pulled from the [2021 Road Inventory](https://massdot.maps.arcgis.com/home/item.html?id=342e8400ba3340c1bf5bf2b429ad8294#overview) and the [Potential for Everyday Walking](https://geo-massdot.opendata.arcgis.com/datasets/MassDOT::potential-for-everyday-biking-2022-update/about) layer containing latent demand for active-mode trip making.
- **Bicycle Facility Coverage**: Road segments were attributed to a block group, total milage per block group was calculated, and road segments were filtered by facility type (12). The percentage of road miles with bicycle facilities is calculated per block group by dividing road miles with bike facilities by total road miles. 
- **Sidewalk Coverage**: Road segments were attributed to a block group, total milage per block group was calculated, and road segments were filtered by left or right sidewalk widths (4+). The percentage of road miles with sidewalks is calculated per block group by dividing road miles with sidewalks by total road miles. 
- **Potential for Everyday Walking**: Road segments were attributed to a block group and filtered by potential (high) and totaled. 
### Safety
This project measures safety in two ways: number of fatal and serious injury crashes and relative roadway risk. 2019-2020 crash data are pulled from [MassDOT IMPACT Portal](https://apps.impact.dot.state.ma.us/cdv/). 2022 MPO rankings for bicycle safety, pedestrian safety, roadway departure, and speed aggression risk are pulled from [MassDOT Impact Open Data](https://massdot-impact-crashes-vhb.opendata.arcgis.com/). 
- **Fatal and Serious Injury Crashes**: Crash locations were attributed to a block group and totaled. 
- **Roadway Risk**: Road segments were attributed to a block group and total milage was calculated. Mileage from all four risk categories was combined to capture total risk miles. The roadway risk ratio is calculated per block group by dividing total risk miles by total road miles. 
### Accessibility 
This project measures access to critical destinations and all jobs. Critical destinations (CDs) are defined as food retailers, acute & non-acute care hospitals, community health centers, K-12 schools & colleges, and public housing. Data for food retailers is pulled from [MAPC Food Systems data](https://experience.arcgis.com/experience/f3de9dc909a54f89985c9df8c01723d7/page/Airtable/?%5B%E2%80%A6%5D16ece44-layer-43-FoodInsecurity_CensusTracts_updated%3A427). All other CD data are pulled from [MassGIS](https://www.mass.gov/info-details/massgis-data-layers). The analysis is performed using [Conveyal](https://conveyal.com/), a digital platform for accessibility analysis. 
- **Critical Destinations**: Food retailer data were filtered to remove gourmet and convenience stores and combined with other CD data. A new field was created ("opportunity"=1) and the shapefile was exported to be analyzed in Conveyal.
- **Jobs**: Data from Longitudinal Employer-Household Dynamics are embedded in Conveyal and requires no additional preparation. 
### Affordability 
This project measures affordability in two ways: housing cost change and transportation burden. Data are pulled from the [Massachusetts Association of Realtors](https://www.marealtor.com/market-data/#1611270997262-064e71dd-09e1) and from the [2019 Housing+Transportation Index](https://htaindex.cnt.org/download/data.php). 
- **Housing Cost Change**: Average sales price were calculated for the first quarter of 2016 and 2022 for single-family homes and condos per town. Percent changes between average sales prices in 2016 and 2022 were calculated for single-family homes and condos per town. An average percent change of housing was calculated across single-family and condo sales per town. These calculations were automated using R [``housingcosts_ma.R``](/analysis/housingcosts_ma.R) and values were attributed to block groups in GIS before being combined in the final index.  
- **Transportation Burden**: The field "t_80ami" or "Transportation Costs % Income for the Regional Moderate Household" was isolated from the H+T Index to represent transportation burden. 
### Environment
This project measures transportation impacts on the environment by vehicle-miles traveled (VMT). Average Annual Daily Traffic (AADT) and road length data are pulled from from the [2021 Road Inventory](https://massdot.maps.arcgis.com/home/item.html?id=342e8400ba3340c1bf5bf2b429ad8294#overview). 
- **Vehicle-Miles Traveled**: VMT is calculated per road segment by multiplying the road length (in miles) by AADT. A median VMT value is calculated for each block group.  
## Process using Conveyal
Access to jobs and destinations was calculated with Conveyal's regional analysis for a typical weekday in 2022. 
- **Origins/Destinations**: Origins used for this analysis are the center points of a rectangular grid covering the state (Conveyal's default option). Critical destinations (CDs) were uploaded to Conveyal as free form points. 
- **Network**: The network in Conveyal was updated using an OpenStreetMap extract and [2022 GTFS files](/analysis/conveyal) for the MBTA and RTAs.
- **Analysis Settings**: Access mode was car, transit modes were all, egress mode was walking, and boundary was the entire region. 

The analysis outputs were saved as .tiff files. Using half-mile buffers around each block group, the sum of CDs and mean number of jobs accessible by block group were calculated using ArcGIS's raster analysis tool "Zonal Statistics."
## Calculate Index
To build a comprehensive understanding of transportation impacts, we created a combined index using percent ranks (based on the Centers for Disease Control and Prevention Social Vulnerability Index methodology) with all five categories weighted equally. The ten indicators were merged into one table using [``TIS_compile_indicators.R``](/analysis/TIS_compile_indicators.R). 

The following steps are implemented in [``TIS_build_index.R``](/analysis/TIS_build_index.R).
1. Filter data by MPO region and calculate rank of value as a percent (0-100%) for each indicator using Excel’s percentrank.inc function
2. Invert percent rank for the five indicators representing negative impacts (crashes, roadway risk, housing cost change, transportation burden, and vehicle-miles traveled)
3. Sum indicator values for each category (e.g., add all Infrastructure percent rank values together)
4. Calculate rank of value for five categories (0-1))%) = Category Rank
5. Sum five category scores = TIS Score

## Build Dashboard
To visualize the results, we developed a Tableau dashboard hosted [here](https://public.tableau.com/app/profile/casey.auch/viz/BeyondMobilityDraft3/TISDashboard). 
