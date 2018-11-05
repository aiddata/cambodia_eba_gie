#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Merging Project Information Database treatment data with covariate data from the Commune Database and 
# spatio-temporal data measuring nighttime light of Cambodia from GeoQuery
#------------------------------

setwd("~/box sync/cambodia_eba_gie")

library(dplyr)
library(plyr)
library(readxl)
library(stringr)

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

pid <- read.csv("pid/completed_pid/pid_merge.csv",stringsAsFactors = F)
pid <- pid[pid$actual.end.yr!=1908 | is.na(pid$actual.end.yr),]

gazetteer <- 
  read_excel("inputdata/National Gazetteer 2014.xlsx", sheet = 4) %>%
  as.data.frame() %>%
  .[,!(names(.) %in% c("ProvKH", "DistTypeKh", "DistKh", "CommTypeKh", "Name_KH"))]

pid <- merge(pid, gazetteer, by.x = "vill.id", by.y = "Id", all.x = T)

pid$project.length <- (((pid$actual.end.yr-pid$actual.start.yr)*12)+(pid$actual.end.mo-pid$actual.start.mo))

for(i in 1:nrow(pid)) {
  if(is.na(pid$actual.end.yr[i])) {
    if(is.na(pid$actual.start.yr[i]) & !is.na(pid$ProvEn[i])) {
      temp <- mean(pid$project.length[(pid$planned.start.yr==pid$planned.start.yr[i] & pid$ProvEn==pid$ProvEn[i])], na.rm = T)
      
      pid$actual.end.yr[i] <- pid$planned.start.yr[i] + floor((pid$planned.start.mo[i]+temp)/12)
      pid$actual.end.mo[i] <- round(((pid$planned.start.mo[i]+temp) %% 12), digits = 0)
      
    } else if (!is.na(pid$actual.start.yr[i]) & !is.na(pid$ProvEn[i])) {
      
      temp <- mean(pid$project.length[(pid$actual.start.yr==pid$actual.start.yr[i] & pid$ProvEn==pid$ProvEn[i])], na.rm = T)
      
      pid$actual.end.yr[i] <- pid$actual.start.yr[i] + floor((pid$actual.start.mo[i]+temp)/12)
      pid$actual.end.mo[i] <- round(((pid$actual.start.mo[i]+temp) %% 12), digits = 0)
    }
  }
}

###################

# pid$subsector <-
#   read_excel("pid/pid_excel_2012/ListSubSector.xlsx") %>%
#   merge(pid, ., by.x = "activity.type", by.y = "Name_EN", all.x = T) %>%
#   .$Id

pid$new.repair[pid$new.repair=="Routinemaintenance"] <- "Routine maintenance"
pid$new.repair[pid$new.repair=="Repeatedservice"] <- "Repeated service"

pid$new.repair.num[pid$new.repair.num==601] <- 2
pid$new.repair.num[pid$new.repair.num==602] <- 1
pid$new.repair.num[pid$new.repair.num==603] <- 3
pid$new.repair.num[pid$new.repair.num==604] <- 4
pid$new.repair.num[pid$new.repair.num==605] <- 5

nrow(pid[(pid$n.bidders %in% c(2003, 3140)),])
pid <- pid[!(pid$n.bidders %in% c(2003, 3140)),] #May want to keep the rows with high n bidders

hist(pid$cs.fund)

sum(pid$cs.fund>2e+8, na.rm = T)
sum(pid$cs.fund>1e+8, na.rm = T)
hist(pid$cs.fund[pid$cs.fund<1e+8]) #do we want to remove major outliers?

sum(pid$local.cont>3e+7, na.rm = T)
sum(pid$local.cont>1e+7, na.rm = T)
hist(pid$local.cont[pid$local.cont<2e+6])

pid$bid.dummy <- ifelse(pid$n.bidders==0, 0, 1)

###################

rm(list = setdiff(ls(), "pid"))
# cdb <- read_excel("inputdata/CDB_merged_final.xlsx")[,c("VillGis", "Year", "MAL_TOT", "FEM_TOT")]
shape <- read.csv("inputdata/village_grid_files/village_data.csv", stringsAsFactors = F)

