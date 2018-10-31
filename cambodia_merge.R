#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Merging Project Information Database treatment data with covariate data from the Commune Database and 
# spatio-temporal data measuring nighttime light of Cambodia from GeoQuery
#------------------------------

setwd("~/box sync/cambodia_eba_gie")

library(plyr)
library(readxl)
library(stringr)

# pid2016 <- read.csv("pid/completed_pid/pid_2016.csv", stringsAsFactors = F)
# pid2012 <- read.csv("pid/completed_pid/pid_2012.csv", stringsAsFactors = F)
# pid2008 <- read.csv("pid/completed_pid/pid_2008.csv", stringsAsFactors = F)
# pid <- rbind.fill(pid2016, pid2012, pid2008)
# common.index <- sort(unique(pid2008$activity.type)[which(((unique(pid2008$activity.type) %in% unique(pid2012$activity.type)) &
#                                                (unique(pid2008$activity.type) %in% unique(pid2016$activity.type))))])
# common.index <- cbind(common.index, seq(1, length(common.index), 1))
# pid <- pid[,!(names(pid)=="activity.type.num")]
# pid <- merge(pid, common.index, by.x="activity.type", by.y="common.index", all.x = T)
# names(pid)[names(pid)=="V2"] <- "activity.type.num"
# pid$activity.type.num <- as.numeric(pid$activity.type.num)
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

grid_1000_matched_data <- read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv",
                                   stringsAsFactors = F)
merge_grid_1000_lite <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv",
                                 stringsAsFactors = F)
grid_1000_matched_data <- merge(grid_1000_matched_data, merge_grid_1000_lite, by = "cell_id")

###################

rm(list = setdiff(ls(), c("data", "cdb", "grid_1000_matched_data")))

id.list <- list()
id.list2 <- list()
for(i in 1:nrow(grid_1000_matched_data)) {
  if(grid_1000_matched_data$village_point_ids[i]=="") {
    id.list[[i]] <- ""
  } else {
    id.list[[i]] <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_point_ids[i], split = "\\|"))))
  }
  
  if(grid_1000_matched_data$village_box_ids[i]=="") {
    id.list2[[i]] <- ""
  } else {
    id.list2[[i]] <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_box_ids[i], split = "\\|"))))
  }
}

trimmed.data <- data[,c(grep("VillGis", names(data)), (grep("latitude", 
                                                            names(data)):length(names(data))))]
trimmed.grid <- grid_1000_matched_data[,c(grep("cell_id", names(grid_1000_matched_data)), 
                                          grep("v4composites", names(grid_1000_matched_data)))]
stats.data <- cbind(trimmed.data[0,], trimmed.grid[0,])

for(i in 1:nrow(trimmed.grid)) {
  temp <- trimmed.data[(trimmed.data$VillGis %in% id.list2[[i]]),]
  if(nrow(temp)>0) {
    x<-((nrow(stats.data)+1):(nrow(stats.data)+nrow(temp)))
    stats.data[x, (names(stats.data) %in% names(temp))] <- temp
    
    stats.data[x, (names(stats.data) %in% names(trimmed.grid))] <- trimmed.grid[i,]
  }
  if(i %% 1000 == 0){cat(i, "of", nrow(trimmed.grid), "\n")}
}

###################

#producing project count and ntl quantile statistic data frames by year/province

for(i in unique(stats.data$ProvEn)) {
  temp <- as.data.frame(apply(stats.data[stats.data$ProvEn==i, grep("v4composite", names(stats.data))], 2, as.numeric))
  
  sum.stats <- as.data.frame(cbind(apply(temp, 2, mean, na.rm=T), t(apply(temp, 2, quantile, na.rm=T))))
  row.names(sum.stats) <- gsub("v4composites_calibrated_201709.", "", row.names(sum.stats)) %>%
    gsub(".mean", "", .)
  sum.stats$count <- NA

  for(j in 1:length(unique(stats.data$actual.end.yr))) {
    year <- unique(stats.data$actual.end.yr)[j]
    count <- nrow(stats.data[(stats.data$ProvEn==i & stats.data$actual.end.yr==year),])
    sum.stats$count[grep(year, row.names(sum.stats))] <- count
  }
  sum.stats2 <- sum.stats[,c("count", "0%", "25%", "V1", "50%", "75%", "100%")]
  colnames(sum.stats2) <- c("count", "0%", "25%", "Mean", "Median", "75%", "100%")
  assign(paste0("sum_stats_", i), sum.stats2)
  #write.csv(sum.stats2, paste0("/Users/christianbaehr/desktop/sum_stats/", gsub(" ", "", i), ".csv"))
}

