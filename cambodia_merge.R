#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Merging Project Information Database treatment data with covariate data from the Commune Database and 
# spatio-temporal data measuring nighttime light of Cambodia from GeoQuery
#------------------------------

library(plyr)
library(readxl)
library(stringr)

setwd("~/box sync/cambodia_eba_gie")

pid2016 <- read.csv("pid/completed_pid/pid_2016.csv", stringsAsFactors = F)
pid2012 <- read.csv("pid/completed_pid/pid_2012.csv", stringsAsFactors = F)
pid2008 <- read.csv("pid/completed_pid/pid_2008.csv", stringsAsFactors = F)
pid <- rbind.fill(pid2016, pid2012, pid2008)
# write.csv(pid, "~/box sync/cambodia_eba_gie/PID/completed_pid/pid_merge.csv", row.names = F)
# pid <- read.csv("pid/completed_pid/pid_merge.csv",stringsAsFactors = F)

pid <- pid[pid$actual.end.yr!=1908 | is.na(pid$actual.end.yr),]
gazetteer <- as.data.frame(read_excel("inputdata/National Gazetteer 2014.xlsx", 
                                                        sheet = 4))
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

pid$subsector <-
  read_excel("pid/pid_excel_2012/ListSubSector.xlsx") %>%
  merge(pid, ., by.x = "activity.type", by.y = "Name_EN", all.x = T) %>%
  .$Id

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
cdb <- read_excel("inputdata/CDB_merged_final.xlsx")[,c("VillGis", "Year", "MAL_TOT", "FEM_TOT")]
shape <- read.csv("inputdata/village_grid_files/village_data.csv", stringsAsFactors = F)

sum(cdb$VillGis %in% shape$VILL_CODE)
cdb <- merge(cdb, shape, by.x = "VillGis", by.y = "VILL_CODE")
cdb$TOTPOP <- as.numeric(cdb$MAL_TOT) + as.numeric(cdb$FEM_TOT)

hist(cdb$MAL_TOT[cdb$MAL_TOT<10000])
which(cdb$MAL_TOT>10000)

# View(cdb[cdb$VillGis==cdb$VillGis[65740],])
#get some weird results when comparing high pop village population by year, ie row 65740

which(cdb$TOTPOP>15000)
View(cdb[cdb$VillGis==cdb$VillGis[21815],])
cdb <- cdb[-c(6621, 15299, 21815),]

#cdb <- cdb[-c(6650, 15070, 19122),]
# villages 65731 65732 65733 65734 65736 65738 65739 65740 65744 OK

which(cdb$MOTO_NUM>10000)
# View(cdb[cdb$VillGis==cdb$VillGis[65729],])

which(cdb$Crim_case>100)
#View(cdb[cdb$VillGis==cdb$VillGis[66617], "Crim_case"])
# cdb <- cdb[-c(2449, 66617),]

which(cdb$Crim_case>40)
# View(cdb[cdb$VillGis==cdb$VillGis[34887], "Crim_case"])


###################

length(unique(pid$vill.id))
sum(pid$vill.id %in% cdb$VillGis) * length(unique(cdb$Year))
data <- merge(cdb, pid, by.x = "VillGis", by.y = "vill.id")

# pid$vill.id[3]
# View(pid[pid$vill.id==pid$vill.id[3],])
# View(cdb[cdb$VillGis==pid$vill.id[3],])
# View(test[test$VillGis==pid$vill.id[3],])

###################

rm(list = setdiff(ls(), "data"))

grid_1000_matched_data <- read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv",
                                   stringsAsFactors = F)
merge_grid_1000_lite <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv",
                                 stringsAsFactors = F)
grid_1000_matched_data <- merge(grid_1000_matched_data, merge_grid_1000_lite, by = "cell_id")
rm(merge_grid_1000_lite)

sum(is.na(data$actual.end.yr))
data <- data[!is.na(data$actual.end.yr),]

###################

#grid_1000_matched_data$village_point_ids <- as.character(as.numeric(grid_1000_matched_data$village_point_ids))
id.list <- list()
for(i in 1:nrow(grid_1000_matched_data)) {
  if(grid_1000_matched_data$village_point_ids[i]=="") {
    id.list[[i]] <- ""
  } else {
    id.list[[i]] <- as.character(as.numeric(unlist(strsplit(grid_1000_matched_data$village_point_ids[i], split = "\\|"))))
  }
}

proj.geo <- cbind(data[1,c(1:2, 140:175)], grid_1000_matched_data[1,c(1:6, which(grepl("v4composites", names(grid_1000_matched_data))))])
proj.geo[sort(paste0("pop", unique(data$Year)))] <- NA
proj.geo <- proj.geo[0,]

#i=data$VillGis[82]
#i=1020117
#i=3161501
count <- 1
for(i in unique(data$VillGis)) {
  temp <- data[data$VillGis==i,]
  temp$id <- seq(1, nrow(temp), 1)

  grid <- unlist(lapply(id.list, function(x) i %in% x))
  
  if(sum(grid) > 0) {
    #rows <- c(nrow(proj.geo)+1):(nrow(proj.geo)+length(unique(paste(temp$project.id, temp$contract.id))))
    rows <- c(nrow(proj.geo)+1):(nrow(proj.geo)+sum(grid))
    
    
    #temp$TOTPOP[order(unique(temp$Year))]
    #may have to edit this further if the shorter vectors dont properly house in the df
    proj.geo[rows, ] <- c(temp[1, c(1:2, 140:175)],
                          grid_1000_matched_data[grid, c(1:6, grep("v4composites", names(grid_1000_matched_data)))])
    
    proj.geo[rows, paste0("pop", sort(unique(temp$Year)))] <- temp$TOTPOP[order(unique(temp$Year))]
    
    if(length(temp$TOTPOP[order(unique(temp$Year))]) < 9) {
      proj.geo[rows, paste0("pop", unique(data$Year)[!(unique(data$Year) %in% temp$Year)])] <- NA
    }
    
    # str(c(temp[1, c(1:2, 140:175)],
    #       grid_1000_matched_data[rows, c(1:6, which(grepl("v4composites", names(grid_1000_matched_data))))],
    #       temp$TOTPOP[order(temp$Year)[seq(1, length(temp$Year), 2)]]))
    # 
    # str(grid_1000_matched_data[rows, c(1:6, which(grepl("v4composites", names(grid_1000_matched_data))))])
    # str(temp$TOTPOP[order(temp$Year)[seq(1, length(temp$Year), 2)]])
    # str(temp[1, c(1:2, 140:175)])
    
    proj.geo$first.end.date[rows] <- min(temp$actual.end.yr, na.rm = T)
  }
  
  # grid_1000_matched_data$earliest
  # 
  # min(temp$actual.end.yr)
  
  # for(j in unique(temp$actual.end.yr)) {
  #   
  #   temp2 <- temp[temp$actual.end.yr==j,]
  #   n.proj <- length(unique(temp2$contract.id))
  #   
  # }

  if(count %% 1000==0) {
    cat(count, "of", length(unique(data$VillGis)), "\n")
  }
  count <- count+1
}

proj.geo<- proj.geo[,!(names(proj.geo) %in% c("XCOOR", "YCOOR", "latitude", "longitude", "ProvKH", "DistTypeKh", 
                                               "DistKh", "CommTypeKh", "Name_KH"))]

names(proj.geo)[grepl("v4c", names(proj.geo))] <- paste0("ntl", 1992:2013)

write.csv(proj.geo, "processeddata/pid_geo_merge.csv", row.names = F)
