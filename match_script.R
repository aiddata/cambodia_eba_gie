
library(plyr)
library(sf)
library(readxl)
library(stringr)

setwd("~/box sync/cambodia_eba_gie")

#reading gazetteer data in
gazetteer.data <- as.data.frame(read_excel("inputdata/National Gazetteer 2014.xlsx", 
                                           sheet = 4))
gazetteer.data$Id <- as.character(gazetteer.data$Id)
gazetteer.data$Name_EN <- toupper(as.character(gazetteer.data$Name_EN))

#some gazetteer village names include numbers at the end indicating whether that village is a duplicate. I omit these numbers
#and later manually omit duplicates from the data
no.nums <- as.character(1:10)
for(i in 1:nrow(gazetteer.data)) {
  if(any(strsplit(gazetteer.data$Name_EN[i], split = " ")[[1]] %in% no.nums)) {
    temp <- strsplit(gazetteer.data$Name_EN[i], split = " ")[[1]]
    gazetteer.data$Name_EN[i] <- paste(temp[1:(length(temp)-1)], collapse = " ")
  }
}

###################

#reading punwath data in
punwath.data <- as.data.frame(st_read("inputdata/Cphum09-84-2016/Cphum09-84-2016.shp",
                                      stringsAsFactors = F))
punwath.data$Code_Phum <- as.character(punwath.data$Code_Phum)
punwath.data$Phum_Rom <- toupper(as.character(punwath.data$Phum_Rom))
punwath.data$unverified <- 1

###################

#reading shape data in
shape.data <- as.data.frame(st_read("inputdata/census_2008_villages/Village.shp", 
                                    stringsAsFactors = F))
shape.data$VILL_CODE <- as.character(as.numeric(shape.data$VILL_CODE))
shape.data$VILL_NAME <- toupper(as.character(shape.data$VILL_NAME))
shape.data$unverified <- 0
#some village codes include an extra 0 at the front of the number. I omit this zero to prevent incorrect mismatches
# for(i in 1:nrow(shape.data)) {
#   temp.id <- strsplit(shape.data[i, "VILL_CODE"], split = "")[[1]]
#   if (temp.id[1]=="0") {
#     shape.data[i, "VILL_CODE"] <- paste0(temp.id[2:length(temp.id)], collapse = "")
#   }
# }

###################

#merging shape data and gazetteer data based on IDs
gazetteer.shape.match1 <- merge(shape.data, gazetteer.data, by.x = "VILL_CODE", by.y = "Id")

gazetteer.data.nomatch1 <- gazetteer.data[!(gazetteer.data$Id %in% shape.data$VILL_CODE),]
shape.data.nomatch1 <- shape.data[!(shape.data$VILL_CODE %in% gazetteer.data$Id),]

#merging Punwath data and gazetteer data based on IDs
gazetteer.punwath.match1 <- merge(punwath.data, gazetteer.data.nomatch1, by.x = "Code_Phum", by.y = "Id")

gazetteer.data.nomatch2 <- gazetteer.data.nomatch1[!(gazetteer.data.nomatch1$Id %in% punwath.data$Code_Phum),]
punwath.data.nomatch1 <- punwath.data[!(punwath.data$Code_Phum %in% gazetteer.data.nomatch1$Id),]


###################

#removing observations from shape data if their names have duplicates in the data
shape.data.duplicate <- shape.data.nomatch1$VILL_NAME[duplicated(shape.data.nomatch1$VILL_NAME)]
shape.data.nomatch1$duplicate <- NULL
for(i in 1:nrow(shape.data.nomatch1)) {
  if(shape.data.nomatch1$VILL_NAME[i] %in% shape.data.duplicate) {
    shape.data.nomatch1$duplicate[i] <- TRUE
  } else {
    shape.data.nomatch1$duplicate[i] <- FALSE
  }
}

#removing observations from punwath data if their names have duplicates in the data
punwath.data.duplicate <- punwath.data.nomatch1$Phum_Rom[duplicated(punwath.data.nomatch1$Phum_Rom)]
punwath.data.nomatch1$duplicate <- NULL
for(i in 1:nrow(punwath.data.nomatch1)) {
  if(punwath.data.nomatch1$Phum_Rom[i] %in% punwath.data.duplicate) {
    punwath.data.nomatch1$duplicate[i] <- TRUE
  } else {
    punwath.data.nomatch1$duplicate[i] <- FALSE
  }
}

#removing observations from the gazetteer data if their names have duplicates in the data
gazetteer.data.duplicate <- gazetteer.data.nomatch2$Name_EN[duplicated(gazetteer.data.nomatch2$Name_EN)]
gazetteer.data.nomatch2$duplicate <- NULL
for(i in 1:nrow(gazetteer.data.nomatch2)) {
  if(gazetteer.data.nomatch2$Name_EN[i] %in% gazetteer.data.duplicate) {
    gazetteer.data.nomatch2$duplicate[i] <- TRUE
  } else {
    gazetteer.data.nomatch2$duplicate[i] <- FALSE
  }
}

