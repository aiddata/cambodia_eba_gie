
# designate the activity type for subsetting the PID data here. The string you pass to the activity.type object must
# match with one of the values of the activity type variable in the PID data
# for the output.file.name variable, input the desired name of the .csv file containing the heterogeneous effects panel dataset
activity.type <- c("Rural Domestic Water Supplies")
output.file.name <- "panel_rural-domestic-water_only"

# once the correct activity type and output file names have been assigned, you can run the rest of the script

###################

setwd("~/box sync/cambodia_eba_gie")

library(plyr)
library(dplyr)
library(readxl)
library(sf)
library(stringr)
library(sp)
library(spatialEco)

pid <- read.csv("ProcessedData/pid.csv", stringsAsFactors = F)
pre.treatment <- pid[which(pid$activity.type %in% activity.type),]

# reading in and merging data from the GeoQuery extract
grid_1000_matched_data <- read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv", stringsAsFactors = F)
merge_grid_1000_lite <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv", stringsAsFactors = F)
grid_1000_matched_data <- merge(grid_1000_matched_data, merge_grid_1000_lite, by = "cell_id")
grid_1000_matched_data <- grid_1000_matched_data[,-c(7:49, 72:221)]

#merging PID data with GeoQuery extract
id.list <- list()
id.list2 <- list()
for(i in 1:nrow(grid_1000_matched_data)) {
  point <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_point_ids[i], split = "\\|"))))
  box <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_box_ids[i], split = "\\|"))))
  if(grid_1000_matched_data$village_point_ids[i]=="") {id.list[[i]] <- ""} 
  else {id.list[[i]] <- point}
  if(grid_1000_matched_data$village_box_ids[i]=="") {id.list2[[i]] <- ""} 
  else {
    if(length(setdiff(box, point)) > 0) {id.list2[[i]] <- setdiff(box, point)} 
    else {id.list2[[i]] <- ""}}}

panel.names <- c("village.code", "village.name", "province.name", "district.name", "commune.name", 
                 as.vector(outer(c("box", "point"), c("earliest.end.date", "enddate.type", "earliest.sector.num", "earliest.sector", 
                                                      paste0("count", 1992:2017)), paste, sep=".")), names(grid_1000_matched_data))

pre.panel <- as.data.frame(matrix(NA, nrow = nrow(grid_1000_matched_data), ncol = length(panel.names)))
names(pre.panel) <- panel.names

treatment <- as.data.frame(matrix(NA, nrow = 1, ncol = 24))[0,]
names(treatment) <- c("village.code", "village.name", "province.name", "district.name", "commune.name", "earliest.end.date", 
                      "enddate.type", "earliest.sector.num", "earliest.sector", paste0("count", 2003:2017))

for(i in 1:length(unique(pre.treatment$village.code))) {
  temp <- pre.treatment[which(pre.treatment$village.code==unique(pre.treatment$village.code)[i]),]
  row <- nrow(treatment)+1
  treatment[row, c("village.code", "village.name", "province.name", "district.name", "commune.name", "earliest.end.date", 
                   "enddate.type", "earliest.sector.num", "earliest.sector")] <- c(temp$village.code[1],
                                                                                   temp$village.name[1],
                                                                                   temp$province.name[1],
                                                                                   temp$district.name[1],
                                                                                   temp$commune.name[1],
                                                                                   temp$actual.end.yr[which.min(temp$actual.end.yr)],
                                                                                   temp$enddate.type[which.min(temp$actual.end.yr)],
                                                                                   temp$activity.type.num[which.min(temp$actual.end.yr)],
                                                                                   temp$activity.type[which.min(temp$actual.end.yr)])
  for(j in sort(unique(pre.treatment$actual.end.yr))) {
    treatment[row, grep(paste0("count", j), names(treatment))] <- nrow(temp[temp$actual.end.yr==j,])}}

###

polygons <- readRDS("inputdata/gadm36_KHM_4_sp.rds")
shape <- as.data.frame(read.csv("inputdata/village_grid_files/village_data.csv", stringsAsFactors = F))
spatial.data <- SpatialPointsDataFrame(coords = shape[,c("longitude", "latitude")], data = shape, 
                                       proj4string = CRS("+proj=longlat +datum=WGS84"))
shape <- as.data.frame(point.in.poly(x=spatial.data, y=polygons))[,c("VILL_CODE", "VILL_NAME", "NAME_1", "NAME_2", "NAME_3")]
names(shape) <- c("village.code", "village.name", "province.name", "district.name", "commune.name")

###

