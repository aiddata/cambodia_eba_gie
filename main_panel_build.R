#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Merging Project Information Database treatment data with covariate data from the Commune Database and 
# spatio-temporal data measuring nighttime light of Cambodia from GeoQuery
#------------------------------

setwd("~/box sync/cambodia_eba_gie")

library(plyr)
library(dplyr)
# library(readxl)
# library(sf)
library(stringr)
# library(sp)
library(spatialEco)
# library(rlist)
library(rgdal)

boundaries <- readRDS("inputdata/gadm36_KHM_4_sp.rds")
shape <- as.data.frame(read.csv("inputdata/village_grid_files/village_data.csv", stringsAsFactors = F))
village_points <- SpatialPointsDataFrame(coords = shape[,c("longitude", "latitude")], data = shape, proj4string = CRS("+proj=longlat +datum=WGS84"))
shape <- as.data.frame(point.in.poly(x=village_points, y=boundaries))[,c("VILL_CODE", "VILL_NAME", "NAME_1", "NAME_2", "NAME_3")]
names(shape) <- c("vill_code", "vill_name", "prov_name", "dist_name", "comm_name")

# the commented out code merges the three PID datasets then writes out a complete PID dataset that can be read in instead 
# of re-running this code each time
pid2008 <- read.csv("pid/completed_pid/pid_2008.csv", stringsAsFactors = F)
pid2008$bid.dummy <- ifelse(pid2008$n.bidders>0, 1, 0)
pid2008[,c("actual.start.yr", "actual.start.mo")] <- NA

pid2012 <- read.csv("pid/completed_pid/pid_2012.csv", stringsAsFactors = F)
pid2012$bid.dummy <- ifelse(pid2012$n.bidders>0, 1, 0)

pid2016 <- read.csv("pid/completed_pid/pid_2016.csv", stringsAsFactors = F)
pid2016$bid.dummy <- ifelse(pid2016$n.bidders>0, 1, 0)
pid2016[,c("last.report", "new.repair.num", "status")] <- NA

pid <- do.call("rbind", list(pid2008, pid2012, pid2016))
pid <- pid[pid$actual.end.yr!=1908 | is.na(pid$actual.end.yr),]

# merging PID data with shape data based on Village ID
pid <- merge(shape, pid, by.x = "vill_code", by.y = "vill.id", all.y = T)
# generating a variable that contains the length of each PID project
pid$proj_length <- (((pid$actual.end.yr-pid$actual.start.yr)*12)+(pid$actual.end.mo-pid$actual.start.mo))

# some PID projects are missing an actual end date value. To avoid losing data, actual end date is estimated by determining the average
# project length of other projects in the same year and in the same province and treating that as the expected length of the project. This
# expected length, assuming we have an actual start date value, allows us to estimate the end date of the project.
pid$enddate_accuracy <- NA
for(i in which(is.na(pid$actual.end.yr))) {
  
  if(is.na(pid$actual.start.yr[i])) {temp_var <- c("planned.start.yr", "planned.start.mo")} 
  else {temp_var <- c("actual.start.yr","actual.start.mo")}
  
  # expected end date is estimated based on mean project length and the actual start date value
  temp_length <- mean(pid$proj_length[which(pid$actual.start.yr==pid[i, temp_var[1]] & pid$prov_name==pid$prov_name[i])], na.rm = T)
  
  pid$actual.end.yr[i] <- pid[i, temp_var[1]] + floor((pid[i, temp_var[2]]+temp_length)/12) 
  pid$actual.end.mo[i] <- round(((pid[i, temp_var[2]]+temp_length) %% 12), digits = 0)
  
  # assigning end date estimation codes for robustness checks
  pid$enddate_accuracy[i] <- ifelse(is.na(pid$actual.start.yr[i]), 0, 1)
}
pid$enddate_accuracy[is.na(pid$enddate_accuracy)] <- 2
pid <- pid[!is.na(pid$actual.end.yr),]

# ensuring all levels of the new/repair string variable are consistent
pid$new.repair[which(pid$new.repair=="Routinemaintenance")] <- "Routine maintenance"
pid$new.repair[which(pid$new.repair=="Repeatedservice")] <- "Repeated service"

x <- tapply(X=pid$vill_code, INDEX = pid$project.id, FUN = function(X) {length(unique(X))})
y <- cbind(names(x), as.numeric(x))
pid <- merge(pid, y, by.x="project.id", by.y="V1")
pid$mult_vill_proj <- ifelse(as.numeric(pid$V2)>1, 1, 0)
pid <- pid[, names(pid)!= "V2"]

