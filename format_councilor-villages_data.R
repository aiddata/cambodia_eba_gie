
setwd("/Users/christianbaehr/Box Sync/cambodia_eba_gie")

library(readxl)
library(plyr)
library(sp)
library(spatialEco)

temp_list <- list()
for(i in dir("inputData/councilors-villages_data/2003")) {
  temp_data <- as.data.frame(read_xlsx(paste0("inputData/councilors-villages_data/2003/", i), col_names = F))

  names(temp_data) <- c("comm_code", "comm_name", "n_councilors_03", "categoryA", "categoryB", "admin_funds_03", "dev_funds_03", "total_funds_03")  
  temp_list[[gsub("pg_|.xlsx", "", i)]] <- temp_data
}
communes_2003 <- do.call("rbind", temp_list)

communes_2003 <- communes_2003[!is.na(communes_2003$admin_funds_03),]
communes_2003 <- communes_2003[!is.na(communes_2003$comm_code),]
communes_2003 <- communes_2003[!is.na(communes_2003$comm_name),]

communes_2003$comm_code <- gsub(" ", "", communes_2003$comm_code)
communes_2003$comm_code <- gsub("\\I", "1", communes_2003$comm_code)

communes_2003$n_councilors_03 <- gsub("II|l l|I I|1 I", "11", communes_2003$n_councilors_03)

communes_2003$categoryA <- gsub("0", NA, communes_2003$categoryA)
communes_2003$categoryA <- ifelse(is.na(communes_2003$categoryA), NA, "1A")
communes_2003$categoryB <- ifelse(is.na(communes_2003$categoryB), NA, "1B")

communes_2003$admin_funds_03 <- gsub(",| |\\.", "", communes_2003$admin_funds_03)
communes_2003$dev_funds_03 <- gsub(",| |\\.", "", communes_2003$dev_funds_03)
communes_2003$dev_funds_03 <- gsub("I", "1", communes_2003$dev_funds_03)
communes_2003$total_funds_03 <- gsub(",| |\\.", "", communes_2003$total_funds_03)
communes_2003$total_funds_03 <- gsub("I", "1", communes_2003$total_funds_03)

communes_2003$n_councilors_03 <- as.numeric(communes_2003$n_councilors_03)

communes_2003$admin_funds_03 <- as.numeric(communes_2003$admin_funds_03)
communes_2003$dev_funds_03 <- as.numeric(communes_2003$dev_funds_03)
communes_2003$total_funds_03 <- as.numeric(communes_2003$total_funds_03)

###################

temp_list <- list()
for(i in dir("inputData/councilors-villages_data/2004")) {
  temp_data <- as.data.frame(read_xlsx(paste0("inputData/councilors-villages_data/2004/", i), col_names = F))
  names(temp_data) <- c("comm_code", "comm_name", "n_councilors_04", "n_villages", "admin_funds_04", "dev_funds_04", "total_funds_04")
  
  temp_list[[gsub("pg_|.xlsx", "", i)]] <- temp_data
}
communes_2004 <- do.call("rbind", temp_list)






y <- y[(y$`2`!="Sub-total" & y$`2`!="Total:" & y$`2`!="Total") | is.na(y$`2`),]


boundaries <- readRDS("inputdata/gadm36_KHM_4_sp.rds")
shape <- as.data.frame(read.csv("inputdata/village_grid_files/village_data.csv", stringsAsFactors = F))
village_points <- SpatialPointsDataFrame(coords = shape[,c("longitude", "latitude")], data = shape, proj4string = CRS("+proj=longlat +datum=WGS84"))
shape <- as.data.frame(point.in.poly(x=village_points, y=boundaries))[,c("VILL_CODE", "VILL_NAME", "NAME_1", "NAME_2", "NAME_3")]
names(shape) <- c("vill_code", "vill_name", "prov_name", "dist_name", "comm_name")

temp_shape <- NULL
for(i in 1:nrow(shape)) {
  if(nchar(shape$vill_code[i])==7) {
    temp_shape[i] <- paste(unlist(strsplit(as.character(as.numeric(shape$vill_code[i])), ""))[1:5],collapse = "")
  } else {
    temp_shape[i] <- paste(unlist(strsplit(as.character(as.numeric(shape$vill_code[i])), ""))[1:6],collapse = "")
  }
}
temp_shape2 <- unique(temp_shape)
sum(y$`1` %in% temp_shape2)

###################












