
#g.shape <- read.csv("~/Box Sync/Pro")
#only 2009-2012

library(readxl)
library(stringr)
contract.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ContractOutput.xlsx")
contract.budget <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ContractBudget.xlsx")
list.fund.source <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ListFundSource.xlsx")
list.fund.source <- list.fund.source[,c("Id", "Name_EN")]
#merging contract budget data with "list.fund.source", which contains the name of each funding
#source, i.e. Commune/Sankat Fund or Local Contributions
contract.budget <- merge(contract.budget, list.fund.source, by.x="FundSourceId", by.y="Id")
#for this dataset, we only want one observation per contract ID
contract.budget.new <- contract.budget[!duplicated(contract.budget$ContractId),]
#creating new variables in the contract budget dataset for dollars contributed by Commune/Sankat Fund and
#for dollars contributed by local contributions
contract.budget.new[,c("cs.fund", "local.cont")] <- NA
#using a for loop to iterate through each unique contract and compute CS Fund and local contributions
for(i in contract.budget.new[,"ContractId"]) {
  #isolating the contract budget and output observations for each unique contract ID
  temp.budget <- contract.budget[contract.budget$ContractId==i,]
  temp.output <- contract.output[contract.output$ContractId==i,]
  #pulling all contributions from the CS fund and local contributions and storing them in separate vectors
  temp.cs <- as.numeric(temp.budget$Amount[temp.budget$Name_EN=="Commune/Sangkat Fund"])
  temp.lc <- as.numeric(temp.budget$Amount[temp.budget$Name_EN=="Local Contribution"])
  
  if(nrow(temp.output)>0) {
    #taking the sum of each contributions vector and dividing them by the number of observations of the
    #contract ID value in the contract budget dataset. This will help avoid counting contributions by these
    #funding sources multiple times
    contract.budget.new$cs.fund[contract.budget.new$ContractId==i] <- sum(temp.cs)/nrow(temp.output)
    contract.budget.new$local.cont[contract.budget.new$ContractId==i] <- sum(temp.lc)/nrow(temp.output)
  } else {
    contract.budget.new$cs.fund[contract.budget.new$ContractId==i] <- 0
    contract.budget.new$local.cont[contract.budget.new$ContractId==i] <- 0
  }
  
}
#merging the contract output dataset with the new contract budget dataset, which avoids overcounting of 
#contributions by the CS fund and local contributions
contract.merge <- merge(contract.output, contract.budget.new, by="ContractId")
sum(contract.budget.new$ContractId %in% contract.output$ContractId)

#running tests to ensure the new merged contracts dataset records the same number of contributions by the
#CS fund and local contributions as the original contract budget dataset
contract.budget2 <- contract.budget[contract.budget$ContractId %in% contract.output$ContractId,]
sum(contract.budget2$Amount[contract.budget2$Name_EN=="Commune/Sangkat Fund"])
sum(contract.merge$cs.fund)
sum(contract.budget2$Amount[contract.budget2$Name_EN=="Local Contribution"])
sum(contract.merge$local.cont)

###################

rm(list=setdiff(ls(), "contract.merge"))

contract <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/Contract.xlsx")
contract <- merge(contract, contract.merge, by.x="Id", by.y="ContractId")

contract.progress <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ContractProgress.xlsx")

#creating empty columns for the last report data of each contract and the progress of each contract at the 
#last report date
contract[,c("last.report", "progress")] <- NA
#using a for loop so for each unique contract ID, we can identify the observation of the last report date
for(i in unique(contract.progress$ContractId)) {
  #subsetting the data so we only keep the observations of the specific contract ID
  temp.progress <- contract.progress[contract.progress$ContractId==i,]
  temp.contract <- contract[contract$Id==i,]
  #identifying the observation with the last treatment date and creating a matrix of this observation repeated
  #with number of rows equal to the number of rows in the contract dataset with this contract ID
  temp.contract[,c("last.report", "progress")] <- matrix(rep(c(as.character(temp.progress$ReportOn[which.max(temp.progress$ReportOn)]),
                                                                             as.character(temp.progress$Value[which.max(temp.progress$ReportOn)])), 
                                                                           nrow(temp.contract)), ncol=2, byrow=T)
  #filling the observations in the contract dataset with the specific contract ID with the contents of the matrix
  #generated previously
  contract[contract$Id==i,c("last.report","progress")] <- temp.contract[,c("last.report","progress")]
}

###################

#merging the contract data with the reference data identifying Activity Description (eg. laterite rd, crushed stone rd)
list.standard.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ListStandardOutput.xlsx")
sum(list.standard.output$Id %in% contract$OutputId)
contract <- merge(contract, list.standard.output, by.x="OutputId", by.y="Id")

#merging the contract data with the reference data further describing the activity (eg. unpaved rds, bridges, etc.)
list.output.groups <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ListOutputGroups.xlsx")
sum(list.output.groups$Id %in% contract$GroupId)
contract <- merge(contract, list.output.groups, by.x="GroupId", by.y="Id")

