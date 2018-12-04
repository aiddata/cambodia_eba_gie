# multi-village projects make up ~20% of all PID projects
setwd("~/box sync/cambodia_eba_gie")

library(plyr)
library(dplyr)
library(readxl)
library(sf)
library(stringr)
library(sp)
library(spatialEco)
library(rlist)

# the commented out code merges the three PID datasets and assigns a common Activity Type index to the PID data
# it then writes out a complete PID dataset that can be read in instead of re-running this code each time

pid2008 <- read.csv("PID/completed_pid/pid_2008.csv", stringsAsFactors = F)
pid2012 <- read.csv("PID/completed_pid/pid_2012.csv", stringsAsFactors = F)
pid2016 <- read.csv("PID/completed_pid/pid_2016.csv", stringsAsFactors = F)
test2008 <- NULL
for(i in unique(pid2008$vill.id)) {
  temp <- pid2008[pid2008$vill.id==i,]
  if(length(unique(temp$project.id))!=1) {test2008[length(test2008)+1] <- T} 
  else {test2008[length(test2008)+1] <- F}}
pid2008.sub <- pid2008[which(test2008),]
test2012 <- NULL
for(i in unique(pid2012$vill.id)) {
  temp <- pid2012[pid2012$vill.id==i,]
  if(length(unique(temp$project.id))!=1) {test2012[length(test2012)+1] <- T} 
  else {test2012[length(test2012)+1] <- F}}
pid2012.sub <- pid2012[which(test2012),]
test2016 <- NULL
for(i in unique(pid2016$vill.id)) {
  temp <- pid2016[pid2016$vill.id==i,]
  if(length(unique(temp$project.id))!=1) {test2016[length(test2016)+1] <- T} 
  else {test2016[length(test2016)+1] <- F}}
pid2016.sub <- pid2016[which(test2016),]

pid <- rbind.fill(pid2016.sub, pid2012.sub, pid2008.sub)
# multi-village projects make up ~20% of all PID projects

common.index <- as.data.frame(matrix(data = NA, nrow = 21, ncol = 0))
common.index[1:17,"2008"] <- sort(unique(pid2008$activity.type))
common.index[1:17,"2012"] <- sort(unique(pid2012$activity.type))[match(common.index[1:17,"2008"],
                                                                       sort(unique(pid2012$activity.type)))]
common.index[1:17,"2016"] <- sort(unique(pid2016$activity.type))[match(common.index[1:17,"2008"],
                                                                       sort(unique(pid2016$activity.type)))]
common.index[18:21, "2012"] <- unique(pid2012$activity.type)[!(unique(pid2012$activity.type) %in% common.index[1:17,"2012"])]
common.index[18:21, "2016"] <- unique(pid2016$activity.type)[match(common.index[18:21, "2012"], unique(pid2016$activity.type))]
common.index[,"type"] <- c(common.index[1:17,"2008"], common.index[18:21, "2012"])
common.index[,"id"] <- seq(1, 21, 1)

pid <- merge(pid[,!(names(pid)=="activity.type.num")], common.index[,c("type", "id")], by.x = "activity.type", by.y = "type")
names(pid)[names(pid)=="id"] <- "activity.type.num"

# reading in complete PID data
pid <- pid[pid$actual.end.yr!=1908 | is.na(pid$actual.end.yr),]

polygons <- readRDS("inputdata/gadm36_KHM_4_sp.rds")
shape <- as.data.frame(read.csv("inputdata/village_grid_files/village_data.csv", stringsAsFactors = F))
spatial.data <- SpatialPointsDataFrame(coords = shape[,c("longitude", "latitude")], data = shape, 
                                       proj4string = CRS("+proj=longlat +datum=WGS84"))
shape <- as.data.frame(point.in.poly(x=spatial.data, y=polygons))[,c("VILL_CODE", "VILL_NAME", "NAME_1", "NAME_2", "NAME_3")]
names(shape) <- c("village.code", "village.name", "province.name", "district.name", "commune.name")

# merging PID data with shape data based on Village ID
pid <- merge(shape, pid, by.x = "village.code", by.y = "vill.id", all.y = T)
# generating a variable that contains the length of each PID project
pid$project.length <- (((pid$actual.end.yr-pid$actual.start.yr)*12)+(pid$actual.end.mo-pid$actual.start.mo))

