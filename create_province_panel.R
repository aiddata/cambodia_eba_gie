library(readxl)


setwd("/Users/christianbaehr/Desktop/temp")

aims <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/AIMS.csv")[,-1]

#no AIMS data for the Tboung Khmum province
provinces <- names(aims)[4:28] <- c("Kampong Chhnang", "Kampong Thom", "Pursat", "Kampot", "Prey Veng", "Svay Rieng",
                       "Takeo", "Nation Wide", "Koh Kong", "Kampong Cham", "Kampong Speu", "Kratie", 
                       "Pailin", "Banteay Meanchey", "Phnom Penh", "Battambang", "Preah Sihanouk", 
                       "Preah Vihear", "Siem Reap", "Oddar Meanchey", "Kep", "Ratanak Kiri", 
                       "Stung Treng", "Kandal", "Mondul Kiri")
years <- names(aims)[29:54] <- as.numeric(gsub("X", "", names(aims)[29:54]))

for(i in 1:nrow(aims)) {
  x <- which(names(aims)==as.character(years)[1])-1
  temp <- x+which(aims[i,as.character(years)]==1)
  aims[i, temp:54] <- 1
  if(is.na(aims[i,"Total.Budget"])){
    aims[i,"Total.Budget"] <-0
  }
}

aims$firsthalf_years_provs <- rowSums(aims[as.character(1993:2005)])*rowSums(aims[provinces])
aims$secondhalf_years_provs <- rowSums(aims[as.character(2006:2018)])*rowSums(aims[provinces])
aims$avg_expend_firsthalf <- aims$Total.Budget/(aims$firsthalf_years_provs + (2*aims$secondhalf_years_provs))
aims$avg_expend_secondhalf <- aims$avg_expend_firsthalf*2


province.data <- as.data.frame(read_excel("/Users/christianbaehr/Desktop/gazetteer_data.xlsx")[,4:5])
province.data[25,] <- c(0, "Nation Wide")
province.data[17,2] <- "Siem Reap"
province.data <- merge(as.data.frame(provinces, stringsAsFactors = F), province.data,
                       by.x = "provinces", by.y = names(province.data)[2])

new.variables <- paste0(rep(c("count","sum"), each=length(years)), years)
province.data <- cbind(province.data, as.data.frame(matrix(NA, nrow = nrow(province.data), 
                                                        ncol = length(new.variables),
                                                        dimnames = list(c(),new.variables))))

for(i in 1:nrow(province.data)) {
  temp.data <- aims[which(aims[,which(colnames(aims)==province.data[i,1])]==1),]

  province.data[i,new.variables] <- c(colSums(temp.data[as.character(years)]),
                                      as.vector(t(as.matrix(temp.data[as.character(1993:2005)])) %*% as.matrix(temp.data["avg_expend_firsthalf"])),
                                      as.vector(t(as.matrix(temp.data[as.character(2006:2018)])) %*% as.matrix(temp.data["avg_expend_secondhalf"])))
}


seila <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/Seila.csv")