#merging the contract data with the reference data describing the Activity Type (eg. Rural Transport, Irrigation, etc.)
list.subsector <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ListSubsector.xlsx")
sum(list.subsector$Id %in% contract$SubSectorId)
contract <- merge(contract, list.subsector, by.x="SubSectorId", by.y="Id")

###################

rm(list=setdiff(ls(), "contract"))

project <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/Project.xlsx")
project.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ProjectOutput.xlsx")
lookup <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/Lookup.xlsx")

unique(project.output$List_Project_Output_Type_ID)
unique(lookup$Id)
#merging project output data with the data identifying whether the project was New, Repair, Upgrade, etc. 
project.output <- merge(project.output, lookup, by.x="List_Project_Output_Type_ID", by.y="Id")

sum(project$Id %in% project.output$ProjectId)
#merging the project output data into the project dataset based on ID
project <- merge(project, project.output, by.x="Id", by.y="ProjectId")

#creating match IDs between the project and contract data consisting of the Project ID, Village ID, and contract
#order number for each observation
project$matchID <- paste0(project$Id, project$VillageId, project$OrderNr.x)
contract$matchID <- paste0(contract$Reference, contract$VillageId, contract$OrderNr)
sum(contract$matchID %in% project$matchID)
length(unique(project$matchID))
length(unique(contract$matchID))

#only retaining the project and contract observations that do not have duplicated match IDs
project <- project[!(project$matchID %in% project$matchID[duplicated(project$matchID)]),]
contract <- contract[!(contract$matchID %in% contract$matchID[duplicated(contract$matchID)]),]
#merging the contract and project data
project <- merge(project, contract, by.x="matchID", by.y="matchID")
length(unique(project$matchID))

#splitting the PlannedStartOn into planned start year and planned start month. Doing the same for ActualWorkStartOn
project$plannedstartyear <- matrix(unlist(str_split(as.character(project$PlannedStartOn), "-")), ncol = 3, byrow = T)[,1]
project$plannedstartmonth <- matrix(unlist(str_split(as.character(project$PlannedStartOn), "-")), ncol = 3, byrow = T)[,2]
project$actualstartyear[!is.na(project$ActualWorkStartOn)] <- 
  matrix(unlist(str_split(as.character(project$ActualWorkStartOn[!is.na(project$ActualWorkStartOn)]), "-")), ncol = 3, byrow = T)[,1]
project$actualstartmonth[!is.na(project$ActualWorkStartOn)] <- 
  matrix(unlist(str_split(as.character(project$ActualWorkStartOn[!is.na(project$ActualWorkStartOn)]), "-")), ncol = 3, byrow = T)[,2]

#splitting the PlannedCompletionOn into planned end year and planned end month. Doing the same for ActualWorkCompletionOn
project$plannedendyear <- matrix(unlist(str_split(as.character(project$PlannedCompletionOn), "-")), ncol = 3, byrow = T)[,1]
project$plannedendmonth <- matrix(unlist(str_split(as.character(project$PlannedCompletionOn), "-")), ncol = 3, byrow = T)[,2]
project$actualendyear[!is.na(project$ActualWorkCompletionOn)] <- 
  matrix(unlist(str_split(as.character(project$ActualWorkCompletionOn[!is.na(project$ActualWorkCompletionOn)]), "-")), ncol = 3, byrow = T)[,1]
project$actualendmonth[!is.na(project$ActualWorkCompletionOn)] <- 
  matrix(unlist(str_split(as.character(project$ActualWorkCompletionOn[!is.na(project$ActualWorkCompletionOn)]), "-")), ncol = 3, byrow = T)[,2]

#changing the one variable name that is duplicated
names(project)[151] <- "Name_EN.y.y.2"
#only retaining the necessary variables from the merged project-contract data
project <- project[,c("Id.x", "Id.y", "RILGPProjectTypeId", "Name_EN.y.y.2", "RILGPOutputCategoryId",
                      "Name_EN.y.y", "SubSectorId.x", "List_Project_Output_Type_ID", "Name_EN.y.x",
                      "plannedstartyear", "plannedstartmonth", "actualstartyear", "actualstartmonth",
                      "plannedendyear", "plannedendmonth", "actualendyear", "actualendmonth", "last.report",
                      "progress", "Bidders", "AwardedByBidding", "cs.fund", "local.cont", "VillageId.x")]
#assigning meaningful names to the variables in the data
names(project) <- c("project_id", "contract_id", "activity.type.num", "activity.type", "activity.desc.num",
                    "activity.desc", "subsector", "new.repair.num", "new.repair", "planned.start.yr",
                    "planned.start.mo", "actual.start.yr", "actual.start.mo", "planned.end.yr", "planned.end.mo",
                    "actual.end.yr", "actual.end.mo", "last.report", "status", "n.bidders", "bid.dummy", "cs.fund",
                    "local.cont", "vill.id")

write.csv(project, "~/Box Sync/cambodia_eba_gie/PID/completed_pid/pid_2012.csv", row.names = F)

