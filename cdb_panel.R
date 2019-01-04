
setwd("~/box sync/cambodia_eba_gie")

library(spatialEco)
library(rlist)
library(sp)

polygons <- readRDS("inputdata/gadm36_KHM_4_sp.rds")
shape <- as.data.frame(read.csv("inputdata/village_grid_files/village_data.csv", stringsAsFactors = F))
spatial.data <- SpatialPointsDataFrame(coords = shape[,c("longitude", "latitude")], data = shape, 
                                       proj4string = CRS("+proj=longlat +datum=WGS84"))
shape <- as.data.frame(point.in.poly(x=spatial.data, y=polygons))[,c("VILL_CODE", "VILL_NAME", "NAME_1", "NAME_2", "NAME_3")]
names(shape) <- c("village.code", "village.name", "province.name", "district.name", "commune.name")

pid <- read.csv("ProcessedData/pid.csv", stringsAsFactors = F)

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

cdb <- read.csv("InputData/CDB_merged_final.csv", stringsAsFactors = F)
cdb <- merge(shape, cdb, by.x = "village.code", by.y = "VillGis")
cdb <- cdb[which(!is.na(cdb$province.name)),]
cdb <- cdb[,c("village.code", "village.name", "province.name", "district.name", "commune.name", "Year", "FAMILY", "MAL_TOT", "FEM_TOT", "KM_ROAD", "HRS_ROAD", "KM_P_SCH", "Baby_die_Midw", "Baby_die_TBA", 
              "THATCH_R", "Zin_Fibr_R", "TILE_R", "Flat_R_Mult", "Flat_R_One", "Villa_R", "THAT_R_Elec", "Z_Fib_R_Elec", 
              "Til_R_Elec", "Flat_Mult_Elec", "Flat_One_Elec", "Villa_R_Elec", "Fish_ro_boat", "Trav_ro_boat", "Fish_Mo_boat",
              "Trav_Mo_boat", "M_boat_les1T", "M_boat_ov1T", "Family_Car", "BICY_NUM", "COW_FAMI", "Hors_Fami", "PIG_FAMI", 
              "Goat_fami", "Chick_fami", "Duck_fami", "THAT_R_TV", "Z_Fib_R_TV", "Til_R_TV", "Flat_Mult_TV", "Flat_One_TV", 
              "Villa_R_TV")]

# cdb <- cdb[!grepl("n.a.", cdb$commune.name),]

# assessing the FAMILY variable major outliers
hist(cdb$FAMILY[which(cdb$FAMILY>2000)])
tail(sort(cdb$FAMILY))
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$FAMILY==6361)]),])
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$FAMILY==6621)]),])
aggregate(cdb$FAMILY, list(cdb$Year), mean, na.rm=T)

hist(cdb$FAMILY[which(cdb$Year==2008)], ylim = c(0, 10000), xlim = c(0, 8500))
hist(cdb$FAMILY[which(cdb$Year==2009)], ylim = c(0, 10000), xlim = c(0, 8500))
hist(cdb$FAMILY[which(cdb$Year==2010)], ylim = c(0, 10000), xlim = c(0, 8500))
hist(cdb$FAMILY[which(cdb$Year==2011)], ylim = c(0, 10000), xlim = c(0, 8500))
hist(cdb$FAMILY[which(cdb$Year==2012)], ylim = c(0, 10000), xlim = c(0, 8500))
hist(cdb$FAMILY[which(cdb$Year==2013)], ylim = c(0, 10000), xlim = c(0, 8500))
hist(cdb$FAMILY[which(cdb$Year==2014)], ylim = c(0, 10000), xlim = c(0, 8500))
hist(cdb$FAMILY[which(cdb$Year==2015)], ylim = c(0, 10000), xlim = c(0, 8500))
hist(cdb$FAMILY[which(cdb$Year==2016)], ylim = c(0, 10000), xlim = c(0, 8500))