###################

#producing stacked bar plots of activity type by year/province

for(i in unique(stats.data$ProvEn)) {
  temp <- stats.data[which((stats.data$ProvEn==i & !is.na(stats.data$activity.type) & !is.na(stats.data$actual.end.yr))),]
  if(nrow(temp)>1) {
    temp.mat <- as.data.frame(matrix(0, ncol = 11, nrow = 16))
    a <- stats.data[!duplicated(stats.data[,c("activity.type", "activity.type.num")]), 
                    c("activity.type", "activity.type.num")]
    a <- a[!is.na(a$activity.type.num),]
    names(temp.mat) <- a$activity.type[match(c(1:11), a$activity.type.num)]
    row.names(temp.mat) <- c(2003:2018)
    
    for(j in unique(temp$actual.end.yr)) {
      temp2 <- temp[which(temp$actual.end.yr==j),]
      x <- table(temp2$activity.type.num)
      temp.mat[(row.names(temp.mat)==j), as.numeric(names(x))] <- table(temp2$activity.type.num)
    }
    png(paste0("/Users/christianbaehr/desktop/activity_plots/activity_", gsub(" ", "", i), ".png"))
    barplot(t(as.matrix(temp.mat))[colSums(temp.mat)>0,], main = paste("Activity Type Distribution,", i),
            xlab = "Year", ylab = "Number of Projects", 
            col = c(1:nrow(t(as.matrix(temp.mat)))))
    legend("topright", legend=row.names(t(as.matrix(temp.mat)))[colSums(temp.mat)>0], cex = 0.5, 
           fill = c(1:nrow(t(as.matrix(temp.mat)))))
    dev.off()
  }
}

###################


#i=data$VillGis[82]
#i=1020117
#i=3161501

# which(data$VillGis %in% grid_1000_matched_data$village_point_ids[24981])
# data$VillGis[20533]
# grid_1000_matched_data$village_point_ids[24981]
# which(unique(data$VillGis)==data$VillGis[20533])
# i=unique(data$VillGis)[6225]

#data <- data[!duplicated(data[,!(names(data) %in% c("pid_id", "id"))])]
# dups <- data[duplicated(data[,!(names(data) %in% c("pid_id", "id"))]),]

# proj.geo <- cbind(data[1,c(grep("VillGis",names(data)),grep("TOTPOP",names(data)),grep("latitude",names(data)):length(names(data)))], 
#                   grid_1000_matched_data[1,c(1:6,grep("v4composites", names(grid_1000_matched_data)))])
# proj.geo[sort(paste0("pop", unique(cdb$Year)))] <- NA
proj.geo <- proj.geo2 <- cbind(data[1,c(grep("VillGis",names(data)), grep("latitude",names(data)):length(names(data)))],
                  grid_1000_matched_data[1, c(1:6,grep("v4composites", names(grid_1000_matched_data)))])
proj.geo[paste0("trt.count", 2003:2018)] <- proj.geo[paste0("trt.cs.fund", 2003:2018)] <- 
  proj.geo[paste0("trt.local.cont", 2003:2018)] <- proj.geo[c("cs.sum", "lc.sum")] <- NA
proj.geo2 <- proj.geo <- proj.geo[0,]