shape.data.nomatch1.noduplicates <- shape.data.nomatch1[!shape.data.nomatch1$duplicate,]
punwath.data.nomatch1.noduplicates <- punwath.data.nomatch1[!punwath.data.nomatch1$duplicate,]
gazetteer.data.nomatch2.noduplicates <- gazetteer.data.nomatch2[!gazetteer.data.nomatch2$duplicate,]

#from the gazetteer and shape data that hasnt already been merged, merging the gazetteer data with the shape data
#that doesnt have duplicated names, based on names
gazetteer.shape.match2 <- merge(shape.data.nomatch1.noduplicates, gazetteer.data.nomatch2,
                                by.x = "VILL_NAME", by.y = "Name_EN")
gazetteer.data.nomatch3 <- gazetteer.data.nomatch2.noduplicates[!(gazetteer.data.nomatch2.noduplicates$Name_EN %in% 
                                                       shape.data.nomatch1.noduplicates$VILL_NAME),] 
shape.data.nomatch2 <- shape.data.nomatch1.noduplicates[!(shape.data.nomatch1.noduplicates$VILL_NAME %in% 
                                                            gazetteer.data.nomatch3),]
#from the gazetteer and punwath data that hasnt already been merged, merging the gazetteer data with the punwath data
#that doesnt have duplicated names, based on names
gazetteer.punwath.match2 <- merge(punwath.data.nomatch1.noduplicates, gazetteer.data.nomatch3,
                                  by.x = "Phum_Rom", by.y = "Name_EN")
gazetteer.data.nomatch4 <- gazetteer.data.nomatch3[!(gazetteer.data.nomatch3$Name_EN %in% 
                                                                    punwath.data.nomatch1.noduplicates$Phum_Rom),]
punwath.data.nomatch2 <- punwath.data.nomatch1.noduplicates[!(punwath.data.nomatch1.noduplicates$Phum_Rom %in% 
                                                                gazetteer.data.nomatch4$Name_EN),]

#combining the data frames containing matches between the Punwath data and the gazetteer data
gazetteer.punwath.fullmatch <- rbind.fill(gazetteer.punwath.match1, gazetteer.punwath.match2)
gazetteer.punwath.fullmatch$Name_EN[is.na(gazetteer.punwath.fullmatch$Name_EN)] <- 
  gazetteer.punwath.fullmatch$Phum_Rom[is.na(gazetteer.punwath.fullmatch$Name_EN)]
# gazetteer.punwath.fullmatch$Id[is.na(gazetteer.punwath.fullmatch$Id)] <- 
#   gazetteer.punwath.fullmatch$Code_Phum[is.na(gazetteer.punwath.fullmatch$Id)]

#combining the data frames containing matches between the shape data and the gazetteer data
gazetteer.shape.fullmatch <- rbind.fill(gazetteer.shape.match1, gazetteer.shape.match2)
gazetteer.shape.fullmatch$Name_EN[is.na(gazetteer.shape.fullmatch$Name_EN)] <- 
  gazetteer.shape.fullmatch$VILL_NAME[is.na(gazetteer.shape.fullmatch$Name_EN)]
# gazetteer.shape.fullmatch$Id[is.na(gazetteer.shape.fullmatch$Id)] <- 
#   gazetteer.shape.fullmatch$VILL_CODE[is.na(gazetteer.shape.fullmatch$Id)]

#retaining only necessary columns for the matched datasets and aligning column names
gazetteer.shape <- gazetteer.shape.fullmatch[,c("VILL_CODE", "ProvEn", "Name_EN", "geometry", "TOTPOP", "unverified")]
names(gazetteer.shape) <- c("vill_code", "province_name", "vill_name", "geometry", "total_pop", "unverified")
gazetteer.punwath <- gazetteer.punwath.fullmatch[,c("Code_Phum", "ProvEn", "Name_EN", "geometry", "unverified")]
names(gazetteer.punwath) <- c("vill_code", "province_name", "vill_name", "geometry", "unverified")

#binding matched shape/gazetteer data with matched punwath/gazetteer data

full.data <- rbind.fill(gazetteer.shape, gazetteer.punwath)
full.data$geo <- as.character(full.data$geometry)
full.data$geo <- gsub("c", "", full.data$geo)
full.data$geo <- gsub("\\(", "", full.data$geo)
full.data$geo <- gsub(")", "", full.data$geo)
full.data$geo <- gsub(" ", "", full.data$geo)

full.data$lat <- matrix(unlist(str_split(full.data$geo, ",")), ncol = 2, byrow = T)[,1]
full.data$long <- matrix(unlist(str_split(full.data$geo, ",")), ncol = 2, byrow = T)[,2]

full.data <- full.data[!duplicated(full.data$vill_code),]
write.csv(full.data[,c("vill_code", "vill_name", "province_name", "total_pop", "unverified", "lat", "long")], 
          "processeddata/matched_shape_data.csv", row.names = F)

