
## set your working directory as well as a path to store output files (dont store
## these in the Box due to the high disk space requirements)

# setwd("C:/Users/cbaehr/Box Sync")
# setwd("/Users/christianbaehr/Box Sync")

# storage_path <- "C:/Users/cbaehr/Downloads"
# storage_path <- "/Users/christianbaehr/Downloads"

if(Sys.info()[1]=="Windows") {
  memory.limit(50000)
}

library(parallel); library(sf); library(spatialEco); library(stringr)

###################

### MERGE CONCESSIONS & PLANTATIONS DATA WITH 30m GRID ###

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

rm(list = c("int_villages", "idx", "i"))

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
# write.csv(sf_grid, paste0(storage_path, "/plant_conces_data.csv"), row.names = F)

rm(list=setdiff(ls(), "storage_path"))

###################

### MERGE PID TREATMENT DATA WITH 30m GRID ###

## merging PID data with the 3km buffer villages shapefile. Will merge this 
## dataset with the empty 30m grid

## read in the buffered villages data
villages <- st_read("cambodia_eba_gie/inputData/ndvi/buffered_villages/buffered_villages.shp",
                    stringsAsFactors=F)

## convert string village codes to numeric
villages$VILL_CODE <- as.numeric(villages$VILL_CODE)

## read in PID data
pid <- read.csv("cambodia_eba_gie/processedData/pid.csv", stringsAsFactors = F)[,c("village.code", "actual.end.yr")]

## collapse PID data to the village code level. Separate multiple end dates by "|"
temp <- tapply(pid$actual.end.yr, INDEX=list(pid$village.code), 
               FUN = function(x) {paste0(x, collapse = "|")})
temp <- as.data.frame(cbind(names(temp), unname(temp)), stringsAsFactors=F)

## merge PID data with spatial data on village buffers
pid <- merge(temp, villages, by.x = "V1", by.y = "VILL_CODE")
pid <- pid[, c("V1", "V2", "geometry")]
names(pid) <- c("vill_code", "end_years", "geometry")

## convert end years data to list. Can be merged more quickly with grid data
pid$end_years <- str_split(pid$end_years, pattern = "\\|")
## convert end years list from string to integer
pid$end_years <- lapply(pid$end_years, as.integer)

## periodically remove unnecessary datasets to preserve memory
rm(list = c("temp", "villages"))

###

## merging the 30m grid with treatment data in 10 separate batches. Memory demands 
## are too high to do in one piece

for(i in 1:10) {
  ## read in 30m grid and split into 10 batches. Only retain batch i
  temp_grid <- read.csv("cambodia_eba_gie/inputData/ndvi/empty_grid.csv", stringsAsFactors = F)
  temp_grid <- split(temp_grid, sort(rep(1:10, length.out=nrow(temp_grid))))[[i]]
  
  ## convert grid to sf shape object
  list_temp_grid <- st_as_sf(temp_grid, coords = c("latitude", "longitude"), 
                             crs = "+proj=longlat +datum=WGS84 + no_defs")
  
  ## identify which PID village buffers intersect with each grid cell
  intersection <- lapply(list_temp_grid, 
                         FUN = function(x) {st_intersects(x, pid$geometry)})
  rm(list_temp_grid)
  
  ## add NA values to empty grid cells (cells that dont intersect with a buffer)
  idx <- !sapply(intersection[[1]], length)
  intersection[[1]][idx] <- NA
  ## for cells with more than one village intersection, merge to one string
  ## separated by "|"
  intersection[[1]] <- unlist(sapply(intersection[[1]], 
                                     function(x) {paste(x, collapse = "|")}))
  
  ## the three lines below are intended to convert the "intersection" object
  ## from class "sgbp" to a generic "list" object
  intersection <- unlist(intersection)
  intersection <- str_split(intersection, pattern = "\\|")
  intersection <- lapply(intersection, as.integer)
  
  ## pull the end dates for the PID projects intersecting with each each grid cell
  end_years <- lapply(intersection, FUN = function(x) {pid$end_years[x]})
  rm(list = c("intersection", "idx"))
  
  ## the below code takes the integer vector of PID end dates for each grid cell and 
  ## converts it to a running count of projects completed from 2003-18. First 
  ## convert the integer vector to a factor with levels of 2003-18, then create a 
  ## table counting the occurences of each level in the vector, then take the 
  ## cumulative sum of that table
  end_years <- sapply(end_years, function(x) {cumsum(table(factor(unlist(x), levels = c(2003:2018))))})
  ## transpose the "end_years" matrix so columns are years
  end_years <- t(end_years)
  
  ## build matrix of zeroes representing the # of completed projects in each cell from 
  ## 1999-2002 (no projects were completed before 03)
  add_grid <- matrix(data = 0, nrow = nrow(end_years), ncol = 4)
  colnames(add_grid) <- as.character(1999:2002)
  
  ## merge 1999-2002 matrix with 2003-18 matrix
  end_years <- cbind(add_grid, end_years)
  ## merge grid coordinates with treatment matrix
  end_years <- cbind(temp_grid, end_years)
  
  ## save the matrix batch with unique filename. Will merge matrices together after
  save(end_years, file = paste0(storage_path, "/treatment", i, ".RData"))
  
  rm(list = c("end_years", "temp_grid", "add_grid"))

}

