
setwd("~/box sync/cambodia_eba_gie")
options(scipen = 8)

library(readxl)
library(XML)
library(dplyr)
library(stringr)

# data <- list()
# for(i in 1:25) {
#   for(j in 2013:2016) {
#       url <- paste0("http://db.ncdd.gov.kh/pid/reports/monitoring/contractsummary.castle?pv=", i, "&year=", j)
#       x <- readHTMLTable(url)
#       y <- x[[2]]
#       data[[paste0(j, i)]] <- y[-1,]
#   }
# }

#load the R list object including scraped pid data
load("PID/pid_excel_2016/pid_2016_r_list.RData")
#object 92 is empty
data=x[-92]
#creating skeleton dataset to store all 2016 pid data
data.pull <- as.data.frame(matrix(NA, nrow = 0, ncol = 17))

test.vector <- NA

#it may be best to select a test i value and run through each of these functions on that example to understand the work flow
for(i in 1:99) {
  #making all column classes character
  new.data <- mutate_all(data[[i]], as.character)
  
  #adding district data to all underlying rows
  new.data$district <- NA
  #identifying all unique districts in the data
  districts <- new.data$Commune[which(is.na(new.data$Village))]
  #identifying the index values associated with each district
  dist.rows <- c(which(is.na(new.data$Village)), nrow(new.data))
  
  for(j in 1:(length(dist.rows)-1)) {
    #adding district data to each row
    new.data$district[dist.rows[j]:dist.rows[j+1]] <- districts[j]
  }
  #removing the deprecated district rows
  new.data <- new.data[-dist.rows[-length(dist.rows)],]
  
  new.data$comm2 <- new.data$Commune
  #identifying unique communes
  communes <- new.data$Commune[which(new.data$Commune != "")]
  #identifying the index values associated with each commune
  comm.rows <- c(which(new.data$Commune != ""), nrow(new.data))
  
  #identifying unique villages, activities, cs.fund data, and local.cont data
  new.data$village.id <- NA
  villages <- new.data$Village[which(new.data$Commune != "")]
  new.data$activity <- NA
  activities <- new.data$Outputs[which(new.data$Commune != "")]
  new.data$cs.fund <- NA
  cs.fund <- new.data$`Total Value`[which(new.data$Commune != "")]
  new.data$local.cont <- NA
  local.cont <- new.data$`C/S Fund`[which(new.data$Commune != "")]
  
  #as a test, just pulling the raw local cont values from the data and testing the sum of these values
  #against the sum of local cont values from the actual dataset produced by this loop. We expect the sums
  #to be equivalent, indicating that the cs fund and local cont values have not been double counted
  test.vector[i] <- 
    new.data$`C/S Fund` %>%
    gsub("R", "", .) %>%
    gsub(",", "", .) %>%
    as.numeric() %>%
    sum(na.rm = T)
  
  for(k in 1:(length(comm.rows)-1)) {
    #adding commune, village, and activity data to each row
    new.data$comm2[comm.rows[k]:comm.rows[k+1]] <- communes[k]
    new.data$village.id[comm.rows[k]:comm.rows[k+1]] <- villages[k]
    new.data$activity[comm.rows[k]:comm.rows[k+1]] <- activities[k]
    
    #identifying the number that will be used to divide cs.fund and local.cont data
    y <- length(comm.rows[k]:comm.rows[k+1])-2
    
    #formatting the cs.fund and local.cont data so they can be included in computations
    cs.fund2 <- unlist(strsplit(cs.fund[k]," "))[1]
    cs.fund2 <- gsub(",", "", cs.fund2)
    local.cont2 <- unlist(strsplit(local.cont[k]," "))[1]
    local.cont2 <- gsub(",", "", local.cont2)
    
    #there was an indexing issue, so this if else clause is a long winded way of dividing cs.fund and local.cont data
    #to avoid double counting
    if(k+1==length(comm.rows)) {
      cs.fund2 <- as.numeric(cs.fund2)/(y+1)
      local.cont2 <- as.numeric(local.cont2)/(y+1)
    } else {
      cs.fund2 <- as.numeric(cs.fund2)/y
      local.cont2 <- as.numeric(local.cont2)/y
    }
    #including the divided cs.find and local.cont data in the new dataset
    new.data$cs.fund[comm.rows[k]:comm.rows[k+1]] <- cs.fund2
    new.data$local.cont[comm.rows[k]:comm.rows[k+1]] <- local.cont2
    
  }
  #removing deprecated commune data from the dataset
  new.data <- new.data[-comm.rows[-length(comm.rows)],]
  #first row of the dataset is empty
  new.data <- new.data[,-1]
  names(new.data)[names(new.data)=="comm2"] <- "commune"
  
  #pulling the new/repair data from the outputs column
  new.data$isNew <- NA
  for(m in 1:nrow(new.data)) {
    new.data$isNew[m] <- unlist(strsplit(new.data$Outputs[m], "]"))[1]
  }
  new.data$isNew <- gsub(" ", "", new.data$isNew)
  new.data$isNew <- gsub("\\[", "", new.data$isNew)
  
  #splitting the column id and name into separate rows
  new.data$commune.id <- matrix(unlist(str_split(new.data$commune, ", ")), ncol = 2, byrow = T)[,1]
  new.data$commune.name <- matrix(unlist(str_split(new.data$commune, ", ")), ncol = 2, byrow = T)[,2]
  
  #formatting the village.id variable
  new.data$vill.id <- 
    new.data$village.id %>%
    gsub("/", "", .) %>%
    gsub("-", "", .) %>%
    as.numeric()
  
  data[[i]] <- new.data
  #this loop indexes through each dataset in the list, formats the dataset, and then I append that formatted dataset onto the
  #skeleton dataset created at the top of the loop
  data.pull[(nrow(data.pull)+1):(nrow(data.pull)+nrow(new.data)),] <- new.data
  
  if(i==99) {
    #at the completion of the loop, pasting the names from the datasets in the list onto the new dataset
    names(data.pull) <- names(new.data)
  }
}
sum(test.vector)
sum(data.pull$local.cont)