# some PID projects are missing an actual end date value. To avoid losing data, actual end date is estimated by determining the average
# project length of other projects in the same year and in the same province and treating that as the expected length of the project. This
# expected length, assuming we have an actual start date value, allows us to estimate the end date of the project.
pid$enddate.type <- NA
for(i in 1:nrow(pid)) {
  if(is.na(pid$actual.end.yr[i])) {
    if(is.na(pid$actual.start.yr[i])) {
      # determining the mean project length for projects in the the same province and year as i
      avg.length <- mean(pid$project.length[which(pid$planned.start.yr==pid$planned.start.yr[i] & pid$province.name==pid$province.name[i])], na.rm = T)
      # for cases where the actual start date is missing, we use the planned start date as the reference point
      # for estimating actual end date
      pid$actual.end.yr[i] <- pid$planned.start.yr[i] + floor((pid$planned.start.mo[i]+avg.length)/12)
      pid$actual.end.mo[i] <- round(((pid$planned.start.mo[i]+avg.length) %% 12), digits = 0)
      # assigning end date estimation codes for robustness checks
      pid$enddate.type[i] <- 2
    } else if (!is.na(pid$actual.start.yr[i])) {
      avg.length <- mean(pid$project.length[which(pid$actual.start.yr==pid$actual.start.yr[i] & pid$province.name==pid$province.name[i])], na.rm = T)
      # expected end date is estimated based on mean project length and the actual start date value
      pid$actual.end.yr[i] <- pid$actual.start.yr[i] + floor((pid$actual.start.mo[i]+avg.length)/12)
      pid$actual.end.mo[i] <- round(((pid$actual.start.mo[i]+avg.length) %% 12), digits = 0)
      pid$enddate.type[i] <- 1
    } else {pid$enddate.type[i] <- 0}
  } else {pid$enddate.type[i] <- 0}
}

pid <- pid[!is.na(pid$actual.end.yr),]

# ensuring all levels of the new/repair string variable are consistent
pid$new.repair[pid$new.repair=="Routinemaintenance"] <- "Routine maintenance"
pid$new.repair[pid$new.repair=="Repeatedservice"] <- "Repeated service"

# normalizing numeric new/repair variables
pid$new.repair.num[pid$new.repair.num==601] <- 2
pid$new.repair.num[pid$new.repair.num==602] <- 1
pid$new.repair.num[pid$new.repair.num==603] <- 3
pid$new.repair.num[pid$new.repair.num==604] <- 4
pid$new.repair.num[pid$new.repair.num==605] <- 5

# removing major outliers in the bidding variable
nrow(pid[(pid$n.bidders %in% c(2003, 3140)),])
pid <- pid[!(pid$n.bidders %in% c(2003, 3140)),] #May want to keep the rows with high n bidders

pid$bid.dummy <- ifelse(pid$n.bidders==0, 0, 1)

###################

# creating a skeleton dataset to store treatment data
treatment <- as.data.frame(matrix(NA, nrow = 1, ncol = 24))[0,]
names(treatment) <- c("village.code", "village.name", "province.name", "district.name", "commune.name", "earliest.end.date", 
                      "enddate.type", "earliest.sector.num", "earliest.sector", paste0("count", 2003:2017))

# filling treatment dataset with necessary variables
for(i in 1:length(unique(pid$village.code))) {
  temp <- pid[which(pid$village.code==unique(pid$village.code)[i]),]
  row <- nrow(treatment)+1
  # treatment dataset only stores one observations per village. For cases of multiple observations of the same village,
  # the treatment data stores the village ID, province the village is in, and the end year and activity type information
  # for the observation with the earliest end year
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
  # storing the count of villages getting treated in each year in the treatment data
  for(j in sort(unique(pid$actual.end.yr))) {
    treatment[row, grep(paste0("count", j), names(treatment))] <- nrow(temp[temp$actual.end.yr==j,])
  }
}

###################

# reading in and merging data from the GeoQuery extract
grid_1000_matched_data <- read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv",
                                   stringsAsFactors = F)
merge_grid_1000_lite <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv",
                                 stringsAsFactors = F)
grid_1000_matched_data <- merge(grid_1000_matched_data, merge_grid_1000_lite, by = "cell_id")
grid_1000_matched_data <- grid_1000_matched_data[,-c(7:49, 72:221)]