# assessing the MAL_TOT variable major outliers
hist(cdb$MAL_TOT[which(cdb$MAL_TOT>10000)])
tail(sort(cdb$MAL_TOT))
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$MAL_TOT==12013)]),])
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$MAL_TOT==12043)]),])
# the observation with value 14112 is clearly a data error. Doesnt affect any variables we are interested
# in, but if we use MAL_TOT we need to omit these
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$MAL_TOT==14112)]),])
# the observation with value 14337 is clearly a data error
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$MAL_TOT==14337)]),])
# the observation with value 26368 is clearly a data error
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$MAL_TOT==26368)]),])
plot(aggregate(cdb$MAL_TOT, list(cdb$Year), mean, na.rm=T))

# assessing the HRS_ROAD variable major outliers
hist(cdb$HRS_ROAD[which(cdb$HRS_ROAD>1000)])
tail(sort(cdb$HRS_ROAD))
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$HRS_ROAD==840)]),])
# the observation with value 900 is clearly a data error
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$HRS_ROAD==900)]),])
# all three observations with value 1800 are clearly data errors
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$HRS_ROAD==1800)[1]]),])
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$HRS_ROAD==1800)[2]]),])
# the observation with value 2400 is clearly a data error
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$HRS_ROAD==2400)]),])
plot(aggregate(cdb$HRS_ROAD, list(cdb$Year), mean, na.rm=T))

# assessing the Family_Car variable major outliers
hist(cdb$Family_Car[which(cdb$Family_Car>800)])
tail(sort(cdb$Family_Car))
# weird intra-village variation for this subset
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$Family_Car==2455)]),])
# the observation with value 4113 is clearly a data error
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$Family_Car==4113)]),])
View(cdb[which(cdb$village.code==cdb$village.code[which(cdb$Family_Car==5307)]),])
plot(aggregate(cdb$Family_Car, list(cdb$Year), mean, na.rm=T))

hist(cdb$Family_Car[which(cdb$Year==2008)], xlim = c(0, 2000))
hist(cdb$Family_Car[which(cdb$Year==2009)], xlim = c(0, 2000))
hist(cdb$Family_Car[which(cdb$Year==2010)], xlim = c(0, 2000))
hist(cdb$Family_Car[which(cdb$Year==2011)], xlim = c(0, 2000))
hist(cdb$Family_Car[which(cdb$Year==2012)], xlim = c(0, 2000))
hist(cdb$Family_Car[which(cdb$Year==2013)], xlim = c(0, 2000))
hist(cdb$Family_Car[which(cdb$Year==2014)], xlim = c(0, 2000))
hist(cdb$Family_Car[which(cdb$Year==2015)], xlim = c(0, 2000))
hist(cdb$Family_Car[which(cdb$Year==2016)], xlim = c(0, 2000))

# randomly select a village and view, across years, the variation in variables of interest
View(cdb[cdb$village.code==sample(cdb$village.code, 1),])

###################

names <- c("FAMILY", "MAL_TOT", "FEM_TOT", "KM_ROAD", "HRS_ROAD", "KM_P_SCH", "Baby_die_Midw", "Baby_die_TBA", 
           "THATCH_R", "Zin_Fibr_R", "TILE_R", "Flat_R_Mult", "Flat_R_One", "Villa_R", "THAT_R_Elec", "Z_Fib_R_Elec", 
           "Til_R_Elec", "Flat_Mult_Elec", "Flat_One_Elec", "Villa_R_Elec", "Fish_ro_boat", "Trav_ro_boat", "Fish_Mo_boat",
           "Trav_Mo_boat", "M_boat_les1T", "M_boat_ov1T", "Family_Car", "BICY_NUM", "COW_FAMI", "Hors_Fami", "PIG_FAMI", 
           "Goat_fami", "Chick_fami", "Duck_fami", "THAT_R_TV", "Z_Fib_R_TV", "Til_R_TV", "Flat_Mult_TV", "Flat_One_TV", 
           "Villa_R_TV")

panel.names <- list()
for(i in names) {panel.names[[length(panel.names)+1]] <- paste0(i, ".", 2008:2016)}

