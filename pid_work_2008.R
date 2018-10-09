
library(readxl)

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

proj.test <- merge(project, project.output, by.x="ProjectID", by.y="ProjectID")