rm(list=setdiff(ls(), "data.pull"))

pid2016 <- read_excel("PID/PID2019-2016-new.xlsx")
#had to read in the dates data separately, because R doesnt really allow you to pull in xlsx data with only some date columns
pid2016.dates <- read_excel("PID/PID2019-2016-new.xlsx", col_types = "date")
pid2016$ActualWorkCompletionOn <- pid2016.dates$ActualWorkCompletionOn
pid2016$ActualWorkStartOn <- pid2016.dates$ActualWorkStartOn

# length(unique(pid2016$Id))
# sum(data.pull$vill.id %in% pid2016$Id)
# sum(pid2016$Id %in% data.pull$vill.id)

#splitting dates data into year and month
pid2016$plannedstartyear[!is.na(pid2016$PlannedStartOn)] <- 
  matrix(unlist(str_split(as.character(pid2016$PlannedStartOn[!is.na(pid2016$PlannedStartOn)]), "-")), ncol=3, byrow=T)[,1]
pid2016$plannedstartmonth[!is.na(pid2016$PlannedStartOn)] <- 
  matrix(unlist(str_split(as.character(pid2016$PlannedStartOn[!is.na(pid2016$PlannedStartOn)]), "-")), ncol=3, byrow=T)[,2]

pid2016$actualstartyear[!is.na(pid2016$ActualWorkStartOn)] <- 
  matrix(unlist(str_split(as.character(pid2016$ActualWorkStartOn[!is.na(pid2016$ActualWorkStartOn)]), "-")), ncol=3, byrow=T)[,1]
pid2016$actualstartmonth[!is.na(pid2016$ActualWorkStartOn)] <- 
  matrix(unlist(str_split(as.character(pid2016$ActualWorkStartOn[!is.na(pid2016$ActualWorkStartOn)]), "-")), ncol=3, byrow=T)[,2]

pid2016$plannedendyear[!is.na(pid2016$PlannedCompletionOn)] <- 
  matrix(unlist(str_split(as.character(pid2016$PlannedCompletionOn[!is.na(pid2016$PlannedCompletionOn)]), "-")), ncol=3, byrow=T)[,1]
pid2016$plannedendmonth[!is.na(pid2016$PlannedCompletionOn)] <- 
  matrix(unlist(str_split(as.character(pid2016$PlannedCompletionOn[!is.na(pid2016$PlannedCompletionOn)]), "-")), ncol=3, byrow=T)[,2]

pid2016$actualendyear[!is.na(pid2016$ActualWorkCompletionOn)] <- 
  matrix(unlist(str_split(as.character(pid2016$ActualWorkCompletionOn[!is.na(pid2016$ActualWorkCompletionOn)]), "-")), ncol=3, byrow=T)[,1]
pid2016$actualendmonth[!is.na(pid2016$ActualWorkCompletionOn)] <- 
  matrix(unlist(str_split(as.character(pid2016$ActualWorkCompletionOn[!is.na(pid2016$ActualWorkCompletionOn)]), "-")), ncol=3, byrow=T)[,2]

#removing data with start year <=2012
pid2016 <- pid2016[as.numeric(pid2016$actualstartyear) > 2012,]
#merging the 2016 pid data Brad sent with the data scraped from PID website
pid2016 <- merge(pid2016, data.pull, by.x="Id", by.y="vill.id")

