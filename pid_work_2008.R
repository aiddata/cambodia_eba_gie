
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

which(duplicated(paste(project$VillGis, project$ProjectID)))[1]

proj.cont <- cbind(project[0,], contract[0,])
proj.cont[] <- lapply(proj.cont, function(x) as.numeric(as.character(x)))
proj.cont <- proj.cont[,!(names(proj.cont)=="linkProjectID")]

for(i in unique(contract$linkProjectID)) {
  temp.contract <- contract[contract$linkProjectID==i,]
  temp.project <- project[project$ProjectID==i,]
  
  if(nrow(temp.project)!=0) {
    temp.project <- temp.project[!duplicated(temp.project$VillGis),]
    
    temp.contract[,c("FundCS", "FundLocalContr", "linkProjectID")] <- as.data.frame(matrix(c(temp.contract$FundCS/nrow(temp.project),
                                                                                             temp.contract$FundLocalContr/nrow(temp.project),
                                                                                             temp.contract$linkProjectID), ncol = 3))
    
    # cs.split <- as.data.frame(matrix(c(temp.contract$FundCS/nrow(temp.project),
    #                                    temp.contract$FundLocalContr/nrow(temp.project),
    #                                    temp.contract$linkProjectID), ncol = 3))
    # names(cs.split) <- c("FundCS", "FundLocalContr", "linkProjectID")
    
    temp.project <- merge(temp.project, temp.contract, by.x="ProjectID", by.y="linkProjectID")
    
    # test <- merge(temp.project, temp.contract, by.x=)
    # 
    # 
    # 
    # temp.contract <- temp.contract[,!(names(temp.contract) %in% names(temp.project2))]
    # temp.project3 <- merge(temp.project, temp.contract, by.x="ProjectID", by.y="linkProjectID")
    # 
    # temp.project4 <- cbind(temp.project2, temp.project3[,!(names(temp.project3) %in% names(temp.project))])
    proj.cont[(nrow(proj.cont)+1):(nrow(proj.cont)+nrow(temp.project)),] <- temp.project
  }
}

proj.cont <- proj.cont[,c("ProjectID", "ContractID", "NameE.y.x", "Name",
                          "isNew", "NameE.y.y", )] #no subsector,
names(proj.cont) <- c("project_id", "contract_id", "activity.type", "activity.desc",
                      "new.repair.num", "new.repair",)

write.csv(proj.cont, "~/Box Sync/")

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

