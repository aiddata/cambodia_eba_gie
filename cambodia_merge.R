#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Merging Project Information Database treatment data with covariate data from the Commune Database and 
# spatio-temporal data measuring nighttime light of Cambodia from GeoQuery
#------------------------------

setwd("~/box sync/cambodia_eba_gie")

library(plyr)
library(dplyr)
library(readxl)
library(sf)
library(stringr)
library(sp)
library(spatialEco)
library(rlist)
library(rgdal)

# reading in complete PID data
pid <- read.csv("PID/completed_pid/pid_merge.csv", stringsAsFactors = F)

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

# removing major outliers in the bidding variable
nrow(pid[(pid$n.bidders %in% c(2003, 3140)),])
pid <- pid[!grepl("2003|3140", pid$n.bidders),]
# pid <- pid[!(pid$n.bidders %in% c(2003, 3140)),] #May want to keep the rows with high n bidders

sum(pid$cs.fund>2e+8, na.rm = T)
sum(pid$cs.fund>1e+8, na.rm = T)
#hist(pid$cs.fund[pid$cs.fund<1e+8]) #do we want to remove major outliers?

sum(pid$local.cont>3e+7, na.rm = T)
sum(pid$local.cont>1e+7, na.rm = T)
#hist(pid$local.cont[pid$local.cont<2e+6])

# creating a dummy variable denoting whether there was competitive bidding for a contract based
# on the number of bidders variable

pid$n.bidders <- sapply(pid$n.bidders, FUN = function(x) {mean(as.numeric(unlist(strsplit(x, "\\|"))), na.rm = T)})

q <- quantile(pid$mean_unitCost, na.rm=T, probs=seq(0, 1, 0.1))
pid$unitCost_quantile <- as.character(sapply(pid$mean_unitCost, FUN = function(x) {names(which.min(abs(x-q)))}))
pid$unitCost_quantile <- sapply(pid$unitCost_quantile, FUN = function(x) {0.01*as.numeric(gsub("%", "", x))})

# for(i in 2003:2017) {
#   pid[paste0("pct_compet_bids", i)] <- ifelse(pid$actual.end.yr==i, pid$pct_comp_bid, NA)
#   pid[paste0("n_bids_", i)] <- ifelse(pid$actual.end.yr==i, pid$n.bidders, NA)
# }
# stargazer(pid[,c(sort(grep(paste(2003:2017, collapse="|"), names(pid), value = T)))], type="html",
#           omit.summary.stat = c("max", "min", "p25", "p75", "sd"), 
#           out = "/Users/christianbaehr/Desktop/sum_stats.html")

# write.csv(pid, "ProcessedData/pid.csv", row.names = F)
# pid <- read.csv("ProcessedData/pid.csv", stringsAsFactors = F)

###################

# building stacked barplots of activity type by year by province
# for(i in unique(pid$province.name)) {
#   # taking the subset of pid occurring in province i
#   temp <- pid[which((pid$province.name==i & !is.na(pid$activity.type) & !is.na(pid$actual.end.yr))),]
#   if(nrow(temp)>1) {
#     # creating a matrix to store the data that will be used to build plots
#     temp.mat <- as.data.frame(matrix(0, ncol = 21, nrow = 16))
#     a <- pid[!duplicated(pid[,c("activity.type", "activity.type.num")]),
#                     c("activity.type", "activity.type.num")]
#     a <- a[!is.na(a$activity.type.num),]
#     names(temp.mat) <- a$activity.type[match(c(1:21), a$activity.type.num)]
#     row.names(temp.mat) <- c(2003:2018)
# 
#     for(j in unique(temp$actual.end.yr)) {
#       # filling row j in the matrix with the activity type data from the corresponding year
#       temp2 <- temp[which(temp$actual.end.yr==j),]
#       x <- table(temp2$activity.type.num)
#       temp.mat[(row.names(temp.mat)==j), as.numeric(names(x))] <- table(temp2$activity.type.num)
#     }
#     # producing barplots for the distribution of activity types for projects in each province in each year
#     mycolors <- c('#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe',
#                 '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080',
#                 '#000000')
#     png(paste0("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/activity_plots/activity_",
#                gsub(" ", "", i), ".png"), width = 10, height = 7, res = 300, units = 'in')
#     barplot(t(as.matrix(temp.mat))[colSums(temp.mat)>0,],
#             main = paste("Activity Type Distribution,", i), xlab = "Year", ylab = "Number of Projects",
#             col = mycolors[which(colSums(temp.mat)>0)])
#     legend("topright", legend=row.names(t(as.matrix(temp.mat)))[colSums(temp.mat)>0], cex = 0.75,
#            fill = mycolors[which(colSums(temp.mat)>0)])
#     dev.off()
#   }
# }