# sum(cdb$VillGis %in% shape$VILL_CODE)
# cdb <- merge(cdb, shape, by.x = "VillGis", by.y = "VILL_CODE")
# cdb$TOTPOP <- as.numeric(cdb$MAL_TOT) + as.numeric(cdb$FEM_TOT)
# 
# hist(cdb$MAL_TOT[cdb$MAL_TOT<10000])
# which(cdb$MAL_TOT>10000)
# 
# # View(cdb[cdb$VillGis==cdb$VillGis[65740],])
# #get some weird results when comparing high pop village population by year, ie row 65740
# 
# # which(cdb$TOTPOP>15000)
# # #View(cdb[cdb$VillGis==cdb$VillGis[21815],])
# cdb <- cdb[-c(6621, 15299, 21815),]
# 
# cdb <- cdb[-c(6650, 15070, 19122),]
# # villages 65731 65732 65733 65734 65736 65738 65739 65740 65744 OK
# 
# # which(cdb$MOTO_NUM>10000)
# # # View(cdb[cdb$VillGis==cdb$VillGis[65729],])
# #
# # which(cdb$Crim_case>100)
# # #View(cdb[cdb$VillGis==cdb$VillGis[66617], "Crim_case"])
# cdb <- cdb[-c(2449, 66617),]
# #
# # which(cdb$Crim_case>40)
# # View(cdb[cdb$VillGis==cdb$VillGis[34887], "Crim_case"])
# 
# cdb <- cdb[!is.na(cdb$Year),]

###################

length(unique(pid$vill.id))
# data <- merge(cdb, pid, by.x = "VillGis", by.y = "vill.id")
data <- merge(shape, pid, by.x = "VILL_CODE", by.y = "vill.id")
names(data)[names(data)=="VILL_CODE"] <- "VillGis"

sum(is.na(data$actual.end.yr))
data <- data[!is.na(data$actual.end.yr),]

###################

#building stacked barplots of activity type by year by province

for(i in unique(data$ProvEn)) {
  temp <- data[which((data$ProvEn==i & !is.na(data$activity.type) & !is.na(data$actual.end.yr))),]
  if(nrow(temp)>1) {
    temp.mat <- as.data.frame(matrix(0, ncol = 21, nrow = 16))
    a <- data[!duplicated(data[,c("activity.type", "activity.type.num")]),
                    c("activity.type", "activity.type.num")]
    a <- a[!is.na(a$activity.type.num),]
    names(temp.mat) <- a$activity.type[match(c(1:21), a$activity.type.num)]
    row.names(temp.mat) <- c(2003:2018)

    for(j in unique(temp$actual.end.yr)) {
      temp2 <- temp[which(temp$actual.end.yr==j),]
      x <- table(temp2$activity.type.num)
      temp.mat[(row.names(temp.mat)==j), as.numeric(names(x))] <- table(temp2$activity.type.num)
    }
    mycolors <- c('#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', 
                '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', 
                '#000000')
    png(paste0("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/activity_plots/activity_",
               gsub(" ", "", i), ".png"), width = 10, height = 7, res = 300, units = 'in')
    barplot(t(as.matrix(temp.mat))[colSums(temp.mat)>0,], 
            main = paste("Activity Type Distribution,", i), xlab = "Year", ylab = "Number of Projects",
            col = mycolors[which(colSums(temp.mat)>0)])
    legend("topright", legend=row.names(t(as.matrix(temp.mat)))[colSums(temp.mat)>0], cex = 0.75,
           fill = mycolors[which(colSums(temp.mat)>0)])
    dev.off()
  }
}

########################

gazetteer <- read_excel("/Users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/National Gazetteer 2014.xlsx", sheet=3)
data$commid <- NA
for(i in 1:nrow(data)) {
  data$commid[i] <- ifelse((nchar(data$VillGis[i])==7),
                                 paste0(unlist(strsplit(as.character(data$VillGis[i]), ""))[1:5], collapse = ""),
                                 paste0(unlist(strsplit(as.character(data$VillGis[i]), ""))[1:6], collapse = ""))
}
data <- merge(data, gazetteer[,(names(gazetteer) %in% c("Name_EN", "Id"))], by.x = "commid", by.y = "Id", all.x = T)
names(data)[names(data)=="Name_EN" ] <- "comm_name"

