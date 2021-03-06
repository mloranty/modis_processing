############################
#
# extract MODIS veg data
# for winter respiration 
# synthesis
# 
# MML 01/15/18
############################
rm(list=ls())
setwd('/Users/mloranty/Google Drive/Documents/Research/NSFBorealFireCherskii_2014-17/analyses/dg_modis_extract/')
require(MODISTools)
require(XML)
## read in the site coordinates ##
dg.sites <- read.csv(file='dg_site_coords.csv',
                     header=T,
                     colClasses = c('character','numeric','numeric'))

# specify start and end dates
dg.sites$start.date <- 2000
dg.sites$end.date <- 2017

# make data frame to extract annual growing season
# veg indices for each site
 
dg.veg <- data.frame(rep(dg.sites$lat,each=18))
colnames(dg.veg) <- c('lat')
dg.veg$long <- rep(dg.sites$long,each=18)
dg.veg$start.date <- as.POSIXct(paste(rep(2000:2017,nrow(dg.sites)),'06-01',sep='-'),format="%Y-%m-%d",usetz=FALSE)
dg.veg$end.date <- as.POSIXct(paste(rep(2000:2017,nrow(dg.sites)),'08-31',sep='-'),format="%Y-%m-%d",usetz=FALSE)
dg.veg$ID <- paste(rep(dg.sites$site,each=18),rep(2000:2017,nrow(dg.sites)),sep='-')                 

################################################
# get growing season VI data and summarize 
# by year for each site 
################################################

## this gets the subset from ornl daac website
MODISSubsets(LoadDat = dg.veg, Products = "MOD13Q1", SaveDir='modis_asc',
             Bands = c("250m_16_days_NDVI","250m_16_days_EVI","250m_16_days_pixel_reliability"),
             Size = c(0,0), StartDate = TRUE)

## this generates summaries for each timeseries
MODISSummaries(LoadDat = dg.veg, Product = "MOD13Q1", Dir='modis_asc',
               Bands = "250m_16_days_EVI",
               ValidRange = c(-2000,10000), NoDataFill = -3000, ScaleFactor = 0.0001,
               StartDate = TRUE, QualityScreen = TRUE, QualityThreshold = 1,DiagnosticPlot = T,
               QualityBand = "250m_16_days_pixel_reliability",Interpolate=T)

MODISSummaries(LoadDat = dg.veg, Product = "MOD13Q1", Dir='modis_asc',
               Bands = "250m_16_days_NDVI",
               ValidRange = c(-2000,10000), NoDataFill = -3000, ScaleFactor = 0.0001,
               StartDate = TRUE, QualityScreen = TRUE, QualityThreshold = 1,
               QualityBand = "250m_16_days_pixel_reliability",Interpolate=T)



####################################################
# get the MODIS GPP/NPP data with cloud correction #
 
MODISSubsets(LoadDat = test, Products = "MOD17A3",StartDate=TRUE, 
              Bands = c("Gpp_1km","Npp_1km","Gpp_Npp_QC_1km"),
              Size = c(0,0))
 
MODISSummaries(LoadDat = test, Product = "MOD17A3",
               Bands = c("Gpp_1km","Npp_1km"),
               ValidRange = c(0,65500), NoDataFill = 65530, ScaleFactor = 0.0001,
               StartDate = TRUE)
####################################################

GetProducts()
GetBands('MOD13Q1')
GetDates(Lat=64.7227, Long = 161.3508, Product='MOD13Q1')

## this gets the subset from ornl daac website
MODISSubsets(LoadDat = SubsetExample, Products = "MOD13Q1", 
             Bands = c("250m_16_days_NDVI","250m_16_days_EVI","250m_16_days_pixel_reliability"),
             Size = c(0,0), StartDate = TRUE)

## this generates summaries for each timeseries
MODISSummaries(LoadDat = SubsetExample, Product = "MOD13Q1",
               Bands = c("250m_16_days_EVI","250m_16_days_NDVI"),
               ValidRange = c(-2000,10000), NoDataFill = -3000, ScaleFactor = 0.0001,
               StartDate = TRUE, QualityScreen = TRUE, QualityThreshold = 0,
               QualityBand = "250m_16_days_pixel_reliability")

## this will pull downloaded files in as either a matrix or a list
ts <- MODISTimeSeries(Dir = ".", Band = "250m_16_days_EVI", Simplify = TRUE)
