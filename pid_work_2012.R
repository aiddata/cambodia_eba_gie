
#g.shape <- read.csv("~/Box Sync/Pro")
#only 2009-2012

library(readxl)
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







temp.project <- temp.project[,c("Id", "AreaCode", "NatureOfProject", "SubSectorId", "Name_EN.x", "List_Project_Output_Type_ID", "Id.y", "OrderNr.x", "Qty", "UnitCost", "CREF", "GEOREF", )]




#unique(contract$AwardedByBidding) #unique values are -1 and 0. Which indicates competitive bidding?
#sum(contract.output$ContractId %in% contract$Id) #full match between contract.output and contract

contract.match <- merge(contract.output, contract, by.x="ContractId", by.y="Id")

project <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/Project.xlsx")
project.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2012/ProjectOutput.xlsx")
sum(project.output$ProjectId %in% project$Id)
project.match <- merge(project.output, project, by.x="ProjectId", by.y="Id")

# dups <- project.output[project.output$ProjectId=="{1D82DAB8-D1F6-40A5-B7FD-9F7500ACDFB7}",]
# dups <- project.output[project.output$ProjectId=="{00062FDF-0957-4480-AA75-9DD400BF130E}",]
# 
# dups2 <- contract.match[contract.match$Reference=="{1D82DAB8-D1F6-40A5-B7FD-9F7500ACDFB7}",]
# dups2 <- contract.match[contract.match$Reference=="{00062FDF-0957-4480-AA75-9DD400BF130E}",]


sum(contract.match$Reference %in% project.match$ProjectId)

project.match$matchID <- paste0(project.match$ProjectId, project.match$VillageId, project.match$OrderNr)
contract.match$matchID <- paste0(contract.match$Reference, contract.match$VillageId, contract.match$OrderNr)

project.match$uniqueprojID <- seq(1, nrow(project.match), 1)
contract.match$uniquecontID <- seq((nrow(project.match)+1), (nrow(project.match)+nrow(contract.match)), 1)

proj.cont.match <- merge(project.match, contract.match, by.x="matchID", by.y="matchID")

project.nomatch <- project.match[which(!(project.match$uniqueprojID %in% proj.cont.match$uniqueprojID)),]
contract.nomatch <- contract.match[which(!(contract.match$uniquecontID %in% proj.cont.match$uniquecontID)),]
write.csv(project.nomatch, "~/Desktop/project_nomatch.csv")
write.csv(contract.nomatch, "~/Desktop/contract_nomatch.csv")


length(unique(proj.cont.match$VillageId.x))
sum(proj.cont.match$VillageId.x %in% panel$vill_code)
sum(panel$vill_code %in% proj.cont.match$VillageId.x)


# 2003-2008 data

village <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/Village.xlsx")
project.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/ProjectOutput.xlsx")

sum(village$VillGis %in% panel$vill_code)
sum(panel$vill_code %in% project.output$VillGis)

temp <- strsp(contract.match$ActualWorkCompletionOn, )



