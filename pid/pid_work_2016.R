#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Compiling Project Information Database (from Cambodia) for 2013-16
# Will use project completion dates to create treatment info
#------------------------------

library(readxl)
library(rlist)
library(zoo)
library(data.table)

setwd("~/Box Sync/cambodia_eba_gie")

# pulling implementation data from NCDDS

# implementation_raw <- list()
# for(i in 1:25) {
#   for(j in 2013:2017) {
#     url <- paste0("http://db.ncdd.gov.kh/pid/reports/monitoring/Implementation.castle?detail=1&pv=", i, "&year=", j)
#     html <- readHTMLTable(url)
#     table <- html$tblRpt
#     table$year <- j
#     implementation_raw <- list.append(implementation_raw, table)
#   }
# }
# save(implementation_raw, file = "pid/2016_data/implementation_2016.Rdata")

# load in the scraped implementation data
load("pid/2016_data/implementation_2016.Rdata")

# merge all years/provinces of implementation data into one
implementation <- do.call(rbind, implementation_raw)
# all vars character
implementation <- as.data.frame(apply(implementation, 2, as.character), stringsAsFactors = F)
# update names
names(implementation) <- c("area_name", "vill_name", "description", "quantity", "start_actual", 
                           "end_planned", "end_actual", "last_report", "status", "year")
# create empty variables
implementation[c("comm_name", "start_planned", "comm_num", "contractor", "contract_id")] <- NA

# populating each observation with "commune-wide" data. To see why this is necessary, visit
# the NCDDS website and look at how they structure the tables
for(i in 1:nrow(implementation)) {
  # only want to add values to the "sub-commune data", not the commune-level lines
  if(implementation$area_name[i]=="") {
    
    # these two lines allow us to determine which row contains the commune-wide data
    ref <- which(implementation$area_name!="")
    ref2 <- ref[which.min(1/(ref-i))]
    
    # fill out dates columns
    implementation$start_actual[i] <- implementation$start_actual[ref2]
    implementation$end_planned[i] <- implementation$end_planned[ref2]
    implementation$end_actual[i] <- implementation$end_actual[ref2]
    implementation$start_planned[i] <- implementation$quantity[ref2]
    
    # fill out the last report and status columns
    implementation$last_report[i] <- implementation$last_report[ref2]
    implementation$status[i] <- implementation$status[ref2]
    
    # fill out additional columns
    implementation$comm_name[i] <- implementation$area_name[ref2]
    # for commune number, we only want the text before the first forward slash in the vill_name var
    implementation$comm_num[i] <- unlist(strsplit(implementation$vill_name[ref2], "/"))[1]
    implementation$contractor[i] <- implementation$description[ref2]
    implementation$contract_id[i] <- implementation$vill_name[ref2]
  }
}
# now remove the commune-level columns so we have village level data
implementation <- implementation[implementation$area_name=="",]

# reading in gazetteer data so we can merge the commune number and village name
# with the actual village number from gazetteer
gaz <- read_excel("inputdata/National Gazetteer 2014.xlsx", sheet = 4)
gaz$comm_num <- ifelse(nchar(gaz$Id)==7, substr(gaz$Id, 1, 5), substr(gaz$Id, 1, 6))
gaz$unique <- paste(gaz$comm_num, gaz$Name_EN)
# omitted duplicated "commune number-village name" combinations from gazetteer
gaz <- gaz[!(gaz$unique %in% gaz$unique[duplicated(gaz$unique)]),]
# merging impementation data with gazetteer for village IDs
implementation$unique <- paste(as.numeric(implementation$comm_num), implementation$vill_name)
implementation <- merge(implementation, gaz[c("unique", "Id")], by = "unique", all.x=T)

# removing forward slashes and hyphens from contract IDs
implementation$contract_id <- as.numeric(gsub("/|-", "", implementation$contract_id))

###

# pulling procurement data from the NCDDS website
# procurement_raw <- list()
# for(i in 1:25) {
#   for(j in 2013:2017) {
#     url <- paste0("http://db.ncdd.gov.kh/pid/reports/monitoring/procurement.castle?pv=", i, "&year=", j)
#     html <- readHTMLTable(url)
#     table <- html$tblRpt
#     table$year <- j
#     procurement_raw <- list.append(procurement_raw, table)
#   }
# }

# load in procurement data
load("pid/2016_data/procurement_2016.Rdata")

# merge all years/provinces into one dataset
procurement <- do.call(rbind, procurement_raw)
# all variables as character
procurement <- as.data.frame(apply(procurement, 2, as.character), stringsAsFactors = F)
# update names
names(procurement) <- c("project", "n_bidders", "contract", "no", "contractor", "bid_value", "discount",
                        "rejected", "note", "year")
