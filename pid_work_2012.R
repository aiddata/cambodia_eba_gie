
#g.shape <- read.csv("~/Box Sync/Pro")
#only 2009-2012

library(readxl)
library(stringr)
contract.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ContractOutput.xlsx")
contract.budget <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ContractBudget.xlsx")
list.fund.source <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ListFundSource.xlsx")
list.fund.source <- list.fund.source[,c("Id", "Name_EN")]
contract.budget <- merge(contract.budget, list.fund.source, by.x="FundSourceId", by.y="Id")#[,c("FundSourceId","Id","Amount","Name_EN")]

contract.budget.new <- contract.budget[!duplicated(contract.budget$ContractId),]
contract.budget.new[,c("cs.fund", "local.cont")] <- NA
for(i in contract.budget.new[,"ContractId"]) {
  temp.budget <- contract.budget[contract.budget$ContractId==i,]
  temp.output <- contract.output[contract.output$ContractId==i,]
  
  temp.cs <- as.numeric(temp.budget$Amount[temp.budget$Name_EN=="Commune/Sangkat Fund"])
  temp.lc <- as.numeric(temp.budget$Amount[temp.budget$Name_EN=="Local Contribution"])
  
  if(nrow(temp.output)>0) {
    contract.budget.new$cs.fund[contract.budget.new$ContractId==i] <- sum(temp.cs)/nrow(temp.output)
    contract.budget.new$local.cont[contract.budget.new$ContractId==i] <- sum(temp.lc)/nrow(temp.output)
  } else {
    contract.budget.new$cs.fund[contract.budget.new$ContractId==i] <- 0
    contract.budget.new$local.cont[contract.budget.new$ContractId==i] <- 0
  }
  
}
contract.merge <- merge(contract.output, contract.budget.new, by="ContractId")
sum(contract.budget.new$ContractId %in% contract.output$ContractId)

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

contract[,c("last.report", "progress")] <- NA
for(i in unique(contract.progress$ContractId)) {
  temp.progress <- contract.progress[contract.progress$ContractId==i,]
  temp.contract <- contract[contract$Id==i,]
  
  temp.contract[,c("last.report", "progress")] <- matrix(rep(c(as.character(temp.progress$ReportOn[which.max(temp.progress$ReportOn)]),
                                                                             as.character(temp.progress$Value[which.max(temp.progress$ReportOn)])), 
                                                                           nrow(temp.contract)), ncol=2, byrow=T)
  contract[contract$Id==i,c("last.report","progress")] <- temp.contract[,c("last.report","progress")]
}

###################

list.standard.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ListStandardOutput.xlsx")
sum(list.standard.output$Id %in% contract$OutputId)
contract <- merge(contract, list.standard.output, by.x="OutputId", by.y="Id")

list.output.groups <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ListOutputGroups.xlsx")
sum(list.output.groups$Id %in% contract$GroupId)
contract <- merge(contract, list.output.groups, by.x="GroupId", by.y="Id")

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
project.output <- merge(project.output, lookup, by.x="List_Project_Output_Type_ID", by.y="Id")

sum(project$Id %in% project.output$ProjectId)
project <- merge(project, project.output, by.x="Id", by.y="ProjectId")

project$matchID <- paste0(project$Id, project$VillageId, project$OrderNr.x)
contract$matchID <- paste0(contract$Reference, contract$VillageId, contract$OrderNr)
sum(contract$matchID %in% project$matchID)
length(unique(project$matchID))
length(unique(contract$matchID))

project <- project[!(project$matchID %in% project$matchID[duplicated(project$matchID)]),]
contract <- contract[!(contract$matchID %in% contract$matchID[duplicated(contract$matchID)]),]
project <- merge(project, contract, by.x="matchID", by.y="matchID")
length(unique(project$matchID))

project$plannedstartyear <- matrix(unlist(str_split(as.character(project$PlannedStartOn), "-")), ncol = 3, byrow = T)[,1]
project$plannedstartmonth <- matrix(unlist(str_split(as.character(project$PlannedStartOn), "-")), ncol = 3, byrow = T)[,2]
project$actualstartyear[!is.na(project$ActualWorkStartOn)] <- 
  matrix(unlist(str_split(as.character(project$ActualWorkStartOn[!is.na(project$ActualWorkStartOn)]), "-")), ncol = 3, byrow = T)[,1]
project$actualstartmonth[!is.na(project$ActualWorkStartOn)] <- 
  matrix(unlist(str_split(as.character(project$ActualWorkStartOn[!is.na(project$ActualWorkStartOn)]), "-")), ncol = 3, byrow = T)[,2]

project$plannedendyear <- matrix(unlist(str_split(as.character(project$PlannedCompletionOn), "-")), ncol = 3, byrow = T)[,1]
project$plannedendmonth <- matrix(unlist(str_split(as.character(project$PlannedCompletionOn), "-")), ncol = 3, byrow = T)[,2]
project$actualendyear[!is.na(project$ActualWorkCompletionOn)] <- 
  matrix(unlist(str_split(as.character(project$ActualWorkCompletionOn[!is.na(project$ActualWorkCompletionOn)]), "-")), ncol = 3, byrow = T)[,1]
project$actualendmonth[!is.na(project$ActualWorkCompletionOn)] <- 
  matrix(unlist(str_split(as.character(project$ActualWorkCompletionOn[!is.na(project$ActualWorkCompletionOn)]), "-")), ncol = 3, byrow = T)[,2]

names(project)[151] <- "Name_EN.y.y.2"
project <- project[,c("Id.x", "Id.y", "RILGPProjectTypeId", "Name_EN.y.y.2", "RILGPOutputCategoryId",
                      "Name_EN.y.y", "SubSectorId.x", "List_Project_Output_Type_ID", "Name_EN.y.x",
                      "plannedstartyear", "plannedstartmonth", "actualstartyear", "actualstartmonth",
                      "plannedendyear", "plannedendmonth", "actualendyear", "actualendmonth", "last.report",
                      "progress", "Bidders", "AwardedByBidding", "cs.fund", "local.cont", "VillageId.x")]

names(project) <- c("project_id", "contract_id", "activity.type.num", "activity.type", "activity.desc.num",
                    "activity.desc", "subsector", "new.repair.num", "new.repair", "planned.start.yr",
                    "planned.start.mo", "actual.start.yr", "actual.start.mo", "planned.end.yr", "planned.end.mo",
                    "actual.end.yr", "actual.end.mo", "last.report", "status", "n.bidders", "bid.dummy", "cs.fund",
                    "local.cont", "vill.id")

write.csv(project, "~/Box Sync/cambodia_eba_gie/PID/completed_pid/pid_2012.csv", row.names = F)