###################

# graph.data <- as.data.frame(matrix(data = NA, nrow = 10, ncol = 16))
# names(graph.data) <- sort(unique(data$actual.end.yr))
# row.names(graph.data) <- paste0(seq(10, 100, 10), "%_thres")
# count=0
# for(i in sort(unique(data$actual.end.yr))) {
#   count=count+1
#   for(threshold in seq(0.1, 1, 0.1)) {
#     x <- rep(NA, length(unique(data$commid)))
#     for(j in 1:length(unique(data$commid))) {
#       temp <- data[(data$commid==unique(data$commid)[j]),]
#       x[j] <- nrow(temp[temp$actual.end.yr<=i,])/nrow(temp) >= threshold
#     }
#     graph.data[paste0(threshold*100, "%_thres"), as.character(i)] <- sum(x)/length(x)
#   }
#   print(count)
# }
# write.csv(graph.data, "/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/treatment_rates/treatment_rates.csv",
#           row.names = F)
graph.data <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/treatment_rates/treatment_rates.csv",
                       stringsAsFactors = F)
for(i in 1:nrow(graph.data)) {
  if(i==1) {
    png("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/treatment_rates/treatment_rate_graph.png",
        width = 10, height = 7, res = 300, units = 'in')
    plot(as.numeric(graph.data[1,]), col = i, type = "b", axes = F, xlab = NA, ylab = NA)
  } else {
    points(as.numeric(graph.data[i,]), col = i, type = "b")
  }
  if(i==nrow(graph.data)) {
    axis(side = 1, at = c(1:ncol(graph.data)), labels = gsub("X", "", names(graph.data)), tick = T)
    axis(side = 2, at = c(1:nrow(graph.data)/10), labels = paste0(seq(10, 100, 10), "%"),
         tick = T)
    mtext(side = 1, "Year", line = 2)
    mtext(side = 2, "% communes with > X% treatment", line = 2)
    mtext(side = 3, "% treatment by year at commune level")
    legend("bottomright", legend = paste0(seq(10, 100, 10), "% thres"), fill = c(1:nrow(graph.data)),
           col = c(1:nrow(graph.data)), cex = 1)
    dev.off()
  }
}

###################

grid_1000_matched_data <- read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv",
                                   stringsAsFactors = F)
merge_grid_1000_lite <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv",
                                 stringsAsFactors = F)
grid_1000_matched_data <- merge(grid_1000_matched_data, merge_grid_1000_lite, by = "cell_id")

###################

rm(list = setdiff(ls(), c("data", "cdb", "grid_1000_matched_data")))

treatment <- as.data.frame(matrix(NA, nrow = 1, ncol = 21))[0,]
names(treatment) <- c("VillGis", "ProvEn", "earliest.end.date", "earliest.sector.num", 
                      "earliest.sector", paste0("count", 2003:2018))

for(i in 1:length(unique(data$VillGis))) {
  village <- unique(data$VillGis)[i]
  temp <- data[which(data$VillGis==village),]
  row <- nrow(treatment)+1
  
  treatment[row, c(1:5)] <- c(temp$VillGis[1],temp$ProvEn[1],
                                       temp$actual.end.yr[which.min(temp$actual.end.yr)],
                                       temp$activity.type.num[which.min(temp$actual.end.yr)],
                                       temp$activity.type[which.min(temp$actual.end.yr)])
  
  for(j in sort(unique(data$actual.end.yr))) {
    treatment[row, grep(j, names(treatment))] <- nrow(temp[temp$actual.end.yr==j,])
  }
}

###################

#mergin PID data with GeoQuery extract

