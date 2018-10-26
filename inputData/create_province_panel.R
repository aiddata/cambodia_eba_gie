#-----------------------------
# GIE of Cambodia Public Infrastructure and Local Governance Program
# For SIDA / EBA
# Merging Seila and AIMS pretreatment data with Gazetteer province data and
# creating a pseudo-panel dataset of Seila/AIMS projects
#------------------------------

setwd("~/box sync/cambodia_eba_gie")

library(readxl)
library(RCurl)

#pull in AIMS data
aims <- read.csv("inputdata/pretreatment/aims.csv", stringsAsFactors = F)[,-1]
#pull in Gazetteer data with province names and IDs
province.data <- read_xlsx("inputdata/National Gazetteer 2014.xlsx")[4:5]
#pull in Seila data
seila <- read.csv("inputdata/pretreatment/Seila.csv", stringsAsFactors = F)

#no AIMS data for the Tboung Khmum province. Ensuring AIMS province names correspond exactly to Gazetteer province 
#names for merging purposes
provinces <- names(aims)[4:28] <- c("Kampong Chhnang", "Kampong Thom", "Pursat", "Kampot", "Prey Veng", "Svay Rieng",
                       "Takeo", "Nation Wide", "Koh Kong", "Kampong Cham", "Kampong Speu", "Kratie", 
                       "Pailin", "Banteay Meanchey", "Phnom Penh", "Battambang", "Preah Sihanouk", 
                       "Preah Vihear", "Siem Reap", "Oddar Meanchey", "Kep", "Ratanak Kiri", 
                       "Stung Treng", "Kandal", "Mondul Kiri")
#removing the "X" from the column names of the year dummies in the AIMS data
years <- names(aims)[29:54] <- as.numeric(gsub("X", "", names(aims)[29:54]))

#setting the year dummy equal to one for each year after the treatment takes effect (originally was only equal to one
#on the specific year it took effect). This makes computing total years of funding easier 
for(i in 1:nrow(aims)) {
  x <- which(names(aims)==as.character(years)[1])-1
  temp <- x+which(aims[i,as.character(years)]==1)
  aims[i, temp:54] <- 1
  if(is.na(aims[i,"Total.Budget"])){
    aims[i,"Total.Budget"] <-0
  }
}

#for each project in the AIMS data, computing the product of the total number of provinces the project took place in
#by the total number of years the project took place. This value is used to compute the average project budget allocated 
#to each province in each year of the project.

#we are splitting the years into 1993-2005 and 2006-2018 and placing 2x weight on the later set of years when computing 
#average budget allocation
aims$firsthalf_years_provs <- rowSums(aims[as.character(1993:2005)])*rowSums(aims[provinces])
aims$secondhalf_years_provs <- rowSums(aims[as.character(2006:2018)])*rowSums(aims[provinces])
#computing the average budget allocated to each project in each year for the years 1993-2005
aims$avg_expend_firsthalf <- aims$Total.Budget/(aims$firsthalf_years_provs + (2*aims$secondhalf_years_provs))
#computing the average budget allocated to each project in each year for the years 2006-2018. Each year/project unit
#in the 2006-2018 subset is assigned twice the budget allocation of each year/project unit for 1993-2005
aims$avg_expend_secondhalf <- aims$avg_expend_firsthalf*2


### Merging AIMS data with Gazetteer data ###

#matching AIMS names with Gazetteer names
province.data[17,2] <- "Siem Reap"
#merging AIMS data with Gazetteer data based on province name
province.data <- merge(as.data.frame(provinces, stringsAsFactors = F), province.data,
                       by.x = "provinces", by.y = names(province.data)[2], all=T)

#generating new columns for total number of projects taking place in each province in each year and also for total dollar
#amount going into each province each year from these projects
new.variables <- paste0(rep(c("aims.count","aims.sum"), each=length(years)), years)
#combining the existing province data frame with these new columns
province.data <- cbind(province.data, as.data.frame(matrix(NA, nrow = nrow(province.data), 
                                                        ncol = length(new.variables),
                                                        dimnames = list(c(),new.variables))))

#filling the new columns with the total n projects and total amount of funding in each province each year
for(i in 1:nrow(province.data)) {
  temp.data <- aims[which(aims[,which(colnames(aims)==province.data[i,1])]==1),]

  province.data[i,new.variables] <- c(colSums(temp.data[as.character(years)]),
                                      as.vector(t(as.matrix(temp.data[as.character(1993:2005)])) %*% as.matrix(temp.data["avg_expend_firsthalf"])),
                                      as.vector(t(as.matrix(temp.data[as.character(2006:2018)])) %*% as.matrix(temp.data["avg_expend_secondhalf"])))
}

### Merging province panel with Seila data ###

#editing Seila column names for percent communes receiving treatment within each province
names(seila)[10:17] <- gsub("X.", "seila_pct_communes_", names(seila)[10:17])
#editing Seila column names for treatment dummies
names(seila)[2:9] <- gsub("X", "seila_trt_", names(seila)[2:9])
#editing Seila province names to align with province.data names for easier merging
seila[1,"provinces"] <- "Siem Reap"

#merging Seila data into the province panel data
province.data <- merge(province.data, seila, by="provinces", all = T)

#exporting the province level panel dataset containing both the AIMS and Seila data into Box Sync
#write.csv(province.data, "processedData/aims_seila_data.csv", row.names = F)
