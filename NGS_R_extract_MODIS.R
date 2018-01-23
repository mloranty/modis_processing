##########################
#
# extract MODIS variables 
# for PCN NGS Resp sites
#
# MML 11/23/16
##########################

require(xlsx)
require(MODISTools)


rm(list=ls())
setwd("/Users/mloranty/Google Drive/GIS_projects/PCN_NGS_respiration/")

###############################
# read in the data file - new FINAL file updated from SMN 04/01/17
# note this is manually cleaned up and converted to csv
#ngs.sites <- read.csv('NGS_R_CO2_data_11.2016.csv',header=T,colClasses = 'numeric')
ngs.sites <- read.csv("CO2_coords_FINAL.csv",header=T)
# get rid of redundant coords
ngs.sites <- unique(ngs.sites)
# get rid of NA values
ngs.sites <- na.omit(ngs.sites)

# correct colnames
colnames(ngs.sites) <- c('long','lat')
# specify start and end dates
ngs.sites$start.date <- 2000
ngs.sites$end.date <- 2014
# use original row number as site ID. 
ngs.sites$ID <- as.numeric(row.names(ngs.sites))

## need to update for just a few sites
ngs.sites <- ngs.sites[c(12,101,106,69),]
###############################

# make file to extract vegetation indices
# for each year from 2000 - 2016

ngs.veg <- data.frame(rep(ngs.sites$lat,each=17))
colnames(ngs.veg) <- c('lat')
ngs.veg$long <- rep(ngs.sites$long,each=17)
ngs.veg$start.date <- as.POSIXct(paste(rep(2000:2016,nrow(ngs.sites)),'06-01',sep='-'),format="%Y-%m-%d",usetz=FALSE)
ngs.veg$end.date <- as.POSIXct(paste(rep(2000:2016,nrow(ngs.sites)),'08-31',sep='-'),format="%Y-%m-%d",usetz=FALSE)
ngs.veg$ID <- paste("NGS",rep(1:nrow(ngs.sites),each=17),rep(2000:2016,nrow(ngs.sites)),sep='_')  

ngs.veg.all <- ngs.veg
ngs.veg <- ngs.veg.all[52:68,]
################################################
# get growing season VI data and summarize 
# by year for each site 
################################################
t <- ngs.veg[1:5,]

## this gets the subset from ornl daac website
MODISSubsets(LoadDat = ngs.veg, Products = "MOD13Q1", SaveDir='modis_asc',
             Bands = c("250m_16_days_NDVI","250m_16_days_EVI","250m_16_days_pixel_reliability"),
             Size = c(0,0), StartDate = TRUE)

## this generates summaries for each timeseries
MODISSummaries(LoadDat = ngs.veg, Product = "MOD13Q1", Dir='modis_asc',
               Bands = "250m_16_days_EVI",
               ValidRange = c(-2000,10000), NoDataFill = -3000, ScaleFactor = 0.0001,
               StartDate = TRUE, QualityScreen = TRUE, QualityThreshold = 1,DiagnosticPlot = T,
               QualityBand = "250m_16_days_pixel_reliability",Interpolate=T)

MODISSummaries(LoadDat = ngs.veg, Product = "MOD13Q1", Dir='modis_asc',
               Bands = "250m_16_days_NDVI",
               ValidRange = c(-2000,10000), NoDataFill = -3000, ScaleFactor = 0.0001,
               StartDate = TRUE, QualityScreen = TRUE, QualityThreshold = 1,
               QualityBand = "250m_16_days_pixel_reliability",Interpolate=T)

############################
############################
## OLD JUNK CODE AND SUCH ##
############################
############################

############################################################
############################################################
## this will pull downloaded files in as either a matrix or a list
ts <- MODISTimeSeries(Dir = ".", Band = "250m_16_days_EVI", Simplify = TRUE)

#### creat data frame for MODIS extraction
mod.subset <- data.frame(lat = ngs.site$Lat..N,long = ngs.site$Long..E)

## look at list of available products
GetProducts()




## note the MOD17A3 version of NPP/GPP is an improved version produced by NTSG
## the accounts for cloud contaminated LAI/FPAR data
## we'll use MOD17A3 becuase of the improvements and because it easier to use
# GetBands(Product="MOD17A2_51")
# GetDates(Product="MOD17A2_51",Lat=mod.subset$lat[1], mod.subset$lon[1])

GetBands(Product="MOD17A3")
GetDates(Product="MOD17A3",Lat=mod.subset$lat[1], mod.subset$lon[1])

mod.subset$start.date <- 2000
mod.subset$end.date <- 2014

mod.test <- mod.subset[1:2,]
MODISSubsets(LoadDat = mod.test, Products = "MOD17A3", StartDate = T,
             Bands = c("Gpp_1km","Npp_1km","Gpp_Npp_QC_1km"),
             Size=c(0,0))

MODISSummaries(LoadDat = mod.test, Product = "MOD17A3", Bands = c("Gpp_1km","Npp_1km"),
               ValidRange = c(0,65500),NoDataFill = 65530,ScaleFactor=0.0001)


## get MODIS LAI data 
## note this is produced for the 2000-2016 period

mod.subset$end.date <- 2015

GetBands(Product="MOD15A2")
GetDates(Product="MOD15A2",Lat=mod.subset$lat[1], mod.subset$lon[1])