id.list <- list()
id.list2 <- list()
for(i in 1:nrow(grid_1000_matched_data)) {
  point <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_point_ids[i], split = "\\|"))))
  box <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_box_ids[i], split = "\\|"))))
  
  if(grid_1000_matched_data$village_point_ids[i]=="") {
    id.list[[i]] <- ""
  } else {
    id.list[[i]] <- point
  }
  
  if(grid_1000_matched_data$village_box_ids[i]=="") {
    id.list2[[i]] <- ""
  } else {
    if(length(setdiff(box, point)) > 0) {
      id.list2[[i]] <- setdiff(box, point)
    } else {
      id.list2[[i]] <- ""
    }
  }
}

pre.panel <- as.data.frame(matrix(NA, nrow = nrow(grid_1000_matched_data), ncol = 261))
names(pre.panel) <- c("VillGis", "ProvEn", as.vector(outer(c("box", "point"), 
                                                 c("earliest.end.date", "earliest.sector.num", "earliest.sector", 
                                                   paste0("count", 2003:2018)), paste, sep=".")), 
                      names(grid_1000_matched_data))

for(i in 1:length(unique(grid_1000_matched_data$cell_id))) {
  temp.point <- treatment[which(treatment$VillGis %in% as.character(id.list[[i]])),]
  temp.box <- treatment[which(treatment$VillGis %in% as.character(id.list2[[i]])),]
  
  if(nrow(temp.point) > 0) {
    pre.panel[i, "VillGis"] <- temp.point$VillGis[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "ProvEn"] <- temp.point$ProvEn[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "point.earliest.end.date"] <- temp.point$earliest.end.date[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "point.earliest.sector.num"] <- temp.point$earliest.sector.num[which.min(temp.point$earliest.end.date)]
    pre.panel[i, "point.earliest.sector"] <- temp.point$earliest.sector[which.min(temp.point$earliest.end.date)]
    
    for(j in sort(unique(treatment$earliest.end.date))) {
      pre.panel[i, grep(paste0("point.count", j), (names(pre.panel)))] <- 
        as.data.frame(temp.point[, paste0("count", c(2003:2018)[2003:2018<=j])]) %>%
        apply(., 2, sum, na.rm=T) %>%
        sum()
    }
  }
  if(nrow(temp.box) > 0) {
    pre.panel[i, "VillGis"] <- temp.box$VillGis[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "ProvEn"] <- temp.box$ProvEn[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "box.earliest.end.date"] <- temp.box$earliest.end.date[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "box.earliest.sector.num"] <- temp.box$earliest.sector.num[which.min(temp.box$earliest.end.date)]
    pre.panel[i, "box.earliest.sector"] <- temp.box$earliest.sector[which.min(temp.box$earliest.end.date)]
    
    for(j in sort(unique(treatment$earliest.end.date))) {
      pre.panel[i, grep(paste0("box.count", j), (names(pre.panel)))] <- 
        as.data.frame(temp.box[, paste0("count", c(2003:2018)[2003:2018<=j])]) %>%
        apply(., 2, sum, na.rm=T) %>%
        sum()
    }
  }
  pre.panel[i, which(names(pre.panel) %in% names(grid_1000_matched_data))] <- grid_1000_matched_data[i,]
  
  if(i %% 1000 == 0){cat(i, "of", nrow(grid_1000_matched_data), "\n")}
}

###################

# write.csv(pre.panel, "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/pre_panel.csv", row.names=F)
pre.panel <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/pre_panel.csv", stringsAsFactors = F)

gazetteer <- read_excel("/Users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/National Gazetteer 2014.xlsx", sheet=3)
pre.panel$commid <- NA
for(i in 1:nrow(pre.panel)) {
  pre.panel$commid[i] <- ifelse((nchar(pre.panel$VillGis[i])==7),
                           paste0(unlist(strsplit(as.character(pre.panel$VillGis[i]), ""))[1:5], collapse = ""),
                           paste0(unlist(strsplit(as.character(pre.panel$VillGis[i]), ""))[1:6], collapse = ""))
}
pre.panel <- merge(pre.panel, gazetteer[,(names(gazetteer) %in% c("Name_EN", "Id"))], by.x = "commid", by.y = "Id", all.x = T)
names(pre.panel)[names(pre.panel)=="Name_EN" ] <- "comm_name"

