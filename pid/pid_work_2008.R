#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Compiling Project Information Database (from Cambodia) for 2003-2008
# Will use project completion dates to create treatment info
#------------------------------

setwd("~/box sync/cambodia_eba_gie")

library(readxl)
library(stringr)

###########################
## Read in main "contract" file with one entry per contract id (can be multiple contracts per project id)
## And add in additional information from other files from Cambodia Access database
###########################

contract <- read_excel("pid/pid_excel_2008/Contract.xlsx")
length(unique(contract$ContractID))
progress <- read_excel("pid/pid_excel_2008/Progress.xlsx")

#iterating through all unique contract IDs in the progress dataset to identify, for each unique ID, the last date a progress report was
#submitted and the progress value assigned in that report
#will use report date as project end date when actual end date is missing AND progress value is 100%
contract[,c("last.report", "progress")] <- NA
for(i in unique(progress$ContractID)) {
  temp.contract <- contract[contract$ContractID==i,]
  temp.progress <- progress[progress$ContractID==i,]
  
  temp.contract[,c("last.report", "progress")] <- matrix(rep(c(as.character(temp.progress$ReportDate[which.max(temp.progress$ReportDate)]),
                                                               as.character(temp.progress$Progress[which.max(temp.progress$ReportDate)])), 
                                                             nrow(temp.contract)), ncol=2, byrow=T)
  #filling the observations in the contract dataset with the specific contract ID with the contents of the matrix
  #generated previously
  contract[contract$ContractID==i,c("last.report","progress")] <- temp.contract[,c("last.report","progress")]
}

## Identifying Project ID associated with Contract
contract.output <- read_excel("pid/pid_excel_2008/ContractOutput.xlsx")
#remove duplicate observations from the contract.output dataset to identify project id for each contract
contract.output <- contract.output[!duplicated(contract.output$ContractID),c("ContractID", "linkProjectID")]
#merge "linkProjectID" into main contract dataset
contract <- merge(contract, contract.output, by="ContractID")

## Adding changed/updated contract end dates from "amendment" file
amendment <- read_excel("pid/pid_excel_2008/Amendment.xlsx")
#check for duplicate contract ids
length(unique(amendment$ContractID))

#this chunk is where I replace applicable actual.end.dates in the main dataset with end dates from the amendments dataset
amendment$rm <- NA
for(i in unique(amendment$ContractID)) {
  temp.amend <- amendment[amendment$ContractID==i,]
  if(nrow(temp.amend)>1) {
    #making sure the date we are using from the amendments dataset is the most "up to date" amended end date given duplicate Contract IDs
    temp.amend$rm <- ifelse(temp.amend$New_End_Date==max(temp.amend$New_End_Date), 0, 1)
  } else {temp.amend$rm <- 0}
  amendment[amendment$ContractID==i,] <- temp.amend
}
amendment <- amendment[amendment$rm==0,]
#eliminate duplicate Contract ID (had same end date so wasn't eliminated by max New_End_Date code above)
amendment <- amendment[-306,]

contract <- merge(contract, amendment, by="ContractID", all.x = T)

###################
## Merge in Ancillary Information at Project Level
##################

## Merging ancillary datasets with the project output dataset to get descriptive information

output <- read_excel("pid/pid_excel_2008/Output.xlsx")
#identify specific activities for contracts using Output ID
project.output <- read_excel("pid/pid_excel_2008/ProjectOutput.xlsx")
sum(output$OutputID %in% project.output$OutputID)
#merge sector info into project.output
project.output <- merge(project.output, output, by.x="OutputID", by.y="OutputID")

#identify and merge in output type info (e.g. new, repair) 
output.type <- read_excel("pid/pid_excel_2008/OutputType.xlsx")
sum(project.output$isNew %in% output.type$OPTypeID)
project.output <- merge(project.output, output.type, by.x="isNew", by.y="OPTypeID")

length(unique(paste(project.output$OutputID, project.output$ProjectID)))