# write.csv(pid, "ProcessedData/pid.csv", row.names = F)
# pid <- read.csv("ProcessedData/pid.csv", stringsAsFactors = F)

cells <- merge(read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv", stringsAsFactors = F), 
               read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv", stringsAsFactors = F),
               by = "cell_id")

village_points_fix <- village_points %>%
  point.in.poly(x=., y=readOGR("inputdata/village_grid_files/grid_1000_filter_lite.geojson")) %>%
  as.data.frame(.) %>% 
  .[,c("VILL_CODE", "cell_id")]

village_points_fix$point_ids <- NA
for(i in which(!duplicated(village_points_fix$cell_id))) {
  village_points_fix$point_ids[i] <- paste(village_points_fix$VILL_CODE[village_points_fix$cell_id==village_points_fix$cell_id[i]], collapse = "|")
}
village_points_fix <- village_points_fix[!is.na(village_points_fix$point_ids),]

cells <- merge(cells, village_points_fix, by="cell_id", all.x=T)
cells_slim <- cells[, c("cell_id", "point_ids", "village_box_ids", grep("v4composites", names(cells), value = T))]

id_list <- list()
id_list$cell_id <- cells_slim$cell_id
id_list$point_ids <- str_split(cells_slim$point_ids, pattern = "\\|")
id_list$box_ids <- mapply(FUN = function(x, y) {setdiff(x, y)}, x = str_split(cells_slim$village_box_ids, pattern = "\\|"), y = id_list$point_ids)