###################

# building a matrix of data to be used in the commune level treatment rate graph. I store this data in the Box Sync
# so it can be retrieved instead of being re-run each time

# graph.data <- as.data.frame(matrix(data = NA, nrow = 10, ncol = 16))
# names(graph.data) <- sort(unique(pid$actual.end.yr))
# row.names(graph.data) <- paste0(seq(10, 100, 10), "%_thres")
# count <- 0
# for(i in sort(unique(pid$actual.end.yr))) {
#   count=count+1
#   for(threshold in seq(0.1, 1, 0.1)) {
#     x <- rep(NA, length(unique(pid$commune.name)))
#     for(j in 1:length(unique(pid$commune.name))) {
#       temp <- pid[which(pid$commune.name==unique(pid$commune.name)[j]),]
#       x[j] <- nrow(temp[(temp$actual.end.yr<=i),])/nrow(temp) >= threshold
#     }
#     graph.data[paste0(threshold*100, "%_thres"), as.character(i)] <- sum(x[!is.na(x)])/length(x[!is.na(x)])
#   }
#   print(count)
# }
# write.csv(graph.data, "/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/treatment_rates/treatment_rates.csv",
#           row.names = F)

# reading on treatment rates data for plots
# graph.data <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/treatment_rates/treatment_rates.csv",
#                        stringsAsFactors = F)
# # producing line graphs identifying the share of villages that have received X% of total treatment by each year (cumulative)
# for(i in 1:nrow(graph.data)) {
#   if(i==1) {
#     png("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/treatment_rates/treatment_rate_graph.png",
#         width = 10, height = 7, res = 300, units = 'in')
#     plot(as.numeric(graph.data[1,]), col = i, type = "b", axes = F, xlab = NA, ylab = NA)
#   } else {
#     points(as.numeric(graph.data[i,]), col = i, type = "b")
#   }
#   if(i==nrow(graph.data)) {
#     axis(side = 1, at = c(1:ncol(graph.data)), labels = gsub("X", "", names(graph.data)), tick = T)
#     axis(side = 2, at = c(1:nrow(graph.data)/10), labels = paste0(seq(10, 100, 10), "%"),
#          tick = T)
#     mtext(side = 1, "Year", line = 2)
#     mtext(side = 2, "% communes with > X% treatment", line = 2)
#     mtext(side = 3, "% treatment by year at commune level")
#     legend("bottomright", legend = paste0(seq(10, 100, 10), "% thres"), fill = c(1:nrow(graph.data)),
#            col = c(1:nrow(graph.data)), cex = 1)
#     dev.off()
#   }
# }

###################

# creating a skeleton dataset to store treatment data
treatment <- as.data.frame(matrix(NA, nrow = 1, ncol = 83))[0,]
names(treatment) <- c("village.code", "village.name", "province.name", "district.name", "commune.name", "earliest.end.date", 
                      "enddate.type", "earliest.sector", paste0("count", 2003:2017), paste0("n_bids", 2003:2017),
                      paste0("pct_comp_bids", 2003:2017), paste0("unit_cost", 2003:2017), paste0("unitCost_quantile", 2003:2017))