#identify project + order number activities, merge into project.output
table3 <- read_excel("pid/pid_excel_2008/Table3.xlsx")
table3 <- table3[!duplicated(table3$OutputID),]
sum(project.output$OutputID %in% table3$OutputID)
project.output <- merge(project.output, table3, by.x="OutputID", by.y="OutputID")

#identify sub-sector for each project + order number
output.categories <- read_excel("pid/pid_excel_2008/OutputCategories.xlsx")
sum(project.output$CategoryID %in% output.categories$ID)
project.output <- merge(project.output, output.categories, by.x="CategoryID", by.y="ID")


## Merging project output dataset (multiple rows per project) with the project dataset (one row per project, project-level data)

#get overall project sector info
#Project dataset only has one row per project
project <- read_excel("pid/pid_excel_2008/Project.xlsx")
proj.type <- read_excel("pid/pid_excel_2008/ProjType.xlsx")
sum(project$ProjTypeID %in% proj.type$ProjTypeID)
#merge in ProjTypeID classification, which gives overall project sector
project <- merge(project, proj.type, by.x="ProjTypeID", by.y="ProjTypeID")

rm(list=setdiff(ls(), c("contract", "project", "project.output")))

#merge project output (multiple rows per project) with project information, which will repeat over duplicate projects
project <- merge(project, project.output, by.x="ProjectID", by.y="ProjectID")

#changing the classes of date variables to character
x <- unlist(lapply(project, class))
project[,x[!(x=="POSIXt")]=="POSIXct"] <- lapply(project[,x[!(x=="POSIXt")]=="POSIXct"], as.character)

##########################
## Merge Project and Contract Data
##########################

## Merge Project and Contract data (multiple contracts per project AND multiple villages per contract)
# Want to end up with unique project/contract/order identifier

#creating skeleton dataset to merge project and contract data
proj.cont <- cbind(project[0,], contract[0,])
proj.cont <- proj.cont[,!(names(proj.cont)=="linkProjectID")]

#merging contract and project data
for(i in unique(contract$linkProjectID)) {
  #subsetting the project/contract datasets to only the observations with Project ID equal to i
  temp.contract <- contract[contract$linkProjectID==i,]
  temp.project <- project[project$ProjectID==i,]
  
  if(nrow(temp.project)!=0) {
    #dividing the CS fund and local contribution columns by the number of rows in the temporary project dataset so when the datasets are
    #merged, these contribution numbers arent double counted
    temp.contract[,c("FundCS", "FundLocalContr", "linkProjectID")] <- as.data.frame(matrix(c(temp.contract$FundCS/(nrow(temp.project)*nrow(temp.contract)),
                                                                                             temp.contract$FundLocalContr/(nrow(temp.project)*nrow(temp.contract)),
                                                                                             temp.contract$linkProjectID), ncol = 3))
    
    
    # as.data.frame(matrix(rep(c(sum(temp.contract$FundCS)/nrow(temp.project),
    #                        sum(temp.contract$FundLocalContr)/nrow(temp.project),
    #                        temp.contract$linkProjectID), ), ncol = 3))
    # 
    
    
    
    
    
    
    #merging subsetted project and contract data
    temp.project2 <- merge(temp.project[!duplicated(temp.project$VillGis),], temp.contract, by.x="ProjectID", by.y="linkProjectID")
    
    for(j in unique(temp.project2$VillGis)) {
      temp.project2$FundCS[temp.project2$VillGis==j] <- sum(temp.contract$FundCS)*(nrow(temp.project[temp.project$VillGis==j,]))
      temp.project2$FundLocalContr[temp.project2$VillGis==j] <- sum(temp.contract$FundLocalContr)*(nrow(temp.project[temp.project$VillGis==j,]))
    }
    
    #including subsetted project and contract data in the skeleton dataset created above the loop
    proj.cont[(nrow(proj.cont)+1):(nrow(proj.cont)+nrow(temp.project2)),] <- temp.project2
  }
}

## Clean Up Data for later analysis

proj.cont$EndDate[!(is.na(proj.cont$New_End_Date))] <- proj.cont$New_End_Date[!(is.na(proj.cont$New_End_Date))]

