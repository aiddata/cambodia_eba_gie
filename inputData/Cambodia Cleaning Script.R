##Load Libraries and Data
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)




########## Create Seila Binary Variable
#all_provinces=read_excel("C:/Users/rrotberg/Desktop/Cambodia EBA/province names census.xlsx")
all_provinces=read_excel("/Users/christianbaehr/Documents/GitHub/cambodia_eba_gie/inputData/province names census.xlsx")
all_provinces=all_provinces$Name_EN
provinces_in_seila = c("Siemreap", "Banteay Meanchey", "Battambang",
             "Pursat", "Ratanak Kiri", "Oddar Meanchey", "Pailin",
             "Kampong Cham", "Takeo", "Prey Veng", "Kampong Thom",
             "Kampot", "Svay Rieng", "Kampong Speu", "Kampong Chhnang",
             "Kratie", "Preah Vihear")
missing_provinces = setdiff(all_provinces, provinces_in_seila)
provinces = c(provinces_in_seila, missing_provinces)
Seila = as.data.frame(provinces)

y96_99 = c(rep(1,5), rep(0, 20))
y_00 = c(rep(1, 7), rep(0,18))
y_01 = c(rep(1, 12), rep(0, 13))
y_02 = c(rep(1, 17), rep(0, 8))
y_03 = c(rep(1, 17), rep(0, 8))

Seila$`1996` = y96_99
Seila$`1997` = y96_99
Seila$`1998` = y96_99
Seila$`1999` = y96_99
Seila$`2000` = y_00
Seila$`2001` = y_01
Seila$`2002` = y_02
Seila$`2003` = y_03

# write.csv(ps,"C:/Users/rrotberg/Desktop/Cambodia EBA/province_in_seila.csv")
# write.csv(Seila, "~/Desktop/cambodia_data/province_in_seila.csv")


#Seila_commune=read.csv("C:/Users/rrotberg/Desktop/Cambodia EBA/province_in_seila.csv")
Seila_commune=read.csv("/Users/christianbaehr/Documents/GitHub/cambodia_eba_gie/inputData/province_in_seila.csv")
Seila_commune$`%1996`= Seila_commune$X1996/Seila_commune$total_communes*100
Seila_commune$`%1997`= Seila_commune$X1997/Seila_commune$total_communes*100
Seila_commune$`%1998`= Seila_commune$X1998/Seila_commune$total_communes*100
Seila_commune$`%1999`= Seila_commune$X1999/Seila_commune$total_communes*100
Seila_commune$`%1996`= Seila_commune$X1996/Seila_commune$total_communes*100
Seila_commune$`%2000`= Seila_commune$X2000/Seila_commune$total_communes*100
Seila_commune$`%2001`= Seila_commune$X2001/Seila_commune$total_communes*100
Seila_commune$`%2002`= Seila_commune$X2002/Seila_commune$total_communes*100
Seila_commune$`%2003`= Seila_commune$X2003/Seila_commune$total_communes*100

Seila_commune=Seila_commune %>% select(provinces_in_seila,`%1996`, `%1997`,`%1998`,`%1999`,`%2000`,`%2001`,`%2002`,`%2003`)
names(Seila_commune)[1]="provinces"
Seila=left_join(Seila,Seila_commune)
Seila[is.na(Seila)]=0



#write.csv(Seila,"C:/Users/rrotberg/Desktop/Cambodia EBA/Seila.csv",row.names = F)
write.csv(Seila,"/Users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/Seila.csv",row.names = F)