# filling treatment dataset with necessary variables
for(i in 1:length(unique(pid$village.code))) {
  temp <- pid[which(pid$village.code==unique(pid$village.code)[i]),]
  row <- nrow(treatment)+1
  # treatment dataset only stores one observations per village. For cases of multiple observations of the same village,
  # the treatment data stores the village ID, province the village is in, and the end year and activity type information
  # for the observation with the earliest end year
  treatment[row, c("village.code", "village.name", "province.name", "district.name", "commune.name", "earliest.end.date", 
                   "enddate.type", "earliest.sector")] <- c(na.omit(temp$village.code)[1],
                                                            na.omit(temp$village.name)[1],
                                                            na.omit(temp$province.name)[1],
                                                            na.omit(temp$district.name)[1],
                                                            na.omit(temp$commune.name)[1],
                                                            temp$actual.end.yr[which.min(temp$actual.end.yr)],
                                                            temp$enddate.type[which.min(temp$actual.end.yr)],
                                                            temp$activity.type.num[which.min(temp$actual.end.yr)],
                                                            temp$activity.type[which.min(temp$actual.end.yr)])                       
  # storing the count of villages getting treated in each year in the treatment data
  for(j in sort(unique(pid$actual.end.yr))) {
    treatment[row, grep(paste0("count", j), names(treatment))] <- nrow(temp[temp$actual.end.yr==j,])
    treatment[row, grep(paste0("n_bids", j), names(treatment))] <- paste(temp$n.bidders[temp$actual.end.yr==j],collapse="|")
    treatment[row, grep(paste0("pct_comp_bids", j), names(treatment))] <- paste(temp$pct_comp_bid[temp$actual.end.yr==j],collapse = "|")
    treatment[row, grep(paste0("unit_cost", j), names(treatment))] <- mean(temp$mean_unitCost[temp$actual.end.yr==j], na.rm=T)
    treatment[row, grep(paste0("unitCost_quantile", j), names(treatment))] <- mean(temp$unitCost_quantile[temp$actual.end.yr==j], na.rm=T)
    
  }
}

treatment$comm_code <- ifelse(nchar(treatment$village.code==8),
                              substr(treatment$village.code, 1, 6),
                              substr(treatment$village.code, 1, 5))
for(i in 1:nrow(treatment)) {
  if(is.na(treatment$province.name[i])) {
    treatment$province.name[i] <- na.omit(treatment$province.name[treatment$comm_code==treatment$comm_code[i]])[1]
  }
  if(is.na(treatment$district.name[i])) {
    treatment$district.name[i] <- na.omit(treatment$district.name[treatment$comm_code==treatment$comm_code[i]])[1]
  }
  if(is.na(treatment$commune.name[i])) {
    treatment$commune.name[i] <- na.omit(treatment$commune.name[treatment$comm_code==treatment$comm_code[i]])[1]
  }
}

###################

# reading in and merging data from the GeoQuery extract
grid_1000_matched_data <- read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv",
                                   stringsAsFactors = F)
merge_grid_1000_lite <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv",
                                 stringsAsFactors = F)
grid_1000_matched_data <- merge(grid_1000_matched_data, merge_grid_1000_lite, by = "cell_id")

poly <- readOGR("/Users/christianbaehr/box sync/cambodia_eba_gie/inputdata/village_grid_files/grid_1000_filter_lite.geojson")
poly2 <- as.data.frame(point.in.poly(x=spatial.data, y=poly))
poly2 <- poly2[,c("VILL_CODE", "cell_id")]

a <- as.data.frame(unique(poly2$cell_id))
names(a) <- "cell_id"
a$point_id <- NA
for(i in 1:nrow(a)) {
  temp <- poly2[poly2$cell_id==a$cell_id[i],]
  
  if(nrow(temp)==1) {
    a$point_id[i] <- temp$VILL_CODE
  } 
  else if(nrow(temp)>1) {
    temp2 <- temp$VILL_CODE
    a$point_id[i] <- paste(temp2, collapse = "|")
  } 
  else {
    a$point_id[i] <- NA
  }
}

b <- merge(grid_1000_matched_data, a, by="cell_id", all.x=T)
b$village_point_ids <- b$point_id
b$village_point_ids[is.na(b$village_point_ids)] <- ""
b <- b[,!names(b) %in% "point_id"]
grid_1000_matched_data <- b

