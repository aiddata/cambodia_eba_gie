
setwd("/Users/christianbaehr/Box Sync")


library(parallel); library(sf)

## read in plantation/concession data and merge with SEA grid
pa_2000 <- read.csv("MacArthur_Winter2019/ProtectedAreas_Data/merge_sea_grid_pre2001.csv", stringsAsFactors = F)
con <- read.csv("MacArthur_Winter2019/ODCConcessions/merge_sea_grid.csv", stringsAsFactors = F)
pc_data <- merge(pa_2000, con, by="ID")

extract<-read.csv("MacArthur_Winter2019/extracts/sea.csv", stringsAsFactors = F)[, c("ID", "NAME_0")]

pc_data <- merge(pc_data, extract, by="ID")
pc_data <- pc_data[extract$NAME_0=="Cambodia",]

cells <- st_read("MacArthur_Winter2019/grids/sea_grid.shp")
cells <- merge(cells, pc_data, by="ID")

###

## due to large memory requirements, regularly clear unnecessary objects from environment
rm(list=setdiff(ls(), "cells"))

## read in empty 30x30 Cambodia grid
sf_grid <- read.csv("cambodia_eba_gie/inputData/ndvi/empty_grid.csv",
                    stringsAsFactors = F)

## split grid into list of 10 sepatate pieces
list_sf_grid <- split(sf_grid, sort(rep(1:10, length.out=nrow(sf_grid))))

rm(sf_grid)

## convert Cambodia grid pieces to *sf* list
list_sf_grid <- lapply(list_sf_grid, FUN = function(x) {st_as_sf(x, coords = c("latitude", "longitude"), crs="+proj=longlat +datum=WGS84 +no_defs")})

## identify which plantation/concession cells intersect with 30m cells
int_villages <- mclapply(list_sf_grid, FUN = function(x) {st_intersects(x, cells$geometry)})

rm(list_sf_grid)

## replace empty values (indicating no intersection of cells) with NA values
for(i in 1:length(int_villages)) {
  idx <- !(sapply(int_villages[[i]], length))
  int_villages[[i]][idx] <- NA
}

## convert index from list to integer
index <- unlist(do.call(c, int_villages))

rm(int_villages); rm(idx); rm(i)

## retrieve the plantation/concession cell that intersects with each 30m cell
cells <- cells[index, ]
## remove geometry from cells dataset. This will be merged with the 30m data and that geometry
## will be used instead
cells <- as.data.frame(cells)
cells <- cells[names(cells) != "geometry"]

rm(index)

## merge empty grid data with plantation/concession data
sf_grid <- read.csv("cambodia_eba_gie/inputData/ndvi/empty_grid.csv", stringsAsFactors = F)
sf_grid <- cbind.data.frame(sf_grid, cells)
rm(cells)
## not saving this file to the Box Sync because it is so large. Instead stored in Christians Sciclone account
# write.csv(sf_grid, "/Users/christianbaehr/Downloads/plant_conces_data.csv", row.names = F)