for(i in 1:length(unique(grid_1000_matched_data$cell_id))) {
  temp.point <- treatment[which(treatment$village.code %in% as.character(id.list[[i]])),]
  temp.box <- treatment[which(treatment$village.code %in% as.character(id.list2[[i]])),]
  if(nrow(temp.point) > 0) {
    pre.panel[i, "village.code"] <- temp.point$village.code[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "village.name"] <- temp.point$village.name[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "province.name"] <- temp.point$province.name[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "district.name"] <- temp.point$district.name[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "commune.name"] <- temp.point$commune.name[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "point.earliest.end.date"] <- temp.point$earliest.end.date[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "point.enddate.type"] <- temp.point$enddate.type[which.min(temp.point$enddate.type)]
    pre.panel[i, "point.earliest.sector.num"] <- temp.point$earliest.sector.num[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "point.earliest.sector"] <- temp.point$earliest.sector[which.min(temp.point$earliest.end.date)]
    for(j in sort(unique(treatment$earliest.end.date))) {
      pre.panel[i, grep(paste0("point.count", j), (names(pre.panel)))] <- 
        as.data.frame(temp.point[, paste0("count", c(2003:2017)[2003:2017<=j])]) %>%
        apply(., 2, sum, na.rm=T) %>%
        sum()}}
  if(nrow(temp.box) > 0) {
    pre.panel[i, "village.code"] <- temp.box$village.code[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "village.name"] <- temp.box$village.name[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "province.name"] <- temp.box$province.name[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "district.name"] <- temp.box$district.name[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "commune.name"] <- temp.box$commune.name[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "box.earliest.end.date"] <- temp.box$earliest.end.date[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "box.enddate.type"] <- temp.box$enddate.type[which.min(temp.box$enddate.type)]
    pre.panel[i, "box.earliest.sector.num"] <- temp.box$earliest.sector.num[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "box.earliest.sector"] <- temp.box$earliest.sector[which.min(temp.box$earliest.end.date)]
    for(j in sort(unique(treatment$earliest.end.date))) {
      pre.panel[i, grep(paste0("box.count", j), (names(pre.panel)))] <- 
        as.data.frame(temp.box[, paste0("count", c(2003:2017)[2003:2017<=j])]) %>%
        apply(., 2, sum, na.rm=T) %>%
        sum()}}
  pre.panel[i, which(names(pre.panel) %in% names(grid_1000_matched_data))] <- grid_1000_matched_data[i,]
  if(is.na(pre.panel$village.code[i])) {
    villages <- c(id.list[[i]], id.list2[[i]]) %>% .[!.==""]
    temp <- shape[shape$village.code==villages[1],]
    if(nrow(temp)>0) {
      pre.panel[i, "village.code"] <- temp$village.code
      pre.panel[i, "village.name"] <- temp$village.name
      pre.panel[i, "province.name"] <- temp$province.name
      pre.panel[i, "district.name"] <- temp$district.name
      pre.panel[i, "commune.name"] <- temp$commune.name}}
  if(i %% 1000 == 0){cat(i, "of", nrow(grid_1000_matched_data), "\n")}}
for(i in grep("count", names(pre.panel))) {pre.panel[which(is.na(pre.panel[,i])), i] <- 0}

pre.panel$unique.commune.name <- paste(pre.panel$province.name, pre.panel$district.name, pre.panel$commune.name)

names(pre.panel) <- gsub("v4composites_calibrated_201709.", "ntl_", names(pre.panel)) %>% gsub(".mean", "", .)

panel <- reshape(data = pre.panel, direction = "long", varying = list(paste0("ntl_", 1992:2013), 
                                                                      paste0("point.count", 1992:2013),
                                                                      paste0("box.count", 1992:2013)),
                 idvar = "panel_id", sep = "_", timevar = "year")

names(panel)[names(panel)=="village.code"] <- "village_code"
names(panel)[names(panel)=="village.name"] <- "village_name"
names(panel)[names(panel)=="province.name"] <- "province_name"
names(panel)[names(panel)=="district.name"] <- "district_name"
names(panel)[names(panel)=="commune.name"] <- "commune_name"
names(panel)[names(panel)=="box.earliest.end.date"] <- "border_cell_earliest_enddate"
names(panel)[names(panel)=="point.earliest.end.date"] <- "intra_cell_earliest_enddate"
names(panel)[names(panel)=="box.enddate.type"] <- "border_cell_enddate_type"
names(panel)[names(panel)=="point.enddate.type"] <- "intra_cell_enddate_type"
names(panel)[names(panel)=="box.earliest.sector.num"] <- "border_cell_earliest_sector_num"
names(panel)[names(panel)=="point.earliest.sector.num"] <- "intra_cell_earliest_sector_num"
names(panel)[names(panel)=="box.earliest.sector"] <- "border_cell_earliest_sector"
names(panel)[names(panel)=="point.earliest.sector"] <- "intra_cell_earliest_sector"
names(panel)[names(panel)=="unique.commune.name"] <- "unique_commune_name"
names(panel)[names(panel)=="ntl_1992"] <- "ntl"
names(panel)[names(panel)=="point.count1992"] <- "intra_cell_count"
names(panel)[names(panel)=="box.count1992"] <- "border_cell_count"
names(panel)[names(panel)=="ntl_1992_uncalibrated"] <- "ntl_uncalibrated"

panel <- panel[, !(names(panel) %in% c(paste0("point.count", 2014:2017), paste0("box.count", 2014:2017), "dist_to_water.na", 
                                       "dist_to_groads.na", "id", "panel_id", "village_box_ids", "village_point_ids"))]

write.csv(panel, paste0("ProcessedData/heterogeneous_effects/", output.file.name,".csv"), row.names=F)