grid_1000_matched_data <- grid_1000_matched_data[,-c(7:23, 72:221)]

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
# pre.panel.names <- c("village.code", "village.name", "province.name", "district.name", "commune.name", "cell_id", 
#                       as.vector(outer(c("box", "point"), c("earliest.end.date", "enddate.type", "earliest.sector", 
#                                                            paste0("count", 1992:2017)), paste, sep=".")), names(grid_1000_matched_data))
pre.panel.names <- c("village.code", "village.name", "province.name", "district.name", "commune.name", "cell_id", 
                     as.vector(outer(c("box", "point"), c("earliest.end.date", "enddate.type", "earliest.sector", 
                                                          paste0("count", 1992:2017)), paste, sep=".")),
                     paste0("n_bids", 1992:2017), paste0("pct_comp_bids", 1992:2017), paste0("unit_cost", 1992:2017),
                     paste0("unitCost_quantile", 1992:2017))

pre.panel <- as.data.frame(matrix(NA, nrow = nrow(grid_1000_matched_data), ncol = length(pre.panel.names)))
names(pre.panel) <- pre.panel.names

# in the "pre.panel" data, there will be one observation per grid cell
for(i in 1:length(grid_1000_matched_data$cell_id)) {
  # creating temporary datasets containing the PID/shape data of the villages that lie within or border grid cell i. This
  # matching relies on the list objects build previously to identify which villages are within/bordering each cell
  temp.point <- treatment[which(treatment$village.code %in% as.character(as.numeric(id.list[[i]]))),]
  temp.box <- treatment[which(treatment$village.code %in% as.character(as.numeric(id.list2[[i]]))),]
  pre.panel$cell_id[i] <- grid_1000_matched_data$cell_id[i]
  
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
    pre.panel[i, "box.earliest.sector"] <- temp.box$earliest.sector[which.min(temp.box$earliest.end.date)]
    # computing the total number of projects each year for the villages bordering grid cell i
    for(j in sort(unique(treatment$earliest.end.date))) {
      pre.panel[i, grep(paste0("box.count", j), (names(pre.panel)))] <- 
        as.data.frame(temp.box[, paste0("count", c(2003:2017)[2003:2017<=j])]) %>%
        apply(., 2, sum, na.rm=T) %>%
        sum()
    }
  }
  for(j in sort(unique(treatment$earliest.end.date))) {
    
    x <- as.numeric(paste(id.list[[i]], id.list2[[i]]))
    pre.panel[i, grep(paste0("n_bids", j), names(pre.panel))] <- mean(as.numeric(as.matrix(treatment[treatment$village.code %in% x, paste0("n_bids", c(2003:2017)[2003:2017<=j])])),na.rm=T)
    pre.panel[i, grep(paste0("pct_comp_bids", j), names(pre.panel))] <- mean(as.numeric(as.matrix(treatment[treatment$village.code %in% x, paste0("pct_comp_bids", c(2003:2017)[2003:2017<=j])])),na.rm=T)
    pre.panel[i, grep(paste0("unit_cost", j), names(pre.panel))] <- mean(as.numeric(as.matrix(treatment[treatment$village.code %in% x, paste0("unit_cost", c(2003:2017)[2003:2017<=j])])),na.rm=T)
    pre.panel[i, grep(paste0("unitCost_quantile", j), names(pre.panel))] <- mean(as.numeric(as.matrix(treatment[treatment$village.code %in% x, paste0("unitCost_quantile", c(2003:2017)[2003:2017<=j])])),na.rm=T)
    
  }
  
  # merging the grid cell data for grid cell i with the pre.panel dataset for grid cell i
  # pre.panel[i, which(names(pre.panel) %in% names(grid_1000_matched_data))] <- grid_1000_matched_data[i,]
  
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

pre.panel <- merge(pre.panel, grid_1000_matched_data, by="cell_id")

for(i in grep("count", names(pre.panel))) {pre.panel[which(is.na(pre.panel[,i])), i] <- 0}

pre.panel$unique.commune.name <- paste(pre.panel$province.name, pre.panel$district.name, pre.panel$commune.name)