cdb <- reshape(data = cdb, direction = "wide", v.names = names, timevar = "Year", idvar = "village.code")

# cdb[apply(expand.grid(names, ".", 1992:2007), 1, paste, collapse="")] <- NA

sum(cdb$VillGis %in% treatment$village.code)

cdb.panel <- merge(cdb, treatment, by.x = "village.code", by.y = "village.code")

cdb.panel <- cdb.panel[,!(grepl(paste0(c(2003:2007, "NA"), collapse = "|"), names(cdb.panel)))]

cdb.panel <- reshape(data = cdb.panel, direction = "long", varying = list.append(panel.names, paste0("count", 2008:2016)),
                     idvar = "village.code", timevar = "year")

names(cdb.panel) <- gsub("\\.2008|2008|_x", "", names(cdb.panel))
names(cdb.panel) <- gsub("\\.", "_", names(cdb.panel))
cdb.panel <- cdb.panel[,!names(cdb.panel)=="count2017"]
cdb.panel <- cdb.panel[,!grepl("_y", names(cdb.panel))]


# write.csv(cdb.panel, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/cdb_panel.csv", row.names = F)
# cdb.panel <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/cdb_panel.csv", stringsAsFactors = F)

###################

cdb <- cdb[,c("VillGis", grep("THAT_R_Elec|Z_Fib_R_Elec|Til_R_Elec|Flat_Mult_Elec|Flat_One_Elec|Villa_R_Elec", names(cdb), value = T))]
cdb <- cdb[, !grepl(paste("NA", collapse = "|"), names(cdb))]

grid_1000_matched_data <- read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv",
                                   stringsAsFactors = F)
merge_grid_1000_lite <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv",
                                 stringsAsFactors = F)
grid_1000_matched_data <- merge(grid_1000_matched_data, merge_grid_1000_lite, by = "cell_id")
grid_1000_matched_data <- grid_1000_matched_data[,-c(7:49, 72:221)]
grid_1000_matched_data <- grid_1000_matched_data[, !grepl(paste(c(1992:2007, "dist_to_water.na.mean", "dist_to_groads.na.mean"), 
                                                                collapse = "|"), names(grid_1000_matched_data))]

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
    else {id.list2[[i]] <- ""}}
}

dataset <- as.data.frame(matrix(NA, nrow = nrow(grid_1000_matched_data), ncol = c(ncol(grid_1000_matched_data)+ncol(cdb))))
names(dataset) <- c(names(grid_1000_matched_data), names(cdb))

for(i in 1:nrow(grid_1000_matched_data)) {
  
  temp <- cdb[as.character(as.numeric(cdb$VillGis)) %in% as.character(as.numeric(id.list[[i]])),]
  
  dataset[i,which(names(grid_1000_matched_data) %in% names(dataset))] <- grid_1000_matched_data[i,]
  dataset[i,which(names(dataset) %in% names(temp))] <- apply(temp, 2, sum)
  
  if(i %% 1000 == 0){cat(i, "of", nrow(grid_1000_matched_data), "\n")}
  
}

names(dataset) <- gsub(".mean", "", names(dataset))

cdb.corr <- reshape(data = dataset, direction = "long", varying = list(paste0("v4composites_calibrated_201709.", 2008:2017),
                                                                       paste0("THAT_R_Elec.", 2008:2017),
                                                                       paste0("Z_Fib_R_Elec.", 2008:2017),
                                                                       paste0("Til_R_Elec.", 2008:2017),
                                                                       paste0("Flat_Mult_Elec.", 2008:2017),
                                                                       paste0("Flat_One_Elec.", 2008:2017),
                                                                       paste0("Villa_R_Elec.", 2008:2017)), 
                    idvar = "village_id", sep = "\\.", timevar = "year")

names(cdb.corr) <- gsub(".2008", "", names(cdb.corr))
names(cdb.corr)[names(cdb.corr)=="v4composites_calibrated_201709"] <- "ntl"

write.csv(cdb.corr, "/Users/christianbaehr/Desktop/cdb_corr.csv", row.names = F)


