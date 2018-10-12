
library(XML)
library(dplyr)
#library(rlist)

# data <- list()
# 
# for(i in 1:25) {
#   for(j in 2013:2016) {
#       url <- paste0("http://db.ncdd.gov.kh/pid/reports/monitoring/contractsummary.castle?pv=", i, "&year=", j)
#       
#       x <- readHTMLTable(url)
#       
#       y <- x[[2]]
#       data[[paste0(j, i)]] <- y[-1,]
#   }
# }

load("~/Box Sync/cambodia_eba_gie/PID/pid_excel_2016/pid_2016_r_list.RData")


data=x[-92]

for(i in 1:99) {
  temp <- mutate_all(data[[i]], as.character)
  new.data <- temp
  
  new.data$district <- NA
  districts <- new.data$Commune[which(is.na(new.data$Village))]
  dist.rows <- c(which(is.na(new.data$Village)), nrow(new.data))
  
  for(j in 1:(length(dist.rows)-1)) {
    new.data$district[dist.rows[j]:dist.rows[j+1]] <- districts[j]
  }
  new.data <- new.data[-dist.rows[-length(dist.rows)],]
  
  new.data$comm2 <- new.data$Commune
  communes <- new.data$Commune[which(new.data$Commune != "")]
  comm.rows <- c(which(new.data$Commune != ""), nrow(new.data))
  
  # for(k in 1:(length(comm.rows)-1)) {
  #   new.data$comm2[comm.rows[k]:comm.rows[k+1]] <- communes[k] 
  # }
  
  
  #######
  
  new.data$village.id <- NA
  villages <- new.data$Village[which(new.data$Commune != "")]
  new.data$activity <- NA
  activities <- new.data$Outputs[which(new.data$Commune != "")]
  
  new.data$cs.fund <- NA
  cs.fund <- new.data$`C/S Fund`[which(new.data$Commune != "")]
  
  new.data$local.cont <- NA
  local.cont <- new.data$`Local Contrib.`[which(new.data$Commune != "")]
  
  for(k in 1:(length(comm.rows)-1)) {
    new.data$comm2[comm.rows[k]:comm.rows[k+1]] <- communes[k]
    new.data$village.id[comm.rows[k]:comm.rows[k+1]] <- villages[k]
    new.data$activity[comm.rows[k]:comm.rows[k+1]] <- activities[k]
    
    y <- length(comm.rows[k]:comm.rows[k+1])-2
    
    cs.fund2 <- unlist(strsplit(cs.fund[k]," "))[1]
    cs.fund2 <- gsub(",", "", cs.fund2)
    local.cont2 <- unlist(strsplit(local.cont[k]," "))[1]
    local.cont2 <- gsub(",", "", local.cont2)
    
    cs.fund2 <- as.numeric(cs.fund2)/y
    local.cont2 <- as.numeric(local.cont2)/y
    
    new.data$cs.fund[comm.rows[k]:comm.rows[k+1]] <- cs.fund2
    new.data$local.cont[comm.rows[k]:comm.rows[k+1]] <- local.cont2
    
    
    
  }

  new.data <- new.data[-comm.rows[-length(comm.rows)],]
  
  #######
  new.data <- new.data[,-1]
  names(new.data)[names(new.data)=="comm2"] <- "commune"
  
  
  data[[i]] <- new.data
}

#####

test <- data[[1]]
test$`C/S Fund` <- gsub(",", "", test$`C/S Fund`)
sum(as.numeric(unlist(str_split(test$`C/S Fund`, " "))), na.rm = )

#####
names <- c("Banteay Meanchey", "Battambang", "Kampong Cham", "Kampong Chhnang", "Kampong Speu", "Kampong Thom", "Kampot", 
  "Kandal", "Koh Kong", "Kratie", "Mondul Kiri", "Phnom Penh", "Preah Vihear", "Prey Veng", "Pursat", "Ratanak Kiri", 
  "Siemreap", "Preah Sihanouk", "Stung Treng", "Svay Rieng", "Takeo", "Oddar Meanchey", "Kep", "Pailin", "Tboung Khmum")

save(x, file = "~/Box Sync/cambodia_eba_gie/PID/pid_excel_2016/pid_2016_r_list.RData")



# for(i in 1:100) {
#   assign(names(data)[i], data[[i]])
#   
#   write.csv(assign(names(data)[i], data[[i]]), paste("2016pid", names(data)[i], ".csv"), row.names = F)
# }









