#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Compiling Project Information Database (from Cambodia) for 2009-12
# Will use project completion dates to create treatment info
#------------------------------

setwd("~/box sync/cambodia_eba_gie")

library(readxl)
library(stringr)
contract.output <- read_excel("pid/pid_excel_2012/ContractOutput.xlsx")
contract.budget <- read_excel("pid/pid_excel_2012/ContractBudget.xlsx")
list.fund.source <- read_excel("pid/pid_excel_2012/ListFundSource.xlsx")
list.fund.source <- list.fund.source[,c("Id", "Name_EN")]
#merging contract budget data with "list.fund.source", which contains the name of each funding
#source, i.e. Commune/Sankat Fund or Local Contributions
contract.budget <- merge(contract.budget, list.fund.source, by.x="FundSourceId", by.y="Id", all.x = T)
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
    #contract ID value in the contract output dataset. This will help avoid counting contributions by these
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
contract.merge <- merge(contract.output, contract.budget.new, by="ContractId", all.x = T)

#running tests to ensure the new merged contracts dataset records the same number of contributions by the
#CS fund and local contributions as the original contract budget dataset
contract.budget2 <- contract.budget[contract.budget$ContractId %in% contract.output$ContractId,]
sum(contract.budget2$Amount[contract.budget2$Name_EN=="Commune/Sangkat Fund"])
sum(contract.budget2$Amount[contract.budget2$Name_EN=="Local Contribution"])

###################

contract <- read_excel("pid/pid_excel_2012/Contract.xlsx")
contract <- merge(contract.merge, contract, by.x = "ContractId", by.y = "Id", all.x = T)
contract.progress <- read_excel("pid/pid_excel_2012/ContractProgress.xlsx")

#creating empty columns for the last report data of each contract and the progress of each contract at the 
#last report date
contract[,c("last.report", "progress")] <- NA
#using a for loop so for each unique contract ID, we can identify the observation of the last report date
for(i in unique(contract.progress$ContractId)) {
  #subsetting the data so we only keep the observations of the specific contract ID
  temp.progress <- contract.progress[contract.progress$ContractId==i,]
  temp.contract <- contract[contract$ContractId==i,]
  
  if(nrow(temp.contract)>0 & nrow(temp.progress)>0) {
    
    last.report <- temp.progress$ReportOn[which.max(temp.progress$ReportOn)][1]
    progress <- temp.progress$Value[which.max(temp.progress$ReportOn)][1]
    
    contract$last.report[contract$ContractId==i] <- as.character(last.report)
    contract$progress[contract$ContractId==i] <- as.character(progress)
  }
}

###################

#merging the contract data with the reference data identifying Activity Description (eg. laterite rd, crushed stone rd)
list.standard.output <- read_excel("pid/pid_excel_2012/ListStandardOutput.xlsx")
contract <- merge(contract, list.standard.output, by.x="OutputId", by.y="Id", all.x = T)

#merging the contract data with the reference data further describing the activity (eg. unpaved rds, bridges, etc.)
list.output.groups <- read_excel("pid/pid_excel_2012/ListOutputGroups.xlsx")
contract <- merge(contract, list.output.groups, by.x="GroupId", by.y="Id", all.x = T)

#merging the contract data with the reference data describing the Activity Type (eg. Rural Transport, Irrigation, etc.)
list.subsector <- read_excel("pid/pid_excel_2012/ListSubsector.xlsx")
contract <- merge(contract, list.subsector, by.x="SubSectorId", by.y="Id", all.x = T)

###################

rm(list=setdiff(ls(), "contract"))

project <- read_excel("pid/pid_excel_2012/Project.xlsx")
project.output <- read_excel("pid/pid_excel_2012/ProjectOutput.xlsx")
lookup <- read_excel("pid/pid_excel_2012/Lookup.xlsx")

#merging project output data with the data identifying whether the project was New, Repair, Upgrade, etc. 
project.output <- merge(project.output, lookup, by.x="List_Project_Output_Type_ID", by.y="Id", all.x = T)

#merging the project output data into the project dataset based on ID
project <- merge(project, project.output, by.x="Id", by.y="ProjectId", all.y = T)