#producing project count and ntl quantile statistic data frames by year/province

for(i in unique(pre.panel$ProvEn)) {
  temp <- as.data.frame(apply(pre.panel[which(pre.panel$ProvEn==i), grep("v4composite", names(pre.panel))], 2, as.numeric))
  
  sum.stats <- as.data.frame(matrix(data=NA, ncol = 8, nrow = 27))
  row.names(sum.stats) <- 1992:2018
  colnames(sum.stats) <- c("count", "pct.count", "0%", "25%", "Mean", "Median", "75%", "100%")
  
  for(j in unique(pre.panel$point.earliest.end.date)[!is.na(unique(pre.panel$point.earliest.end.date))]) {
    count <- nrow(pre.panel[which((pre.panel$ProvEn==i & pre.panel$point.earliest.end.date==j)),])
    sum.stats[grep(j, row.names(sum.stats)), 1] <- count
    sum.stats[grep(j, row.names(sum.stats)), 2] <- count/nrow(pre.panel[which(pre.panel$ProvEn==i & !is.na(pre.panel$point.earliest.end.date)),])
  }
  
  x <- as.data.frame(cbind(apply(temp, 2, mean, na.rm=T), t(apply(temp, 2, quantile, na.rm=T))))
  row.names(x) <-
    gsub("v4composites_calibrated_201709.", "", row.names(x)) %>%
    gsub(".mean", "", .)
  sum.stats[which(row.names(sum.stats) %in% row.names(x)),3:8] <- x[,c(2:3, 1, 4:6)]
  
  assign(paste0("sum_stats_", gsub(" ", "", i)), sum.stats)
  # write.csv(sum.stats, paste0("/Users/christianbaehr/Box Sync/cambodia_eba_gie/descriptive_stats/summary_stats/", gsub(" ", "", i), ".csv"))
}

names(pre.panel) <- 
  gsub("v4composites_calibrated_201709.", "ntl_", names(pre.panel)) %>%
  gsub(".mean", "", .)
pre.panel <- pre.panel[!is.na(pre.panel$VillGis),]
pre.panel[paste0("standardized_ntl_", 1992:2013)] <- apply(pre.panel[,grep("ntl_", names(pre.panel))], 2, 
                                                           function(x) {x/max(x)})

panel <- reshape(data = pre.panel, direction = "long", varying = list(paste0("ntl_", 1992:2013),
                                                                      paste0("standardized_ntl_", 1992:2013)),
                 idvar = "panel_id", sep = "_", timevar = "year")
names(panel)[names(panel)=="ntl_1992"] <- "ntl"
names(panel)[names(panel)=="standardized_ntl_1992"] <- "standardized_ntl"


# write.csv(panel, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel.csv", row.names = F)
panel <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel.csv", stringsAsFactors = F)

###################

panel2 <- reshape(data = pre.panel, direction = "long", varying = list(paste0("ntl_", 2003:2013),
                                                                       paste0("standardized_ntl_", 2003:2013),
                                                                       paste0("box.count", 2003:2013),
                                                                       paste0("point.count", 2003:2013),
                                                                       paste0("ltdr_avhrr_yearly_ndvi.", 2003:2013),
                                                                       paste0("udel_air_temp_v4_01_yearly.", 2003:2013),
                                                                       paste0("udel_precip_v4_01_yearly.", 2003:2013)),
                  idvar = "panel_id", timevar = "year")

names(panel2)[names(panel2)=="ntl_2003"] <- "ntl" 
names(panel2)[names(panel2)=="standardized_ntl_2003"] <- "standardized_ntl"
names(panel2)[names(panel2)=="box.count2003"] <- "box_count"
names(panel2)[names(panel2)=="point.count2003"] <- "point_count"
names(panel2)[names(panel2)=="ltdr_avhrr_yearly_ndvi.2003"] <- "ndvi"
names(panel2)[names(panel2)=="udel_air_temp_v4_01_yearly.2003"] <- "temp"
names(panel2)[names(panel2)=="udel_precip_v4_01_yearly.2003"] <- "precip"

# write.csv(panel2, file = "/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel2.csv", row.names = F)