#merging PID data with GeoQuery extract
id.list <- list()
id.list2 <- list()
for(i in 1:nrow(grid_1000_matched_data)) {
  # creating lists storing the information of which villages lie in, and in the cells bordering, each grid cell from
  # the GeoQuery data
  point <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_point_ids[i], split = "\\|"))))
  box <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_box_ids[i], split = "\\|"))))
  
  if(grid_1000_matched_data$village_point_ids[i]=="") {
    id.list[[i]] <- ""
  } else {
    # if grid cell i has a village/s within it, item i in the object id.list stores the village id/s
    id.list[[i]] <- point
  }
  if(grid_1000_matched_data$village_box_ids[i]=="") {
    id.list2[[i]] <- ""
  } else {
    if(length(setdiff(box, point)) > 0) {
      # if grid cell i has a village/s in the cells bordering it, item i in the object id.list2 stores the village id/s of
      # those villages but omits any villages within grid cell i
      id.list2[[i]] <- setdiff(box, point)
    } else {
      id.list2[[i]] <- ""
    }
  }
}

# creating a skeleton dataset to store the merged PID/shape and grid cell data
pre.panel.names <- c("village.code", "village.name", "province.name", "district.name", "commune.name", 
                     as.vector(outer(c("box", "point"), c("earliest.end.date", "enddate.type", "earliest.sector.num", "earliest.sector", 
                                                          paste0("count", 1992:2017)), paste, sep=".")), names(grid_1000_matched_data))

pre.panel <- as.data.frame(matrix(NA, nrow = nrow(grid_1000_matched_data), ncol = length(pre.panel.names)))
names(pre.panel) <- pre.panel.names

# in the "pre.panel" data, there will be one observation per grid cell
for(i in 1:length(unique(grid_1000_matched_data$cell_id))) {
  # creating temporary datasets containing the PID/shape data of the villages that lie within or border grid cell i. This
  # matching relies on the list objects build previously to identify which villages are within/bordering each cell
  temp.point <- treatment[which(treatment$village.code %in% as.character(id.list[[i]])),]
  temp.box <- treatment[which(treatment$village.code %in% as.character(id.list2[[i]])),]
  
  # if there are one or more villages within grid cell i, then we fill out the variables with the prefix "point." with
  # the information frmo those villages
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
    # computing the total number of projects each year for the villages within grid cell i
    for(j in sort(unique(treatment$earliest.end.date))) {
      pre.panel[i, grep(paste0("point.count", j), (names(pre.panel)))] <- 
        as.data.frame(temp.point[, paste0("count", c(2003:2017)[2003:2017<=j])]) %>%
        apply(., 2, sum, na.rm=T) %>%
        sum()
    }
  }
  # if there are one or more villages bordering grid cell i, then we fill out the variables with the prefix "box." with
  # the information frmo those villages
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
    # computing the total number of projects each year for the villages bordering grid cell i
    for(j in sort(unique(treatment$earliest.end.date))) {
      pre.panel[i, grep(paste0("box.count", j), (names(pre.panel)))] <- 
        as.data.frame(temp.box[, paste0("count", c(2003:2017)[2003:2017<=j])]) %>%
        apply(., 2, sum, na.rm=T) %>%
        sum()
    }
  }
  # merging the grid cell data for grid cell i with the pre.panel dataset for grid cell i
  pre.panel[i, which(names(pre.panel) %in% names(grid_1000_matched_data))] <- grid_1000_matched_data[i,]
  
  if(is.na(pre.panel$village.code[i])) {
    villages <- c(id.list[[i]], id.list2[[i]]) %>% .[!.==""]
    temp <- shape[shape$village.code==villages[1],]
    if(nrow(temp)>0) {
      pre.panel[i, "village.code"] <- temp$village.code
      pre.panel[i, "village.name"] <- temp$village.name
      pre.panel[i, "province.name"] <- temp$province.name
      pre.panel[i, "district.name"] <- temp$district.name
      pre.panel[i, "commune.name"] <- temp$commune.name
    }
  }
  if(i %% 1000 == 0){cat(i, "of", nrow(grid_1000_matched_data), "\n")}
}

for(i in grep("count", names(pre.panel))) {pre.panel[which(is.na(pre.panel[,i])), i] <- 0}

pre.panel$unique.commune.name <- paste(pre.panel$province.name, pre.panel$district.name, pre.panel$commune.name)