###

## merging the treatment matrix batches

## add skeleton matrix to merge treatment matrices into
treatment <- matrix(nrow = 0, ncol = 22)

for(i in 1:10) {
  
  ## load in treatment matrix i
  load(paste0(storage_path, "/treatment", i, ".RData"))
  
  ## bind treatment matrix i with existing master treatment matrix
  treatment <- rbind(treatment, end_years)
  
  rm(end_years)
  
  # file.remove(paste0(storage_path, "/treatment", i, ".RData"))
  
}

## write full treatment grid
write.csv(treatment, paste0(storage_path, "/cambodia_treatment.csv"), row.names = F)

###################

### MERGE ADMINISTRATIVE BOUNDARIES DATA WITH 30m GRID ###

## read in Cambodia ADM1 data
provinces <- st_read("cambodia_eba_gie/inputData/KHM_ADM1/KHM_ADM1.shp")[, c("geometry", "id")]

## read in Cambodia ADM3 data
communes <- st_read("cambodia_eba_gie/inputData/KHM_ADM3/KHM_ADM3.shp")[, c("geometry", "id")]

for(i in 1:10) {
  ## read in 30m grid and split into 10 batches. Only retain batch i
  temp_grid <- read.csv("cambodia_eba_gie/inputData/ndvi/empty_grid.csv", stringsAsFactors = F)
  temp_grid <- split(temp_grid, sort(rep(1:10, length.out=nrow(temp_grid))))[[i]]
  
  ## convert grid to sf shape object
  list_temp_grid <- st_as_sf(temp_grid, coords = c("latitude", "longitude"), 
                             crs = "+proj=longlat +datum=WGS84 + no_defs")
  
  ## doing a spatial merge of the 30m grid and the ADM1 province information
  list_temp_grid <- point.in.poly(list_temp_grid, provinces)
  list_temp_grid <- list_temp_grid[!duplicated(list_temp_grid@coords), ]
  
  ## spatial merge of the 30m grid and the ADM1 province information
  list_temp_grid <- point.in.poly(list_temp_grid, communes)
  list_temp_grid <- list_temp_grid[!duplicated(list_temp_grid@coords), ]
  
  list_temp_grid <- as.data.frame(list_temp_grid)[, c("coords.x1", "coords.x2", "id.x", "id.y")]
  names(list_temp_grid) <- c("lat", "lon", "prov_id", "comm_id")
  
  ## save each chunk in a temporary file to be merged later
  save(list_temp_grid, file = paste0(storage_path, "/adm_grid", i, ".RData"))
  
  rm(list = c("temp_grid", "list_temp_grid"))
  
}

###

adm <- matrix(nrow = 0, ncol = 4)

for(i in 1:10) {
  
  ## load in treatment matrix i
  load(paste0(storage_path, "/adm_grid", i, ".RData"))
  
  ## bind treatment matrix i with existing master treatment matrix
  adm <- rbind(adm, list_temp_grid)
  
  rm(list_temp_grid)
  
  # file.remove(paste0(storage_path, "/adm_grid", i, ".RData"))
  print(i)
}

write.csv(adm, file = paste0(storage_path, "/adm_data.csv"), row.names = F)

###################

## merge the grids using the `merge_grid_data.py` python file

