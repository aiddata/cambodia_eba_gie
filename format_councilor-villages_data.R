
setwd("/Users/christianbaehr/Box Sync/cambodia_eba_gie")

library(readxl)
library(plyr)
library(sp)
library(spatialEco)

temp_list <- list()
for(i in dir("inputData/governance/communes_councilors_2003")) {
  temp_data <- as.data.frame(read_xlsx(paste0("inputData/governance/communes_councilors_2003/", i), col_names = F))

  names(temp_data) <- c("comm_code", "comm_name", "n_councilors_03", "categoryA", "categoryB", "admin_funds_03", "dev_funds_03", "total_funds_03")  
  temp_list[[gsub("pg_|.xlsx", "", i)]] <- temp_data
}
communes_2003 <- do.call("rbind", temp_list)

communes_2003 <- communes_2003[!is.na(communes_2003$admin_funds_03),]
communes_2003 <- communes_2003[!is.na(communes_2003$comm_code),]
communes_2003 <- communes_2003[!is.na(communes_2003$comm_name),]

communes_2003$comm_code <- gsub(" ", "", communes_2003$comm_code)
communes_2003$comm_code <- gsub("\\I", "1", communes_2003$comm_code)

communes_2003$n_councilors_03 <- gsub("II|l l|I I|1 I", "11", communes_2003$n_councilors_03)

communes_2003$categoryA <- gsub("0", NA, communes_2003$categoryA)
communes_2003$categoryA <- ifelse(is.na(communes_2003$categoryA), NA, "1A")
communes_2003$categoryB <- ifelse(is.na(communes_2003$categoryB), NA, "1B")

communes_2003$admin_funds_03 <- gsub(",| |\\.", "", communes_2003$admin_funds_03)
communes_2003$dev_funds_03 <- gsub(",| |\\.", "", communes_2003$dev_funds_03)
communes_2003$dev_funds_03 <- gsub("I", "1", communes_2003$dev_funds_03)
communes_2003$total_funds_03 <- gsub(",| |\\.", "", communes_2003$total_funds_03)
communes_2003$total_funds_03 <- gsub("I", "1", communes_2003$total_funds_03)

communes_2003$n_councilors_03 <- as.numeric(communes_2003$n_councilors_03)

communes_2003$admin_funds_03 <- as.numeric(communes_2003$admin_funds_03)
communes_2003$dev_funds_03 <- as.numeric(communes_2003$dev_funds_03)
communes_2003$total_funds_03 <- as.numeric(communes_2003$total_funds_03)

communes_2003$comm_type <- ifelse(is.na(communes_2003$categoryA), communes_2003$categoryB, communes_2003$categoryA)
communes_2003 <- communes_2003[,c("comm_code", "comm_name", "comm_type", "n_councilors_03", "admin_funds_03",
                                  "dev_funds_03", "total_funds_03")]

###

temp_list <- list()
for(i in dir("inputData/governance/communes_councilors_2004")) {
  temp_data <- as.data.frame(read_xlsx(paste0("inputData/governance/communes_councilors_2004/", i), col_names = F))
  names(temp_data) <- c("comm_code", "comm_name", "n_councilors_04", "n_vill_in_comm", "admin_funds_04", "dev_funds_04", "total_funds_04")
  
  temp_list[[gsub("pg_|.xlsx", "", i)]] <- temp_data
}
communes_2004 <- do.call("rbind", temp_list)

communes_2004 <- communes_2004[!is.na(communes_2004$total_funds_04),]
communes_2004 <- communes_2004[!is.na(communes_2004$comm_code),]
communes_2004 <- communes_2004[!is.na(communes_2004$comm_name),]

communes_2004$comm_code <- gsub(" ", "", communes_2004$comm_code)
communes_2004$comm_code <- gsub("I|l", "1", communes_2004$comm_code)

communes_2004$n_councilors_04 <- gsub("II", "11", communes_2004$n_councilors_04)

communes_2004$n_vill_in_comm <- gsub("IO", "10", communes_2004$n_vill_in_comm)

communes_2004$admin_funds_04 <- gsub("\\.| |,", "", communes_2004$admin_funds_04)
communes_2004$dev_funds_04 <- gsub("\\.| |,", "", communes_2004$dev_funds_04)
communes_2004$total_funds_04 <- gsub("\\.| |,", "", communes_2004$total_funds_04)

communes_2004$admin_funds_04 <- as.numeric(communes_2004$admin_funds_04)
communes_2004$dev_funds_04 <- as.numeric(communes_2004$dev_funds_04)
communes_2004$total_funds_04 <- as.numeric(communes_2004$total_funds_04)

communes_2004$total_funds_04[communes_2004$comm_code=="40804"] <- 29000000
communes_2004$total_funds_04[communes_2004$comm_code=="210103"] <- 27000000

communes_2004 <- communes_2004[,c("comm_code", "n_councilors_04", "n_vill_in_comm", "admin_funds_04", "dev_funds_04",
                                  "total_funds_04")]

###

councilors_data <- merge(communes_2003, communes_2004, by="comm_code")
sum(councilors_data$n_councilors_03==councilors_data$n_councilors_04)

councilors_data <- councilors_data[,c("comm_code", "comm_name", "comm_type", "n_vill_in_comm", "n_councilors_03",
                                      "admin_funds_03", "dev_funds_03", "total_funds_03", "admin_funds_04", 
                                      "dev_funds_04", "total_funds_04")]

write.csv(councilors_data, "inputData/governance/councilors_data.csv", row.names = F)

