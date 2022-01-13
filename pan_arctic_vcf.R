#####################################
#
# use the luna and terra packages 
# to download and moasic MODIS vcf
#
# MML 01/11/22
#####################################

library(terra)
library(luna)
library(raster)

#read text file with NASA EOSDIS login
pw <- read.csv("C:/Users/mloranty/Desktop/earthdata.csv", header = T)

#set working directory
setwd("L:/data_repo/gis_data/MODIS/MOD44B/")

# download MODIS VCF data 
getModis(product = "MOD44B",
         version = "061",
         start_date = "2009-01-01",
         end_date = "2009-12-31",
         aoi = c(-180,180,45,80),
         download = T,
         path = "MODIS/MOD44B/MOD44B_061_2009/",
         username = pw$un,
         password = pw$pw)

# list all MODIS files
f <- list.files(path = "MOD44B_061_2009/", full.names = T)

# create a list of filenames
f2 <- as.list(f)

# read all rasters in the list
f3 <- lapply(f2,rast)

# subset to include only the first layer (percent tree cover)
f4 <- lapply(f3, subset, 1)

# create a SpatRaster collection
d <- src(f4)

#merge them all into a large mosaic
m <- merge(d, filename = "MOD44B.A2009065.006.boreal.tif", overwrite = T,
           tempdir = "D:/Rtemp/",
           todisk = T,
           memfrac = 0.8,
           progress = 10,
           datatype = "INT1U")

#do.call, merge, list
# mosaic all of these files, one by one
for (i in 2:length(f))
{
  
  t2 <- rast(f[i])
  
  t <- merge(t$`MOD44B_250m_GRID:Percent_Tree_Cover`,t2$`MOD44B_250m_GRID:Percent_Tree_Cover`,
             filename = "MOD44B.A2009065.006.boreal.tif", overwrite = T, todisk = T)
}


t3 <- project(t[[1]],"epsg:6931", method = "near")