#splitting up the data data into separate month and year columns
proj.cont$plannedstartyear <- matrix(unlist(str_split(as.character(proj.cont$StartDate), "-")), ncol = 3, byrow = T)[,1]
proj.cont$plannedstartmonth <- matrix(unlist(str_split(as.character(proj.cont$StartDate), "-")), ncol = 3, byrow = T)[,2]

proj.cont$plannedendyear <- matrix(unlist(str_split(as.character(proj.cont$EndDate), "-")), ncol = 3, byrow = T)[,1]
proj.cont$plannedendmonth <- matrix(unlist(str_split(as.character(proj.cont$EndDate), "-")), ncol = 3, byrow = T)[,2]
proj.cont$actualendyear[!is.na(proj.cont$CompletionDate)] <- 
  matrix(unlist(str_split(as.character(proj.cont$CompletionDate[!is.na(proj.cont$CompletionDate)]), "-")), ncol = 3, byrow = T)[,1]
proj.cont$actualendmonth[!is.na(proj.cont$CompletionDate)] <- 
  matrix(unlist(str_split(as.character(proj.cont$CompletionDate[!is.na(proj.cont$CompletionDate)]), "-")), ncol = 3, byrow = T)[,2]

# cont.abandon <- read_excel("~/box sync/cambodia_eba_gie/pid/pid_excel_2008/tblcontract_abandon.xlsx")
# proj.cont <- merge(proj.cont, cont.abandon, by.x = "ContractID", by.y = "ContractID", all.x = T)

# sum(is.na(proj.cont$actualendyear))
# sum(is.na(proj.cont$FY))
# sum(is.na(proj.cont$actualendyear) & proj.cont$progress=="100" & !is.na(proj.cont$last.report)) #####add this

#for rows with missing actual completion dates, proxying with the last report date if the last report progress was equal to 100
for(i in 1:nrow(proj.cont)) {
  if(!is.na(proj.cont$progress[i])) {
    if(is.na(proj.cont$actualendyear[i]) & proj.cont$progress[i]=="100") {
      proj.cont$actualendyear[i] <- proj.cont$last.report[i]
      proj.cont$actualendyear[i] <- unlist(strsplit(proj.cont$actualendyear[i], "-"))[1]
    }
  }
}

sum(is.na(proj.cont$actualendyear))
#View(proj.cont[,c("ContractID", "actualendyear", "progress", "last.report", "actualendyearnew")])

# missing.ends <- proj.cont[is.na(proj.cont$actualendyear),]
# length(unique(missing.ends$ContractID))
# length(unique(missing.ends$ProjectID))
# missing.ends2 <- as.data.frame(missing.ends[0,])
# for(i in unique(missing.ends$ContractID)) {
#   temp <- missing.ends[missing.ends$ContractID==i,]
#   missing.ends2[i,] <- temp[which.max(as.numeric(temp$progress))[1],]
#   
# }

#only keeping necessary columns and renaming as necessary
# each row is a unique project + contract + village combination
#note: can be multiple contracts per project and multiple villages per contract
proj.cont <- proj.cont[,c("ProjectID", "ContractID", "NameE.y.x", "ProjTypeID", "Name",
                          "isNew", "NameE.y.y", "plannedstartyear", "plannedstartmonth",
                          "plannedendyear", "plannedendmonth", "actualendyear", "actualendmonth",
                          "last.report", "progress", "Bidders", "FundCS", "FundLocalContr", "VillGis")] #no subsector, need competitive bidding dummy
names(proj.cont) <- c("project.id", "contract.id", "activity.type",  "activity.type.num",
                      "activity.desc", "new.repair.num", "new.repair", "planned.start.yr", "planned.start.mo",
                      "planned.end.yr", "planned.end.mo", "actual.end.yr", "actual.end.mo", "last.report",
                      "status", "n.bidders", "cs.fund", "local.cont", "vill.id")
proj.cont$pid_id <- seq(100001, (100000+nrow(proj.cont)), 1)

# write.csv(proj.cont, "pid/completed_pid/pid_2008.csv", row.names = F)