# editing variable names to make data reshaping easier
names(pre.panel) <- gsub("v4composites_calibrated_201709.", "ntl_", names(pre.panel)) %>% gsub(".mean", "", .)
pre.panel <- pre.panel[!grepl("ndvi", names(pre.panel))]

# pre.panel$temp <- paste(pre.panel$village_box_ids, pre.panel$village_point_ids, sep = "|")
# pre.panel$pct_comp_bids <- sapply(pre.panel$temp, FUN = function(x) {mean(pid$pct_comp_bid[which(pid$village.code %in% as.numeric(unlist(strsplit(x, "\\|"))))])})
# pre.panel$n_bidders <- sapply(pre.panel$temp, FUN = function(x) {mean(pid$n.bidders[which(pid$village.code %in% as.numeric(unlist(strsplit(x, "\\|"))))])})

burial <- st_read("inputData/cambodia_CGEO/Burials.shp")

burial_coords <- matrix(unlist(burial$geometry), ncol = 2, byrow = T)
burial_coords <- SpatialPoints(burial_coords, proj4string = CRS("+proj=utm +zone=48 +datum=WGS84"))
burial_coords <- spTransform(x = burial_coords, CRSobj = CRS("+proj=longlat +datum=WGS84"))

# burial$coords <- paste(matrix(burial_coords@coords, ncol = 2, byrow = F)[,1],
#                        matrix(burial_coords@coords, ncol = 2, byrow = F)[,2], sep = ",")

test <- as.data.frame(point.in.poly(x=burial_coords, y=polygons))
test$mergevar <- paste(test$NAME_1, test$NAME_2, test$NAME_3)

pre.panel$burial_dummy <- ifelse(pre.panel$unique.commune.name %in% test$mergevar, 1, 0)
pre.panel$n_burials <- NA
for(i in 1:nrow(pre.panel)) {
  if(pre.panel$unique.commune.name[i] %in% test$mergevar) {
    
    pre.panel$n_burials[i] <- sum(test$mergevar %in% pre.panel$unique.commune.name[i])
  } else {pre.panel$n_burials[i] <- 0}
}

# write.csv(pre.panel, "ProcessedData/pre_panel.csv", row.names=F)
# pre.panel <- read.csv("ProcessedData/pre_panel.csv", stringsAsFactors = F)

###################

# producing project count and ntl quantile statistic data frames by year/province
# for(i in unique(pre.panel$province.name)) {
#   temp <- as.data.frame(apply(pre.panel[which(pre.panel$province.name==i), grep("ntl", names(pre.panel))], 2, as.numeric))
# 
#   sum.stats <- as.data.frame(matrix(data=NA, ncol = 8, nrow = 27))
#   row.names(sum.stats) <- 1992:2018
#   colnames(sum.stats) <- c("count", "pct.count", "0%", "25%", "Mean", "Median", "75%", "100%")
# 
#   for(j in unique(pre.panel$point.earliest.end.date)[!is.na(unique(pre.panel$point.earliest.end.date))]) {
#     count <- nrow(pre.panel[which((pre.panel$province.name==i & pre.panel$point.earliest.end.date==j)),])
#     sum.stats[grep(j, row.names(sum.stats)), 1] <- count
#     sum.stats[grep(j, row.names(sum.stats)), 2] <- count/nrow(pre.panel[which(pre.panel$province.name==i & !is.na(pre.panel$point.earliest.end.date)),])
#   }
# 
#   x <- as.data.frame(cbind(apply(temp, 2, mean, na.rm=T), t(apply(temp, 2, quantile, na.rm=T))))
#   row.names(x) <-
#     gsub("ntl_", "", row.names(x)) %>%
#     gsub(".mean", "", .)
#   sum.stats[which(row.names(sum.stats) %in% row.names(x)),3:8] <- x[,c(2:3, 1, 4:6)]
# 
#   assign(paste0("sum_stats_", gsub(" ", "", i)), sum.stats)
#   # write.csv(sum.stats, paste0("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/summary_stats/", gsub(" ", "", i), ".csv"))
# }

###################

# reshaping cross sectional data into a panel structure with time dimension being years 1992:2013 and the panel variable being
# cell id