pre_panel_names <- c("vill_code", "cell_id",
                     outer(c("total_border", "total_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("univill_border", "univill_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("multvill_border", "multvill_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("new_border", "new_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("repair_border", "repair_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("upgrade_border", "upgrade_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("irrig_border", "irrig_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("rtrans_border", "rtrans_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("utrans_border", "utrans_intra"), c(1992:2017), paste, sep="_"),
                     outer(c("water_border", "water_intra"), c(1992:2017), paste, sep="_"))

pre_panel <- as.data.frame(matrix(NA, nrow = nrow(cells_slim), ncol = length(pre_panel_names)))
names(pre_panel) <- pre_panel_names

for(i in 1:nrow(cells_slim)) {
  temp_point <- pid[which(pid$vill_code %in% as.numeric(id_list$point_ids[[i]])),]
  temp_box <- pid[which(pid$vill_code %in% as.numeric(id_list$box_ids[[i]])),]
  
  pre_panel$vill_code[i] <- ifelse(is.na(id_list$point_ids[[i]]), id_list$box_ids[[i]], id_list$point_ids[[i]])[1]
  pre_panel$cell_id[i] <- cells_slim$cell_id[i]
  
  for(j in unique(pid$actual.end.yr)) {
    pre_panel[i, paste0("total_intra_", j)] <- sum(temp_point$actual.end.yr<=j)
    pre_panel[i, paste0("univill_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$mult_vill_proj==0)
    pre_panel[i, paste0("multvill_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$mult_vill_proj==1)
    pre_panel[i, paste0("new_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$new.repair=="New")
    pre_panel[i, paste0("repair_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$new.repair=="Repair")
    pre_panel[i, paste0("upgrade_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$new.repair=="Upgrade")
    pre_panel[i, paste0("irrig_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$activity.type=="Irrigation")
    pre_panel[i, paste0("rtrans_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$activity.type=="Rural Transport")
    pre_panel[i, paste0("utrans_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$activity.type=="Urban transport")
    pre_panel[i, paste0("water_intra_", j)] <- sum(temp_point$actual.end.yr<=j & temp_point$activity.type=="Rural Domestic Water Supplies")
    
    pre_panel[i, paste0("total_border_", j)] <- sum(temp_box$actual.end.yr<=j)
    pre_panel[i, paste0("univill_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$mult_vill_proj==0)
    pre_panel[i, paste0("multvill_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$mult_vill_proj==1)
    pre_panel[i, paste0("new_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$new.repair=="New")
    pre_panel[i, paste0("repair_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$new.repair=="Repair")
    pre_panel[i, paste0("upgrade_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$new.repair=="Upgrade")
    pre_panel[i, paste0("irrig_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$activity.type=="Irrigation")
    pre_panel[i, paste0("rtrans_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$activity.type=="Rural Transport")
    pre_panel[i, paste0("utrans_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$activity.type=="Urban transport")
    pre_panel[i, paste0("water_border_", j)] <- sum(temp_box$actual.end.yr<=j & temp_box$activity.type=="Rural Domestic Water Supplies")
    
  }
  if(i %% 1000 == 0){cat(i, "of", nrow(cells_slim), "\n")}  
}

pre_panel[,grepl("intra|border", names(pre_panel))] <- apply(pre_panel[,grepl("intra|border", names(pre_panel))],
                                                             2, function(X) {ifelse(is.na(X), 0, X)})

pre_panel <- merge(pre_panel, cells_slim, by="cell_id", all.x=T)
pre_panel$vill_code <- as.numeric(pre_panel$vill_code)
pre_panel <- merge(shape, pre_panel, by="vill_code", all.y=T)

names(pre_panel) <- gsub("v4composites_calibrated_201709.", "ntl_", names(pre_panel)) %>% gsub(".mean", "", .)

# write.csv(pre_panel, "ProcessedData/pre_panel.csv", row.names=F)
# pre_panel <- read.csv("ProcessedData/pre_panel.csv", stringsAsFactors = F)

rm(list = setdiff(ls(), c("pre_panel")))

panel <- reshape(data = pre_panel, direction = "long", idvar = "cell_id", sep = "_", timevar = "year",
                 varying = list(paste0("ntl_", 1992:2013),
                                paste0("total_intra_", 1992:2013), paste0("total_border_", 1992:2013),
                                paste0("univill_intra_", 1992:2013), paste0("univill_border_", 1992:2013),
                                paste0("multvill_intra_", 1992:2013), paste0("multvill_border_", 1992:2013),
                                paste0("new_intra_", 1992:2013), paste0("new_border_", 1992:2013),
                                paste0("repair_intra_", 1992:2013), paste0("repair_border_", 1992:2013),
                                paste0("upgrade_intra_", 1992:2013), paste0("upgrade_border_", 1992:2013),
                                paste0("irrig_intra_", 1992:2013), paste0("irrig_border_", 1992:2013),
                                paste0("rtrans_intra_", 1992:2013), paste0("rtrans_border_", 1992:2013),
                                paste0("utrans_intra_", 1992:2013), paste0("utrans_border_", 1992:2013),
                                paste0("water_intra_", 1992:2013), paste0("water_border_", 1992:2013)))

panel <- panel[, !grepl(paste(c(2014:2018), collapse = "|"), names(panel))]
names(panel) <- gsub("_1992", "", names(panel))

# Create pre-trend for each cell's ntl values from 1992-2002
#subset panel to only include 1992-2001
temp_panel <- panel[panel$year<=11,]

obj <- temp_panel %>% split(.$cell_id) %>% lapply (lm, formula=formula(ntl~year))

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
panel<-merge(panel,obj_coeff,by="cell_id", all.x=T)

panel$n_vill <- unlist(lapply(str_split(panel$village_box_ids, "\\|"), FUN = function(x) {length(x)}))

## Write Panel Data File
# write.csv(panel, file = "ProcessedData/panel.csv", row.names = F)
# panel <- read.csv("ProcessedData/panel.csv", stringsAsFactors = F)

cdb <- read.csv("inputdata/CDB_merged_final.csv", stringsAsFactors = F)

cdb$unique_id <- apply(cdb[,c("VillGis", "Year")], 1, paste, collapse="|")
panel$year_temp <- panel$year+1991
panel$unique_id <- apply(panel[,c("vill_code", "year_temp")], 1, paste, collapse="|")

merged_data <- merge(cdb, panel, by="unique_id")

write.csv(merged_data, "processeddata/ntl_cdb_merge.csv", row.names = F)

###

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
#     png(paste0("descriptive_stats/activity_plots/activity_",
#                gsub(" ", "", i), ".png"), width = 10, height = 7, res = 300, units = 'in')
#     barplot(t(as.matrix(temp.mat))[colSums(temp.mat)>0,],
#             main = paste("Activity Type Distribution,", i), xlab = "Year", ylab = "Number of Projects",
#             col = mycolors[which(colSums(temp.mat)>0)])
#     legend("topright", legend=row.names(t(as.matrix(temp.mat)))[colSums(temp.mat)>0], cex = 0.75,
#            fill = mycolors[which(colSums(temp.mat)>0)])
#     dev.off()
#   }
# }

###

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
# write.csv(graph.data, "descriptive_stats/treatment_rates/treatment_rates.csv",
#           row.names = F)

# reading on treatment rates data for plots
# graph.data <- read.csv("descriptive_stats/treatment_rates/treatment_rates.csv",
#                        stringsAsFactors = F)
# # producing line graphs identifying the share of villages that have received X% of total treatment by each year (cumulative)
# for(i in 1:nrow(graph.data)) {
#   if(i==1) {
#     png("descriptive_stats/treatment_rates/treatment_rate_graph.png",
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

###

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
#   # write.csv(sum.stats, paste0("descriptive_stats/summary_stats/", gsub(" ", "", i), ".csv"))
# }
