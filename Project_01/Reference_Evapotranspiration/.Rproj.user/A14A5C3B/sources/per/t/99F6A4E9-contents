
############### Information ###############

# Extract PET From "TerraClimate_Iran_Raster_1989_2018_100m.RDS" and
# "TerraClimate_Mashhad_Raster_1989_2018_100m.rds" Base on Shapefile.

############### Initial Setting ###############

# Remove Objects from a Specified Environment
rm(list = ls())

# Load My Functions
source("Code/func.R")

# Load Required Packages
library(package = "extrafont")
library(package = "raster")
library(package = "sp")
library(package = "rgdal")
library(package = "dplyr")
library(package = "tcltk")
library(package = "stringr")
library(package = "pbapply")
library(package = "leaflet")

# Select Folder To Save Output Files
if (exists('utils::choose.dir')) {
  Folder.Output <- choose.dir(caption = "Select A Folder To Save Output Files: ")
} else {
  Folder.Output <- tcltk::tk_choose.dir(caption = "Select A Folder To Save Output Files: ")
}

# Load PET Raster Data
DATA <- readRDS(file = "Dataset/ProcessedData/TerraClimate_Iran_Raster_1989_2018_4000m.rds")
DATA <- readRDS(file = "Dataset/ProcessedData/TerraClimate_Mashhad_Raster_1989_2018_100m.rds")

# Load Shapefile Mashhad
CRS.Original <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

Shapefile.Path <- "Dataset/ProcessedData/Mashhad_City_Layers/Limit/ShapeFile"
Shapefile.Name <- "Limit"
Mashhad <- rgdal::readOGR(dsn = Shapefile.Path,
                          layer = Shapefile.Name) %>%
  sp::spTransform(CRSobj = sp::CRS(CRS.Original))

############### Extract PET - Shapefile ###############

# Extract Values From Raster
result <- do.call(what = rbind,
                            args = pbapply::pblapply(X = DATA,
                                                     FUN = raster::extract, y = Mashhad, fun = mean, df = TRUE))

# WARNING: Change Base on Data
Data_Name <- "VALUE"
colnames(x = result)[2] <- Data_Name

# result Cleansing
result <- result %>%
  mutate(date = rownames(.)) %>%
  tidyr::separate(col = date, into = c("VARIABLE", "YEAR", "MONTH.IDs"), sep = "\\_") %>%
  tidyr::separate(col = MONTH.IDs, into = c("MONTH", "IDs"), sep = "\\.") %>%
  select(-IDs) %>%
  select(ID, VARIABLE, YEAR, MONTH, VALUE)

output.name <- paste0(Folder.Output, "/", "Extract_Raster_PET_Shapefile_Gregorian_4000m.csv")
output.name <- paste0(Folder.Output, "/", "Extract_Raster_PET_Shapefile_Gregorian_100m.csv")
write.csv(x = result, file = output.name)

# Convert Month Gregorian to Shamsi
result <- result %>%
  select(YEAR, MONTH, VALUE) %>%
  Month.Gregorian.to.Shamsi(MONTH.ABB = TRUE) %>%
  group_by(PERSIAN.YEAR, PERSIAN.MONTH) %>%
  summarise_all(sum) %>%
  rename(YEAR = PERSIAN.YEAR, MONTH = PERSIAN.MONTH)

result = result[-c(1, nrow(result)), ]

output.name <- paste0(Folder.Output, "/", "Extract_Raster_PET_Shapefile_Shamsi_4000m.csv")
output.name <- paste0(Folder.Output, "/", "Extract_Raster_PET_Shapefile_Shamsi_100m.csv")
write.csv(x = result, file = output.name)