# merge_grid_1000_lite.uncalibrated <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite_uncalibrated.csv", 
#                                               stringsAsFactors = F)
# pre.panel <- merge(pre.panel, merge_grid_1000_lite.uncalibrated, by = "cell_id")
# names(pre.panel) <- gsub("v4composites.", "ntl_", names(pre.panel))
# # names(pre.panel) <- gsub("\\.mean", "_uncalibrated", names(pre.panel))

panel <- reshape(data = pre.panel, direction = "long", varying = list(paste0("ntl_", 1992:2013),
                                                                      #paste0("ndvi_", 1992:2013),
                                                                      paste0("point.count", 1992:2013),
                                                                      paste0("box.count", 1992:2013),
                                                                      #, paste0("ntl_", 1992:2013, "_uncalibrated")
                                                                      paste0("n_bids", 1992:2013),
                                                                      paste0("pct_comp_bids", 1992:2013),
                                                                      paste0("unit_cost", 1992:2013),
                                                                      paste0("unitCost_quantile", 1992:2013)),
                 idvar = "panel_id", sep = "_", timevar = "year")
# panel <- panel[, !(names(panel) %in% c(paste0("point.count", 2014:2017), paste0("box.count", 2014:2017), paste0("n_bids", 2014:2017),
#                                        paste0("pct_comp_bids", 2014:2017), "dist_to_water.na", 
#                                        "dist_to_groads.na", "id", "panel_id"))]

names(panel)[names(panel)=="village.code"] <- "village_code"
names(panel)[names(panel)=="village.name"] <- "village_name"
names(panel)[names(panel)=="province.name"] <- "province_name"
names(panel)[names(panel)=="district.name"] <- "district_name"
names(panel)[names(panel)=="commune.name"] <- "commune_name"
names(panel)[names(panel)=="box.earliest.end.date"] <- "border_cell_earliest_enddate"
names(panel)[names(panel)=="point.earliest.end.date"] <- "intra_cell_earliest_enddate"
names(panel)[names(panel)=="box.enddate.type"] <- "border_cell_enddate_type"
names(panel)[names(panel)=="point.enddate.type"] <- "intra_cell_enddate_type"
names(panel)[names(panel)=="box.earliest.sector"] <- "border_cell_earliest_sector"
names(panel)[names(panel)=="point.earliest.sector"] <- "intra_cell_earliest_sector"
names(panel)[names(panel)=="unique.commune.name"] <- "unique_commune_name"
names(panel)[names(panel)=="ntl_1992"] <- "ntl"
names(panel)[names(panel)=="point.count1992"] <- "intra_cell_count"
names(panel)[names(panel)=="box.count1992"] <- "border_cell_count"

names(panel)[names(panel)=="n_bids1992"] <- "n_bids"
names(panel)[names(panel)=="pct_comp_bids1992"] <- "pct_comp_bids"
names(panel)[names(panel)=="unit_cost1992"] <- "unit_cost"
names(panel)[names(panel)=="unitCost_quantile1992"] <- "unitCost_quantile"


# names(panel)[names(panel)=="ntl_1992_uncalibrated"] <- "ntl_uncalibrated"

# Create pre-trend for each cell's ntl values from 1992-2002
#subset panel to only include 1992-2001
pre_panel<-panel[panel$year<=11,]

obj <-pre_panel %>% split(.$cell_id) %>% lapply (lm, formula=formula(ntl~year))
#extract coefficients
obj_coefficients <- as.data.frame(t(lapply(obj, function(x)as.numeric(x[1]$coefficients[2]))))
#transpose so row number = cell_id and format
obj_coefficients1<-as.data.frame(t(obj_coefficients))
obj_coefficients1$rownumber <- as.numeric(rownames(obj_coefficients1))
obj_coeff<-obj_coefficients1
names(obj_coeff)[names(obj_coeff)=="V1"]="ntlpre_9202"
names(obj_coeff)[names(obj_coeff)=="rownumber"]="cell_id"
obj_coeff$ntlpre_9202<-as.numeric(obj_coeff$ntlpre_9202)
#merge trend for each cell_id back in to full panel dataset
panel<-merge(panel,obj_coeff,by="cell_id")