#creating match IDs between the project and contract data consisting of the Project ID, Village ID, and contract
#order number for each observation
project$matchID <- paste0(project$Id, project$VillageId, project$OrderNr.x)
contract$matchID <- paste0(contract$Reference, contract$VillageId, contract$OrderNr)

#only retaining the project and contract observations that do not have duplicated match IDs
#merging the contract and project data
project <- merge(project, contract, by.x="matchID", by.y="matchID")

unit_cost <- aggregate(project$UnitCost.x, by=list(project$Name_EN.y.y), FUN=mean)

project$tempvar <- paste(project$Id, project$VillageId.x)
project2 <- project[!duplicated(project$tempvar),]
names(project2)[which(names(project2)=="Name_EN.y.y")[2]] <- "Name_EN.y.y.2"

contract$biddummy <- ifelse(contract$Bidders>0, 1, 0)
contract$one_bid_dummy <- ifelse(contract$Bidders==1, 1, 0)
contract$tempvar <- paste(contract$Reference, contract$VillageId)
bidders <- aggregate(contract[,c("Bidders", "biddummy", "one_bid_dummy")], by=list(contract$tempvar), FUN = mean)
project2$bid.dummy <- NA
project2$one_bid_dummy <- NA

for(i in 1:nrow(project2)) {
  if(length(which(bidders$Group.1==project2$tempvar[i]))>0) {
    
    project2$Bidders[i] <- paste(contract$Bidders[which(contract$tempvar==project2$tempvar[i])], collapse = "|")
    #project2$bid.dummy[i] <- bidders$biddummy[which(bidders$Group.1==project2$tempvar[i])]
    #project2$one_bid_dummy[i] <- bidders$one_bid_dummy[which(bidders$Group.1==project2$tempvar[i])]
  }
  if(sum(project$tempvar==project2$tempvar[i])>1) {
    tempdata <- project[project$temp==project2$temp[i],]
    
    project2$UnitCost.x[i] <- paste(unique(tempdata$UnitCost.x), collapse = "|")
    project2$Name_EN.y.x[i] <- paste(unique(tempdata$Name_EN.y.x), collapse = "|")
    project2$Name_EN.y.y.2[i] <- paste(unique(tempdata$Name_EN.y.y.2), collapse = "|")
    
    project2$mean_unitCost[i] <- mean(tempdata$UnitCost.x)/mean(unit_cost$x[unit_cost$Group.1 %in% tempdata$Name_EN.y.y])
  } else {
    
    project2$mean_unitCost[i] <- mean(as.numeric(project2$UnitCost.x[i]))/mean(unit_cost$x[unit_cost$Group.1 %in% project2$Name_EN.y.y])
  }
}

project2$start_year_planned <- year(project2$PlannedStartOn)
project2$start_month_planned <- month(project2$PlannedStartOn)
project2$start_year_actual <- year(project2$ActualWorkStartOn)
project2$start_month_actual <- month(project2$ActualWorkStartOn)
project2$end_year_planned <- year(project2$PlannedCompletionOn)
project2$end_month_planned <- month(project2$PlannedCompletionOn)
project2$end_month_actual <- ifelse(is.na(project2$ActualWorkCompletionOn), month(project2$last.report), month(project2$ActualWorkCompletionOn))
project2$end_year_actual <- ifelse(is.na(project2$ActualWorkCompletionOn), year(project2$last.report), year(project2$ActualWorkCompletionOn))


project2 <- project2[,c("Id", "ContractId", "Name_EN.y.y.2", "Name_EN.y.y",
                      "Name_EN.y.x", "start_year_actual", "start_month_actual",
                      "end_year_actual", "end_month_actual", "last.report",
                      "progress", "Bidders", "mean_unitCost", "cs.fund", "local.cont", "VillageId.x")]

names(project2) <- c("project_id", "contract_id", "activity_type", "activity_desc", "new_repair", 
                    "start_year_actual","start_month_actual", "end_year_actual", "end_month_actual", 
                    "last_report", "status","n_bidders", "mean_unitCost", "cs_fund", "local_cont", "vill_id")

project2$pid_id <- seq(200001, (200000+nrow(project2)), 1)

# write.csv(project2, "pid/completed_pid/pid_2012.csv", row.names = F)
