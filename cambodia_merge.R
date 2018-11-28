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

# the commented out code merges the three PID datasets and assigns a common Activity Type index to the PID data
# it then writes out a complete PID dataset that can be read in instead of re-running this code each time

# pid2016 <- read.csv("pid/completed_pid/pid_2016.csv", stringsAsFactors = F)
# pid2012 <- read.csv("pid/completed_pid/pid_2012.csv", stringsAsFactors = F)
# pid2008 <- read.csv("pid/completed_pid/pid_2008.csv", stringsAsFactors = F)
# pid <- rbind.fill(pid2016, pid2012, pid2008)
# 
# common.index <- as.data.frame(matrix(data = NA, nrow = 21, ncol = 0))
# common.index[1:17,"2008"] <- sort(unique(pid2008$activity.type))
# common.index[1:17,"2012"] <- sort(unique(pid2012$activity.type))[match(common.index[1:17,"2008"],
#                                                                        sort(unique(pid2012$activity.type)))]
# common.index[1:17,"2016"] <- sort(unique(pid2016$activity.type))[match(common.index[1:17,"2008"],
#                                                                        sort(unique(pid2016$activity.type)))]
# common.index[18:21, "2012"] <- unique(pid2012$activity.type)[!(unique(pid2012$activity.type) %in% common.index[1:17,"2012"])]
# common.index[18:21, "2016"] <- unique(pid2016$activity.type)[match(common.index[18:21, "2012"], unique(pid2016$activity.type))]
# common.index[,"type"] <- c(common.index[1:17,"2008"], common.index[18:21, "2012"])
# common.index[,"id"] <- seq(1, 21, 1)
# 
# pid <- merge(pid[,!(names(pid)=="activity.type.num")], common.index[,c("type", "id")], by.x = "activity.type", by.y = "type")
# names(pid)[names(pid)=="id"] <- "activity.type.num"
# write.csv(pid, "pid/completed_pid/pid_merge.csv", row.names = F)

# reading in complete PID data
pid <- read.csv("pid/completed_pid/pid_merge.csv",stringsAsFactors = F)
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
    if(is.na(pid$actual.start.yr[i]) & !is.na(pid$province.name[i])) {
      # determining the mean project length for projects in the the same province and year as i
      temp <- mean(pid$project.length[(pid$planned.start.yr==pid$planned.start.yr[i] & pid$province.name==pid$province.name[i])], na.rm = T)
      # for cases where the actual start date is missing, we use the planned start date as the reference point
      # for estimating actual end date
      pid$actual.end.yr[i] <- pid$planned.start.yr[i] + floor((pid$planned.start.mo[i]+temp)/12)
      pid$actual.end.mo[i] <- round(((pid$planned.start.mo[i]+temp) %% 12), digits = 0)
      # assigning end date estimation codes for robustness checks
      pid$enddate.type[i] <- 2
    } else if (!is.na(pid$actual.start.yr[i]) & !is.na(pid$province.name[i])) {
      temp <- mean(pid$project.length[(pid$actual.start.yr==pid$actual.start.yr[i] & pid$province.name==pid$province.name[i])], na.rm = T)
      # expected end date is estimated based on mean project length and the actual start date value
      pid$actual.end.yr[i] <- pid$actual.start.yr[i] + floor((pid$actual.start.mo[i]+temp)/12)
      pid$actual.end.mo[i] <- round(((pid$actual.start.mo[i]+temp) %% 12), digits = 0)
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

sum(pid$cs.fund>2e+8, na.rm = T)
sum(pid$cs.fund>1e+8, na.rm = T)
#hist(pid$cs.fund[pid$cs.fund<1e+8]) #do we want to remove major outliers?

sum(pid$local.cont>3e+7, na.rm = T)
sum(pid$local.cont>1e+7, na.rm = T)
#hist(pid$local.cont[pid$local.cont<2e+6])

# creating a dummy variable denoting whether there was competitive bidding for a contract based
# on the number of bidders variable
pid$bid.dummy <- ifelse(pid$n.bidders==0, 0, 1)

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
pre.panel <- as.data.frame(matrix(NA, nrow = nrow(grid_1000_matched_data), ncol = 264))
names(pre.panel) <- c("village.code", "village.name", "province.name", "district.name", "commune.name", 
                      as.vector(outer(c("box", "point"), c("earliest.end.date", "enddate.type", "earliest.sector.num", "earliest.sector", 
                                                           paste0("count", 2003:2017)), paste, sep=".")), names(grid_1000_matched_data))

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

# write.csv(pre.panel, "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/pre_panel.csv", row.names=F)
pre.panel <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/pre_panel.csv", stringsAsFactors = F)

###################

# producing project count and ntl quantile statistic data frames by year/province
# for(i in unique(pre.panel$province.name)) {
#   temp <- as.data.frame(apply(pre.panel[which(pre.panel$province.name==i), grep("v4composite", names(pre.panel))], 2, as.numeric))
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
#     gsub("v4composites_calibrated_201709.", "", row.names(x)) %>%
#     gsub(".mean", "", .)
#   sum.stats[which(row.names(sum.stats) %in% row.names(x)),3:8] <- x[,c(2:3, 1, 4:6)]
# 
#   assign(paste0("sum_stats_", gsub(" ", "", i)), sum.stats)
#   # write.csv(sum.stats, paste0("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/summary_stats/", gsub(" ", "", i), ".csv"))
# }

###################

# editing variable names to make data reshaping easier
names(pre.panel) <- gsub("v4composites_calibrated_201709.", "ntl_", names(pre.panel)) %>% gsub(".mean", "", .)

# reshaping cross sectional data into a panel structure with time dimension being years 1992:2013 and the panel variable being
# cell id
panel <- reshape(data = pre.panel, direction = "long", varying = list(paste0("ntl_", 1992:2013)),
                 idvar = "panel_id", sep = "_", timevar = "year")
names(panel)[names(panel)=="ntl_1992"] <- "ntl"

panel <- panel[,!(grepl("ltdr", names(panel)) | grepl("udel", names(panel)))]
# write.csv(panel, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel.csv", row.names = F)
# panel <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel.csv", stringsAsFactors = F)

###################

pre.panel2 <- pre.panel
pre.panel2[c(paste0("box.count", 1992:2002), paste0("point.count", 1992:2002))] <- 0

panel2 <- reshape(data = pre.panel2, direction = "long", varying = list(paste0("ntl_", 1992:2013),
                                                                                paste0("box.count", 1992:2013),
                                                                                paste0("point.count", 1992:2013)),
                           idvar = "panel_id", sep = "_", timevar = "year")

names(panel2)[names(panel2)=="ntl_1992"] <- "ntl"
names(panel2)[names(panel2)=="box.count1992"] <- "box.count"
names(panel2)[names(panel2)=="point.count1992"] <- "point.count"

panel2 <- panel2[,!(grepl("ltdr", names(panel2)) | grepl("udel", names(panel2)))]

# write.csv(panel2, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel2.csv", row.names = F)
panel2 <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel2.csv", stringsAsFactors = F)

###################

pre.panel.uncalibrated <- pre.panel
names(pre.panel.uncalibrated) <- gsub("v4composites_calibrated_201709.", "ntl_", 
                                      names(pre.panel.uncalibrated)) %>% gsub(".mean", "", .)
merge_grid_1000_lite.uncalibrated <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite_uncalibrated.csv", 
                                              stringsAsFactors = F)