# test <- x[[1]]
# test$`C/S Fund` <- gsub(",", "", test$`C/S Fund`)
# sum(as.numeric(unlist(str_split(test$`C/S Fund`, " "))), na.rm = T)
# sum(data[[1]]$cs.fund)
# 
# test2 <- x[[6]]
# test2$`Local Contrib.` <- gsub(",", "", test2$`Local Contrib.`)
# sum(as.numeric(unlist(str_split(test2$`Local Contrib.`, " "))), na.rm = T)
# sum(data[[6]]$local.cont)
# 
# test3 <- x[[1]]
# test3$`Local Contrib.` <- gsub(",", "", test3$`Local Contrib.`)
# sum(as.numeric(unlist(str_split(test3$`Local Contrib.`, " "))), na.rm = T)
# sum(data[[1]]$local.cont)

#reading in gazetteer data to use as a reference. We want to merge pid data with gazetteer so we can get good 
#village Ids
gazetteer.vill <- as.data.frame(read_excel("inputdata/National Gazetteer 2014.xlsx", sheet = 4))
gazetteer.comm <- as.data.frame(read_excel("inputdata/National Gazetteer 2014.xlsx", sheet = 3))
gazetteer.vill$commid <- NA
#retrieving gazetteer commune IDs from the first few characters of the village Ids
for(i in 1:nrow(gazetteer.vill)) {
  if(nchar(gazetteer.vill$Id[i])==7) {
    gazetteer.vill$commid[i] <- paste0(unlist(strsplit(as.character(gazetteer.vill$Id[i]), ""))[1:5], collapse = "")
  } else {
    gazetteer.vill$commid[i] <- paste0(unlist(strsplit(as.character(gazetteer.vill$Id[i]), ""))[1:6], collapse = "")
  }
}
gazetteer.full <- merge(gazetteer.vill, gazetteer.comm, by.x = "commid", by.y = "Id")

#pasting commune and village name in same column to avoid duplicate mismatches
gazetteer.full$commvill <- paste(gazetteer.full$Name_EN.y, gazetteer.full$Name_EN.x)
commvill.dups <- gazetteer.full$commvill[duplicated(gazetteer.full$commvill)]
pid2016$commvill <- paste(pid2016$commune.name, pid2016$Village)

#removing duplicate commune-village names and only keeping pid data which has corresponding commune-village name in gazetteer
pid2016 <- pid2016[(pid2016$commvill %in% gazetteer.full$commvill),]
pid2016 <- pid2016[!(pid2016$commvill %in% commvill.dups),]

x <- merge(pid2016, gazetteer.full, by = "commvill")

pid2016$village.id <- x$Id.y

#only keeping necessary pid variables and renaming as necessary
pid2016 <- pid2016[,c("Reference", "Id", "activity", 
                      "SubSectorId", "isNew", "plannedstartyear", "plannedstartmonth",
                      "actualstartyear", "actualstartmonth", "plannedendyear", "plannedendmonth",
                      "actualendyear", "actualendmonth", "Bidders", "cs.fund", "local.cont",
                      "village.id")]

names(pid2016) <- c("project.id", "contract.id", "activity.type", "subsector",
                    "new.repair", "planned.start.yr", "planned.start.mo",
                    "actual.start.yr", "actual.start.mo", "planned.end.yr", "planned.end.mo",
                    "actual.end.yr", "actual.end.mo", "n.bidders", "cs.fund", "local.cont", "vill.id") 
#not sure this project and contract ids are accurate
#no activity description, last report, or progress
#generate bid dummy?

# fun <- function(x) {
#   length(unique(x))
# }
# 
# apply(pid2016, 2, fun)

write.csv(pid2016, "PID/completed_pid/pid_2016.csv", row.names = F)

#these were the names (in order) of each province from the data I pulled so I kept these as reference
# names <- c("Banteay Meanchey", "Battambang", "Kampong Cham", "Kampong Chhnang", "Kampong Speu", "Kampong Thom", "Kampot", 
#   "Kandal", "Koh Kong", "Kratie", "Mondul Kiri", "Phnom Penh", "Preah Vihear", "Prey Veng", "Pursat", "Ratanak Kiri", 
#   "Siemreap", "Preah Sihanouk", "Stung Treng", "Svay Rieng", "Takeo", "Oddar Meanchey", "Kep", "Pailin", "Tboung Khmum")

#save(x, file = "~/Box Sync/cambodia_eba_gie/PID/pid_excel_2016/pid_2016_r_list.RData")
# for(i in 1:100) {
#   assign(names(data)[i], data[[i]])
#   
#   write.csv(assign(names(data)[i], data[[i]]), paste("2016pid", names(data)[i], ".csv"), row.names = F)
# }