# editing variable names to make data reshaping easier
names(pre.panel) <- gsub("v4composites_calibrated_201709.", "ntl_", names(pre.panel)) %>% gsub(".mean", "", .)

###################

cdb <- read.csv("InputData/CDB_merged_final.csv", stringsAsFactors = F)
cdb <- cdb[,c("VillGis", "Year", "MAL_TOT", "FEM_TOT", "KM_ROAD", "HRS_ROAD", "KM_P_SCH", "Baby_die_Midw", "Baby_die_TBA", 
              "THATCH_R", "Zin_Fibr_R", "TILE_R", "Flat_R_Mult", "Flat_R_One", "Villa_R", "THAT_R_Elec", "Z_Fib_R_Elec", 
              "Til_R_Elec", "Flat_Mult_Elec", "Flat_One_Elec", "Villa_R_Elec", "Fish_ro_boat", "Trav_ro_boat", "Fish_Mo_boat",
              "Trav_Mo_boat", "M_boat_les1T", "M_boat_ov1T", "Family_Car", "BICY_NUM", "Cow_Num", "Hors_NUM", "PIG_FAMI", 
              "Goat_fami", "Chick_fami", "Duck_fami", "THAT_R_TV", "Z_Fib_R_TV", "Til_R_TV", "Flat_Mult_TV", "Flat_One_TV", 
              "Villa_R_TV")]

names <- c("MAL_TOT", "FEM_TOT", "KM_ROAD", "HRS_ROAD", "KM_P_SCH", "Baby_die_Midw", "Baby_die_TBA", 
           "THATCH_R", "Zin_Fibr_R", "TILE_R", "Flat_R_Mult", "Flat_R_One", "Villa_R", "THAT_R_Elec", "Z_Fib_R_Elec", 
           "Til_R_Elec", "Flat_Mult_Elec", "Flat_One_Elec", "Villa_R_Elec", "Fish_ro_boat", "Trav_ro_boat", "Fish_Mo_boat",
           "Trav_Mo_boat", "M_boat_les1T", "M_boat_ov1T", "Family_Car", "BICY_NUM", "Cow_Num", "Hors_NUM", "PIG_FAMI", 
           "Goat_fami", "Chick_fami", "Duck_fami", "THAT_R_TV", "Z_Fib_R_TV", "Til_R_TV", "Flat_Mult_TV", "Flat_One_TV", 
           "Villa_R_TV")
panel.names <- list()
for(i in names) {panel.names[[length(panel.names)+1]] <- paste0(i, ".", 1992:2013)}

cdb <- reshape(data = cdb, direction = "wide", v.names = names, timevar = "Year", idvar = "VillGis")

cdb[apply(expand.grid(names, ".", 1992:2007), 1, paste, collapse="")] <- NA

sum(pre.panel$village.code %in% cdb$VillGis)
cdb.pre.panel <- merge(pre.panel, cdb, by.x = "village.code", by.y = "VillGis", all.x = T)

panel.names <- list.append(panel.names, paste0("ntl_", 1992:2013), paste0("point.count", 1992:2013), paste0("box.count", 1992:2013))

cdb.panel <- reshape(data = cdb.pre.panel, direction = "long", varying = panel.names,
                     idvar = "panel_id", timevar = "year")

cdb.panel <- cdb.panel[,!(grepl(paste0(c(2014:2017, "NA"), collapse = "|"), names(cdb.panel)))]

names(cdb.panel) <- gsub("\\.1992|\\_1992|1992", "", names(cdb.panel))

# reshaping cross sectional data into a panel structure with time dimension being years 1992:2013 and the panel variable being
# cell id
panel <- reshape(data = pre.panel, direction = "long", varying = list(paste0("ntl_", 1992:2013), 
                                                                      paste0("point.count", 1992:2013),
                                                                      paste0("box.count", 1992:2013)),
                 idvar = "panel_id", sep = "_", timevar = "year")
names(panel)[names(panel)=="ntl_1992"] <- "ntl"
names(panel)[names(panel)=="point.count1992"] <- "point.count"
names(panel)[names(panel)=="box.count1992"] <- "box.count"


panel <- panel[, !(names(panel) %in% c(paste0("point.count", 2014:2017), paste0("box.count", 2014:2017)))]
# write.csv(panel, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel_intervillage_projects.csv", row.names = F)