# remove rows that arent pertinent
procurement <- procurement[procurement$project!="" & procurement$project!="Project" & !is.na(procurement$n_bidders),]
# only retaining the text before the comma in the project varible to retrieve commune numbers
procurement$comm_num <- as.numeric(sapply(procurement$project, FUN = function(x) {unlist(strsplit(x, ","))[1]}))

# retrieving contract IDs from the contract variable
procurement$contract_id <- sapply(procurement$contract, FUN = function(x) unlist(strsplit(x, "\r\n\t\t\t"))[1])
# remove slashes/hyphens from contract IDs
procurement$contract_id <- as.numeric(gsub("/|-", "", procurement$contract_id))
# remove observations with unsigned contracts
procurement <- procurement[procurement$contract!="Not yet sign contract",]
# merge implementation and procurement data by contract ID. Retain all implementation obs
contract_output <- merge(implementation, procurement, by="contract_id", all.x = T)

###

# pull output data from NCDDS
# output_raw <- list()
# for(i in 1:25) {
#   for(j in 2013:2017) {
#     url <- paste0("http://db.ncdd.gov.kh/pid/reports/monitoring/contractsummary.castle?pv=",i,"&year=",j)
#     html <- readHTMLTable(url)
#     table <- html$tblRpt
#     table$year <- j
#     output_raw <- list.append(output_raw, table)
#   }
# }
# save(output_raw, file = "PID/2016_data/output_2016.Rdata")

# load output data
load("PID/2016_data/output_2016.Rdata")

# merge all years/provinces for output data
output <- do.call(rbind, output_raw)
# all variables character
output <- as.data.frame(apply(output, 2, as.character), stringsAsFactors = F)
# update names
names(output) <- c("comm_name", "vill_name", "outputs", "quantity", "total_value", "cs_fund", "local_cont",
                   "depr", "year")
# remove commas and Rs from the funding variables
output$quantity <- gsub(",|R", "", output$quantity)
output$total_value <- gsub(",|R", "", output$total_value)
output$cs_fund <- gsub(",|R", "", output$cs_fund)

# new empty variables
output[c("contract_id", "activity", "comm_num")]<- NA

for(i in 1:nrow(output)) {
  if(output$comm_name[i]=="") {
    
    ref <- which(output$comm_name!="")
    ref2 <- ref[which.min(1/(ref-i))]
    
    ref3 <- min(i-1+which(output$comm_name[i:nrow(output)]!=""))
    rows <- ref3-ref2-1
    
    output$total_value[i] <- as.numeric(output$quantity[ref2])/rows
    output$cs_fund[i] <- as.numeric(output$total_value[ref2])/rows
    output$local_cont[i] <- as.numeric(output$cs_fund[ref2])/rows
    
    output$contract_id[i] <- output$vill_name[ref2]
    output$activity[i] <- output$outputs[ref2]
    
    output$comm_num[i] <- unlist(strsplit(output$comm_name[ref2], ","))[1]
  }
}
output <- output[output$comm_name=="",]

output$new_repair <- sapply(output$outputs, function(x) {unlist(strsplit(x, "\\]"))[1]})
output$contract_id <- as.numeric(gsub("/|-", "", output$contract_id))

output$mergevar <- paste(output$contract_id, output$vill_name, output$quantity)
output <- output[!(output$mergevar %in% output$mergevar[duplicated(output$mergevar)]),]

contract_output$mergevar <- paste(contract_output$contract_id, contract_output$vill_name, contract_output$quantity)
contract_output <- contract_output[!(contract_output$mergevar %in% contract_output$mergevar[duplicated(contract_output$mergevar)]),]

contract_output <- merge(contract_output, output, by="mergevar")

contract_output$end_month_actual <- month(as.Date(contract_output$end_actual, format = "%d-%b-%Y"))
contract_output$end_year_actual <- year(as.Date(contract_output$end_actual, format = "%d-%b-%Y"))
contract_output$end_month_planned <- month(as.Date(contract_output$end_planned, format = "%d-%b-%Y"))
contract_output$end_year_planned <- year(as.Date(contract_output$end_planned, format = "%d-%b-%Y"))
contract_output$start_month_actual <- month(as.Date(contract_output$start_actual, format = "%d-%b-%Y"))
contract_output$start_year_actual <- year(as.Date(contract_output$start_actual, format = "%d-%b-%Y"))
contract_output$start_month_planned <- month(as.Date(contract_output$start_planned, format = "%d-%b-%Y"))
contract_output$start_year_planned <- year(as.Date(contract_output$start_planned, format = "%d-%b-%Y"))

###

projects <- read_excel("pid/PID2019-2016-new.xlsx", sheet = 2)
contracts <- read_excel("pid/PID2019-2016-new.xlsx", sheet = 1)

