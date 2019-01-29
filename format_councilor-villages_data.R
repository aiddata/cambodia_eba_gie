
setwd("/Users/christianbaehr/Box Sync/cambodia_eba_gie")

library(readxl)
library(plyr)

temp_list <- list()
for(i in dir("inputData/councilors-villages_data")) {
  
  temp_data <- as.data.frame(read_xlsx(paste0("inputData/councilors-villages_data/", i), col_names = F))
  temp_data <- temp_data[,!is.na(temp_data[3,])]
  if(ncol(temp_data)==7){names(temp_data) <- as.character(c(1:7))}
  
  temp_list[[gsub("pg_|.xlsx", "", i)]] <- temp_data
}

temp_list <- temp_list[names(temp_list)!="24"]
y <- do.call("rbind", temp_list)

y <- y[complete.cases(y),]
y$`1` <- as.numeric(y$`1`)
y$`3` <- as.numeric(y$`3`)
y$`4` <- as.numeric(y$`4`)
y$`5` <- as.numeric(y$`5`)
y$`6` <- as.numeric(y$`6`)
y$`7` <- as.numeric(y$`7`)