###

commune_data <- read.csv("inputData/governance/councilors_data.csv", stringsAsFactors = F)
panel$comm_code <- ifelse(nchar(panel$village_code)==8, substr(panel$village_code, 1, 6), substr(panel$village_code, 1, 5))
panel <- merge(panel, commune_data, by = "comm_code", all.x=T)

province_data <- read.csv("inputData/governance/province_governance.csv", stringsAsFactors = F)
panel <- merge(panel, province_data, by.x="province_name", by.y="Province", all.x=T)

panel$village_point_ids[panel$village_point_ids==""] <- NA

panel$n_vill <- apply(panel[,c("village_point_ids", "village_box_ids")], 1, paste, collapse="|")
panel$vills <- str_count(gsub("NA\\|", "", panel$n_vill), "\\|")+1

panel <- panel[c("village_code", "village_name", "district_name", "commune_name", "province_name", "cell_id", "year", 
                 "ntl", "intra_cell_count", "border_cell_count", "vills", "unique_commune_name", "ntlpre_9202",
                 "comm_type", "n_vill_in_comm", "n_councilors_03", "admin_funds_03", "dev_funds_03", "total_funds_03",
                 "admin_funds_04", "dev_funds_04", "total_funds_04", "n_communes", "pct_commune_priorities_funded_2002",
                 "pct_commune_priorities_funded_2003", "CS_council_pct_women_2002", "CS_council_pct_women_2003",
                 "pct_new_commChiefs_prev_served_2002", "pct_new_CC_mem_prev_served_2002", "n_ExCom_staff_2003", "n_bids",
                 "pct_comp_bids", "unit_cost", "unitCost_quantile", "burial_dummy", "n_burials")]




## Write Panel Data File
# write.csv(panel, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel.csv", row.names = F)
# panel <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel.csv", stringsAsFactors = F)

# grid_1000_matched_data <- grid_1000_matched_data[,c("cell_id", "village_point_ids", "village_box_ids")]

# panel <- merge(panel, grid_1000_matched_data, by="cell_id")
panel$village_point_ids[panel$village_point_ids==""] <- NA

panel$n_vill <- apply(panel[,c("village_point_ids", "village_box_ids")], 1, paste, collapse="|")
panel$vills <- str_count(gsub("NA\\|", "", panel$n_vill), "\\|")+1

###

cdb <- read.csv("/Users/christianbaehr/box sync/cambodia_eba_gie/inputdata/CDB_merged_final.csv", stringsAsFactors = F)

cdb$unique_id <- apply(cdb[,c("VillGis", "Year")], 1, paste, collapse="|")
panel$year_temp=panel$year+1991
panel$unique_id <- apply(panel[,c("village_code", "year_temp")], 1, paste, collapse="|")

merged_data <- merge(cdb, panel, by="unique_id")

write.csv(merged_data, "/Users/christianbaehr/Box Sync/cambodia_eba_gie/processeddata/ntl_cdb_merge.csv", row.names = F)

###

bid_panel <- merge(panel, grid_1000_matched_data[,c("cell_id", "village_point_ids", "village_box_ids")], by="cell_id")

bid_panel$temp <- paste(grid_1000_matched_data$village_box_ids, grid_1000_matched_data$village_point_ids, sep = "|")

bid_panel$temp[1]
1-mean(pid$bid.dummy[which(pid$village.code %in% unlist(strsplit(bid_panel$temp[1], "\\|")))], na.rm = T)

bid_panel$pct_comp_bids <- sapply(bid_panel$temp, FUN = function(x) {1-mean(pid$bid.dummy[which(pid$village.code %in% unlist(strsplit(x, "\\|")))], na.rm = T)})
  
bid_panel$pct_comp_bids2 <- NA
for(i in 1:nrow(bid_panel)) {
  
  bid_panel$pct_comp_bids2[i] <- 1-mean(pid$bid.dummy[which(pid$village.code %in% unlist(strsplit(bid_panel$temp[i], "\\|")))], na.rm = T)
 print(i) 
}