contracts_dates <- read_excel("PID/PID2019-2016-new.xlsx", sheet = 1, col_types = "date")
contracts[c("PlannedStartOn", "ActualWorkStartOn",
            "PlannedCompletionOn", "ActualWorkCompletionOn")] <- contracts_dates[c("PlannedStartOn", "ActualWorkStartOn",
                                                                                   "PlannedCompletionOn", "ActualWorkCompletionOn")]

pre_pid <- merge(projects, contracts, by.x = "Id", by.y = "Reference")

pre_pid$end_month_actual <- month(as.Date(pre_pid$ActualWorkCompletionOn, format = "%Y-%m-%d"))
pre_pid$end_year_actual <- year(as.Date(pre_pid$ActualWorkCompletionOn, format = "%Y-%m-%d"))
pre_pid$end_month_planned <- month(as.Date(pre_pid$PlannedCompletionOn, format = "%Y-%m-%d"))
pre_pid$end_year_planned <- year(as.Date(pre_pid$PlannedCompletionOn, format = "%Y-%m-%d"))
pre_pid$start_month_actual <- month(as.Date(pre_pid$ActualWorkStartOn, format = "%Y-%m-%d"))
pre_pid$start_year_actual <- year(as.Date(pre_pid$ActualWorkStartOn, format = "%Y-%m-%d"))
pre_pid$start_month_planned <- month(as.Date(pre_pid$PlannedStartOn, format = "%Y-%m-%d"))
pre_pid$start_year_planned <- year(as.Date(pre_pid$PlannedStartOn, format = "%Y-%m-%d"))

pre_pid$mergevar <- paste(pre_pid$AreaCode.x, pre_pid$end_month_planned, pre_pid$end_year_planned, 
                          pre_pid$start_month_planned, pre_pid$start_year_planned, pre_pid$Id.y)

contract_output$mergevar <- paste(contract_output$comm_num, contract_output$end_month_planned, contract_output$end_year_planned, 
                                  contract_output$start_month_planned, contract_output$start_year_planned, contract_output$contract_id.x)
contract_output$matchid <- seq(1, nrow(contract_output), 1)

pid <- merge(pre_pid, contract_output, by="mergevar")
names(pid)[which(names(pid)=="Id.y")][1] <- "comm_num2"
pid <- pid[pid$status=="100 %",]

pid$total_value <- as.numeric(pid$total_value)
pid$cs_fund <- as.numeric(pid$cs_fund)
pid$local_cont <- as.numeric(pid$local_cont)
for(i in 1:nrow(pid)) {
  pid$total_value[i] <- pid$total_value[i]/sum(pid$matchid==pid$matchid[i])
  pid$cs_fund[i] <- pid$cs_fund[i]/sum(pid$matchid==pid$matchid[i])
  pid$local_cont[i] <- pid$local_cont[i]/sum(pid$matchid==pid$matchid[i])
}

pid$tempvar <- paste(pid$Id.x, pid$Id.y)
pid2 <- pid[!duplicated(pid$tempvar),]

pid$n_bidders <- ifelse(grepl("\\)", pid$n_bidders),
                        gsub('[\\(\\)]| |"', "", regmatches(pid$n_bidders, gregexpr("\\(.*?\\)", pid$n_bidders))),
                        pid$n_bidders)

for(i in unique(pid2$tempvar)) {
  pid2$quantity[pid2$tempvar==i] <- paste(pid$quantity.x[pid$tempvar==i], collapse = "|")
  pid2$new_repair[pid2$tempvar==i] <- paste(pid$new_repair[pid$tempvar==i], collapse = "|")
  pid2$n_bidders[pid2$tempvar==i] <- paste(pid$n_bidders[pid2$tempvar==i], collapse = "|")
}

pid2 <- pid2[,c("Id.x", "contract_id.x", "activity", "NameEn", "new_repair", "start_year_planned.x", 
                "start_month_planned.x", "end_year_planned.x", "end_month_planned.x", "start_year_actual.x", 
                "start_month_actual.x", "end_year_actual.x", "end_month_actual.x", "last_report", "status", 
                "n_bidders", "cs_fund", "local_cont", "Id.y")]

names(pid2) <- c("project_id", "contract_id", "activity_type", "activity_desc", "new_repair", "start_year_planned",
                 "start_month_planned", "end_year_planned", "end_month_planned", "start_year_actual", 
                 "start_month_actual", "end_year_actual", "end_month_actual", "last_report", "status", "n_bidders",
                 "cs_fund", "local_cont", "vill_id")

pid2$pid_id <- seq(300001, (300000+nrow(pid2)), 1)

# write.csv(pid2, "pid/completed_pid/pid_2016.csv", row.names = F)

