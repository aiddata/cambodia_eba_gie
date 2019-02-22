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
#contract.output <- contract.output[!duplicated(contract.output$ContractID),c("ContractID", "linkProjectID")]

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
#merge sector info into project.output
project.output <- merge(project.output, output, by.x="OutputID", by.y="OutputID", all.x = T)

#identify and merge in output type info (e.g. new, repair) 
output.type <- read_excel("pid/pid_excel_2008/OutputType.xlsx")
project.output <- merge(project.output, output.type, by.x="isNew", by.y="OPTypeID", all.x = T)

#identify project + order number activities, merge into project.output
table3 <- read_excel("pid/pid_excel_2008/Table3.xlsx")
table3 <- table3[!duplicated(table3$OutputID),]
project.output <- merge(project.output, table3, by.x="OutputID", by.y="OutputID", all.x = T)

#identify sub-sector for each project + order number
output.categories <- read_excel("pid/pid_excel_2008/OutputCategories.xlsx")
project.output <- merge(project.output, output.categories, by.x="CategoryID", by.y="ID", all.x = T)

## Merging project output dataset (multiple rows per project) with the project dataset (one row per project, project-level data)

#get overall project sector info
#Project dataset only has one row per project
project <- read_excel("pid/pid_excel_2008/Project.xlsx")
proj.type <- read_excel("pid/pid_excel_2008/ProjType.xlsx")
#merge in ProjTypeID classification, which gives overall project sector
project <- merge(project, proj.type, by.x="ProjTypeID", by.y="ProjTypeID", all.x = T)

#merge project output (multiple rows per project) with project information, which will repeat over duplicate projects
project <- merge(project, project.output, by.x="ProjectID", by.y="ProjectID", all.x = T)

#changing the classes of date variables to character
x <- unlist(lapply(project, class))
project[,x[!(x=="POSIXt")]=="POSIXct"] <- lapply(project[,x[!(x=="POSIXt")]=="POSIXct"], as.character)

##########################
## Merge Project and Contract Data
##########################

## Merge Project and Contract data (multiple contracts per project AND multiple villages per contract)
# Want to end up with unique project/contract/order identifier

#creating skeleton dataset to merge project and contract data
# proj.cont <- cbind(project[0,], contract[0,])
# proj.cont <- proj.cont[,!(names(proj.cont)=="linkProjectID")]

project$mergevar <- paste(project$ProjectID, project$OrderNo)
contract$mergevar <- paste(contract$linkProjectID, contract$linkOrderNo)
# View(contract[contract$mergevar==contract$mergevar[duplicated(contract$mergevar)][1],])

pid2008 <- merge(project, contract, by="mergevar")
pid2008$commvar <- paste(pid2008$ProjectID, pid2008$VillGis)
pid20082 <- pid2008
pid2008 <- pid2008[!duplicated(pid2008$commvar),]

pid2008$actual_start_month <- month(pid2008$StartDate)
pid2008$actual_start_year <- year(pid2008$StartDate)
pid2008$actual_end_month <- month(pid2008$EndDate)
pid2008$actual_end_year <- year(pid2008$EndDate)

for(i in 1:nrow(pid2008)) {
  if(sum(pid20082$commvar==pid2008$commvar[i])>1) {
    temp <- pid20082[pid20082$commvar==pid2008$commvar[i],]
    
    pid2008$FundCS[i] <- paste(temp$FundCS, collapse = "|")
    pid2008$FundLocalContr[i] <- paste(temp$FundLocalContr, collapse = "|")
  }
}

pid2008 <- pid2008[,c("ProjectID", "ContractID", "NameE.y.x", "NameE.x.x", "NameE.y.y", "actual_start_year",
                      "actual_start_month", "actual_end_year", "actual_end_month", "last.report", "progress", "Bidders",
                      "FundCS", "FundLocalContr", "VillGis")]

names(pid2008) <- c("project_id", "contract_id", "activity_type", "activity_desc", "new_repair", "start_year_actual",
                    "start_month_actual", "end_year_actual", "end_month_actual", "last_report", "status",
                    "n_bidders", "cs_fund", "local_cont", "vill_id")

pid2008$pid_id <- seq(100001, (100000+nrow(pid2008)), 1)

# write.csv(pid2008, "pid/completed_pid/pid_2008.csv", row.names = F)
