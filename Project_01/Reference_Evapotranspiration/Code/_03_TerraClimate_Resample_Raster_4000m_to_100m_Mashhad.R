
############### Information ###############

# Extract Mashhad City - Resample 4000m to 100m

############### Initial Setting ###############

rm(list = ls())

library(package = "dplyr")
library(package = "stringr")
library(package = "raster")
library(package = "sp")
library(package = "pbapply")

############### Load Data ###############

# Load Raster Data
if (exists('utils::choose.dir')) {
    data <- readRDS(file = choose.file(caption = "Select Raster File: "))
    Folder.Output <- choose.dir(caption = "Select A Folder To Save Output Files: ")
} else {
    data <- readRDS(file = tk_choose.files(caption = "Select Raster File: "))
    Folder.Output <- tk_choose.dir(caption = "Select A Folder To Save Output Files: ")
}

# Load Shapefile Mashhad
CRS.Original <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

Shapefile.Path <- tk_choose.dir(caption = "Select A Folder Contain Limit Shapefile: ")
Shapefile.Name <- "Limit"
Mashhad <- rgdal::readOGR(dsn = Shapefile.Path,
                          layer = Shapefile.Name) %>%
  sp::spTransform(CRSobj = sp::CRS(CRS.Original))

############### Crop Mashhad ###############

# Crop RasterLayer Using the Shapefile Vector Extent
data.mashhad <- pbapply::pblapply(X = data,
                                  FUN = raster::crop, y = raster::extent(x = Mashhad) + 0.2)

saveRDS(object = data.mashhad,
        file = paste0(Folder.Output, "/", "TerraClimate_Mashhad_Raster_1989_2019_4000m.rds"))

############### Resample ###############

# Load Raster Data
data.mashhad <- data

myRaster <- raster(nrows = dim(data.mashhad[[1]])[1] * 40,
                   ncols = dim(data.mashhad[[1]])[2] * 40,
                   xmn = extent(data.mashhad[[1]])[1],
                   xmx = extent(data.mashhad[[1]])[2],
                   ymn = extent(data.mashhad[[1]])[3],
                   ymx = extent(data.mashhad[[1]])[4]) # 100m


variable <- unique(x = gsub(pattern = "_.*", replacement = "", x = names(data.mashhad)))

for (var in variable) {

  result <- pbapply::pblapply(X = data.mashhad[grepl(pattern = var,
                                                     x = names(data.mashhad))],
                              FUN = raster::resample, y = myRaster, method = "bilinear")

  saveRDS(object = result,
          file = paste0(Folder.Output, "/", "TerraClimate_Mashhad_Raster_", var, "_1989_2019_100m.rds"))

}