names(merge_grid_1000_lite.uncalibrated) <- gsub("v4composites.", "ntl_", 
                                                 names(merge_grid_1000_lite.uncalibrated)) %>% gsub(".mean", "", .)

names(pre.panel.uncalibrated) %in% names(merge_grid_1000_lite.uncalibrated)[!names(merge_grid_1000_lite.uncalibrated)=="cell_id"]

match(pre.panel$cell_id, merge_grid_1000_lite.uncalibrated$cell_id)

pre.panel.uncalibrated[,names(pre.panel.uncalibrated) %in% 
                         names(merge_grid_1000_lite.uncalibrated)[!names(
                           merge_grid_1000_lite.uncalibrated)=="cell_id"]] <- 
  merge_grid_1000_lite.uncalibrated[match(merge_grid_1000_lite.uncalibrated$cell_id, 
                                          pre.panel.uncalibrated$cell_id),!names(merge_grid_1000_lite.uncalibrated)=="cell_id"]

panel.uncalibrated <- reshape(data = pre.panel.uncalibrated, direction = "long", varying = list(paste0("ntl_", 1992:2013)),
                 idvar = "panel_id", sep = "_", timevar = "year")
names(panel.uncalibrated)[names(panel.uncalibrated)=="ntl_1992"] <- "ntl"

panel.uncalibrated <- panel.uncalibrated[,!(grepl("ltdr", names(panel.uncalibrated)) | grepl("udel", names(panel.uncalibrated)))]
# write.csv(panel.uncalibrated, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel_uncalibrated.csv", row.names = F)

###################

cdb <- as.data.frame(read_excel("inputdata/CDB_merged_final.xlsx"))
cdb <- cdb[,c("VillGis", "Year", "MAL_TOT", "FEM_TOT", "KM_ROAD", "HRS_ROAD", "KM_P_SCH", "Baby_die_Midw", "Baby_die_TBA", 
              "THATCH_R", "Zin_Fibr_R", "TILE_R", "Flat_R_Mult", "Flat_R_One", "Villa_R", "THAT_R_Elec", "Z_Fib_R_Elec", 
              "Til_R_Elec", "Flat_Mult_Elec", "Flat_One_Elec", "Villa_R_Elec")]
cdb <- cdb[!is.na(cdb$Year),]

for(i in unique(cdb$VillGis)) {
  temp <- cdb[cdb$VillGis==i,]
  if(length(temp$Year) != length(unique(cdb$Year))) {
    cdb <- cdb[!(cdb$VillGis==i),]
  }
}
cdb <- reshape(cdb, idvar = "VillGis", timevar = "Year", direction = "wide")

cdb.pre.panel <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/pre_panel.csv", stringsAsFactors = F)

sum(cdb.pre.panel$village.code %in% cdb$VillGis)
cdb.pre.panel <- merge(cdb.pre.panel, cdb, by.x = "village.code", by.y = "VillGis", all.x = T)

cdb.pre.panel <- cdb.pre.panel[,c(1:47, 265:436)]
names <- c("MAL_TOT", "FEM_TOT", "KM_ROAD", "HRS_ROAD", "KM_P_SCH", "Baby_die_Midw", "Baby_die_TBA", 
           "THATCH_R", "Zin_Fibr_R", "TILE_R", "Flat_R_Mult", "Flat_R_One", "Villa_R", "THAT_R_Elec", "Z_Fib_R_Elec", 
           "Til_R_Elec", "Flat_Mult_Elec", "Flat_One_Elec", "Villa_R_Elec")
panel.names <- list()
for(i in names) {panel.names[[length(panel.names)+1]] <- paste0(i, ".", 2008:2016)}

cdb.panel <- reshape(data = cdb.pre.panel, direction = "long", varying = panel.names,
                  idvar = "cell_id", timevar = "year")

names(cdb.panel) <- gsub(".2008", "", names(cdb.panel))

# write.csv(cdb.panel, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/cdb_panel.csv", row.names = F)