count <- 1
for(i in unique(data$VillGis)) {
  temp <- data[data$VillGis==i,]
  #temp$id <- seq(1, nrow(temp), 1)
  #cdbtemp <- cdb[cdb$VillGis==i,]
  
  grid <- unlist(lapply(id.list, function(x) i %in% x))
  grid2 <- unlist(lapply(id.list2, function(x) i %in% x))
  
  if(sum(grid) > 0) {
    rows <- c((nrow(proj.geo)+1):(nrow(proj.geo)+sum(grid)))

    #may have to edit this further if the shorter vectors dont properly house in the df
    proj.geo[rows, ] <- cbind(temp[, c(grep("VillGis",names(data)),grep("TOTPOP",names(data)),grep("latitude",names(data)):length(names(data)))],
                          grid_1000_matched_data[grid, c(1:6, grep("v4composites", names(grid_1000_matched_data)))])
      
    proj.geo[rows, paste0("pop", sort(unique(cdbtemp$Year)))] <- cdbtemp$TOTPOP[order(unique(cdbtemp$Year))]
    
    if(length(temp$TOTPOP[order(unique(temp$Year))]) < 9) {
      proj.geo[rows, paste0("pop", unique(data$Year)[!(unique(data$Year) %in% temp$Year)])] <- NA
    }
    proj.geo$first.end.date[rows] <- min(temp$actual.end.yr, na.rm = T)
  }
  
  if(sum(grid2) > 0) {
    rows2 <- c((nrow(proj.geo2)+1):(nrow(proj.geo2)+sum(grid2)))
    
    proj.geo2[rows2, c(grep("VillGis", names(proj.geo2)):
                        grep("project.length", names(proj.geo2)))] <- temp[1,c(match(names(proj.geo2)[c(grep("VillGis", names(proj.geo2)):
                                                                                                         grep("project.length", names(proj.geo2)))], names(temp)))]
    
    proj.geo2[rows2, c(grep("cell_id", names(proj.geo2)):
                         grep("v4composites_calibrated_201709.2013.mean"))] <-
      grid_1000_matched_data[rows2, match(names(proj.geo2)[c(grep("cell_id", names(proj.geo2)):grep("v4composites_calibrated_201709.2013.mean", names(proj.geo2)))],
                                          names(grid_1000_matched_data))]
    
    proj.geo2[rows2, "cs.sum"] <- sum(temp$cs.fund)/sum(grid2)
    proj.geo2[rows2, "lc.sum"] <- sum(temp$local.cont)/sum(grid2)
    
    for(j in 2003:2018) {
      
      proj.geo2[rows2, grep(paste0("trt.local.cont", j), names(proj.geo2))] <- temp$local.cont[temp$actual.end.yr==j]
   
    }
  }
  # if(sum(grid2) > 0) {
  #   rows <- c(nrow(proj.geo2)+1)
  #   temp2 <- proj.geo2[0,]
  #   
  #   temp2[rows, ] <- c(temp[1, c(1:2, 140:175)],
  #                      grid_1000_matched_data[grid2, c(1:6, grep("v4composites", names(grid_1000_matched_data)))])
  #   
  #   temp2[rows, paste0("pop", sort(unique(temp$Year)))] <- temp$TOTPOP[order(unique(temp$Year))]
  #   
  #   if(length(temp$TOTPOP[order(unique(temp$Year))]) < 9) {
  #     temp2[rows, paste0("pop", unique(data$Year)[!(unique(data$Year) %in% temp$Year)])] <- NA
  #   }
  #   proj.geo2[(nrow(proj.geo2)+1),] <- temp2[which.min(temp2$actual.end.yr),]
  #   #proj.geo2$first.end.date[rows] <- min(temp$actual.end.yr, na.rm = T)
  # }
  if(count %% 1000==0) {cat(count, "of", length(unique(data$VillGis)), "\n")}
  count <- count+1
}

proj.geo<- proj.geo[,!(names(proj.geo) %in% c("XCOOR", "YCOOR", "latitude", "longitude", "ProvKH", "DistTypeKh",
                                              "DistKh", "CommTypeKh", "Name_KH"))]
names(proj.geo)[grepl("v4c", names(proj.geo))] <- paste0("ntl", 1992:2013)

# proj.geo <- reshape(data = proj.geo, varying = names(proj.geo)[c(grep("ntl", names(proj.geo)), grep("pop", names(proj.geo)))][17:28], 
#                 direction = "long", idvar = "VillGis", sep = "")
write.csv(proj.geo, "processeddata/pid_geo_merge.csv", row.names = F)

# proj.geo3 <- proj.geo2[0,]
# 
# for(i in unique(proj.geo2$cell_id)) {
#   temp <- proj.geo2[proj.geo2$cell_id==i,]
#   proj.geo3[(nrow(proj.geo3)+1),] <- temp[which.min(temp$actual.end.yr)[1],]
# }

proj.geo2 <- proj.geo2[,!(names(proj.geo2) %in% c("XCOOR", "YCOOR", "latitude", "longitude", "ProvKH", "DistTypeKh", 
                                                  "DistKh", "CommTypeKh", "Name_KH"))]
names(proj.geo2)[grepl("v4c", names(proj.geo2))] <- paste0("ntl", 1992:2013)
proj.geo2$cell.vill.id <- paste(proj.geo2$cell_id, proj.geo2$VillGis)
proj.geo2$uniqueid <- seq(1, nrow(proj.geo2), 1)
proj.geo2 <- reshape(data = proj.geo2, varying = names(proj.geo2)[c(grep("ntl", names(proj.geo2)), grep("pop", names(proj.geo2)))][17:28],
                     direction = "long", idvar = "cell.vill.id", sep = "")

write.csv(proj.geo2, "processeddata/pid_geo_merge2.csv", row.names = F)

proj.geo$trt <- ifelse(proj.geo$time >= proj.geo$actual.end.yr, 1, 0)
