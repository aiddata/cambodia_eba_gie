
library(readxl)

pid <- read.csv("~/box sync/cambodia_eba_gie/PID/completed_pid/pid_merge.csv",stringsAsFactors = F)
pid <- pid[pid$actual.end.yr!=1908 | is.na(pid$actual.end.yr),]
gazetteer <- as.data.frame(read_excel("~/GitHub/cambodia_eba_gie/inputData/National Gazetteer 2014.xlsx", 
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
  read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ListSubSector.xlsx") %>%
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
cdb <- read_excel("~/Box Sync/cambodia_eba_gie/inputData/CDB_merged_final.xlsx")
shape <- read.csv("~/Desktop/shape_data.csv", stringsAsFactors = F)

sum(cdb$VillGis %in% shape$vill_code)
cdb <- merge(cdb, shape, by.x = "VillGis", by.y = "vill_code")

hist(cdb$MAL_TOT[cdb$MAL_TOT<10000])
which(cdb$MAL_TOT>10000)
# View(cdb[cdb$VillGis==cdb$VillGis[65740],])
#get some weird results when comparing high pop village population by year, ie row 65740

cdb <- cdb[-c(6650, 15070, 19122),]
# villages 65731 65732 65733 65734 65736 65738 65739 65740 65744 OK

which(cdb$MOTO_NUM>10000)
# View(cdb[cdb$VillGis==cdb$VillGis[65729],])

which(cdb$Crim_case>100)
View(cdb[cdb$VillGis==cdb$VillGis[66617], "Crim_case"])
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

test1 <- read.csv("~/box sync/cambodia_eba_gie/inputdata/village_grid_files/grid_1000_matched_data.csv")
test2 <- read.csv("~/box sync/cambodia_eba_gie/inputdata/village_grid_files/merge_grid_1000_lite.csv")




