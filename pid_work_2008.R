
library(readxl)
library(stringr)

contract <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/Contract.xlsx")
length(unique(contract$ContractID))
progress <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/Progress.xlsx")
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

contract.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/ContractOutput.xlsx")
contract.output <- contract.output[!duplicated(contract.output$ContractID),c("ContractID", "linkProjectID")]
contract <- merge(contract, contract.output, by="ContractID")

###################

output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/Output.xlsx")
project.output <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/ProjectOutput.xlsx")
sum(output$OutputID %in% project.output$OutputID)
project.output <- merge(project.output, output, by.x="OutputID", by.y="OutputID")

output.type <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/OutputType.xlsx")
sum(project.output$isNew %in% output.type$OPTypeID)
project.output <- merge(project.output, output.type, by.x="isNew", by.y="OPTypeID")

length(unique(paste(project.output$OutputID, project.output$ProjectID)))

table3 <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/Table3.xlsx")
table3 <- table3[!duplicated(table3$OutputID),]
sum(project.output$OutputID %in% table3$OutputID)
project.output <- merge(project.output, table3, by.x="OutputID", by.y="OutputID")

output.categories <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/OutputCategories.xlsx")
sum(project.output$CategoryID %in% output.categories$ID)
project.output <- merge(project.output, output.categories, by.x="CategoryID", by.y="ID")

#####

project <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/Project.xlsx")
proj.type <- read_excel("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2008/ProjType.xlsx")
sum(project$ProjTypeID %in% proj.type$ProjTypeID)
project <- merge(project, proj.type, by.x="ProjTypeID", by.y="ProjTypeID")

#####

rm(list=setdiff(ls(), c("contract", "project", "project.output")))

project <- merge(project, project.output, by.x="ProjectID", by.y="ProjectID")
x <- unlist(lapply(project, class))
project[,x[!(x=="POSIXt")]=="POSIXct"] <- lapply(project[,x[!(x=="POSIXt")]=="POSIXct"], as.character)

proj.cont <- cbind(project[0,], contract[0,])
proj.cont <- proj.cont[,!(names(proj.cont)=="linkProjectID")]

for(i in unique(contract$linkProjectID)) {
  temp.contract <- contract[contract$linkProjectID==i,]
  temp.project <- project[project$ProjectID==i,]
  
  if(nrow(temp.project)!=0) {
    temp.project <- temp.project[!duplicated(temp.project$VillGis),]
    
    temp.contract[,c("FundCS", "FundLocalContr", "linkProjectID")] <- as.data.frame(matrix(c(temp.contract$FundCS/nrow(temp.project),
                                                                                             temp.contract$FundLocalContr/nrow(temp.project),
                                                                                             temp.contract$linkProjectID), ncol = 3))
    
    temp.project <- merge(temp.project, temp.contract, by.x="ProjectID", by.y="linkProjectID")
    proj.cont[(nrow(proj.cont)+1):(nrow(proj.cont)+nrow(temp.project)),] <- temp.project
  }
}

proj.cont$plannedstartyear <- matrix(unlist(str_split(as.character(proj.cont$StartDate), "-")), ncol = 3, byrow = T)[,1]
proj.cont$plannedstartmonth <- matrix(unlist(str_split(as.character(proj.cont$StartDate), "-")), ncol = 3, byrow = T)[,2]

proj.cont$plannedendyear <- matrix(unlist(str_split(as.character(proj.cont$EndDate), "-")), ncol = 3, byrow = T)[,1]
proj.cont$plannedendmonth <- matrix(unlist(str_split(as.character(proj.cont$EndDate), "-")), ncol = 3, byrow = T)[,2]
proj.cont$actualendyear[!is.na(proj.cont$CompletionDate)] <- 
  matrix(unlist(str_split(as.character(proj.cont$CompletionDate[!is.na(proj.cont$CompletionDate)]), "-")), ncol = 3, byrow = T)[,1]
proj.cont$actualendmonth[!is.na(proj.cont$CompletionDate)] <- 
  matrix(unlist(str_split(as.character(proj.cont$CompletionDate[!is.na(proj.cont$CompletionDate)]), "-")), ncol = 3, byrow = T)[,2]

proj.cont <- proj.cont[,c("ProjectID", "ContractID", "ProjTypeID", "NameE.y.x", "OutputID", "Name",
                          "isNew", "NameE.y.y", "plannedstartyear", "plannedstartmonth",
                          "plannedendyear", "plannedendmonth", "actualendyear", "actualendmonth",
                          "last.report", "progress", "Bidders", "FundCS", "FundLocalContr", "VillGis")] #no subsector, need competitive bidding dummy
names(proj.cont) <- c("project_id", "contract_id", "activity.type.num", "activity.type", "activity.desc.num", 
                      "activity.desc", "new.repair.num", "new.repair", "planned.start.yr", "planned.start.mo",
                      "planned.end.yr", "planned.end.mo", "actual.end.yr", "actual.end.mo", "last.report",
                      "status", "n.bidders", "cs.fund", "local.cont", "vill.id")

write.csv(proj.cont, "~/Box Sync/cambodia_eba_gie/PID/completed_pid/pid_2008.csv", row.names = F)


