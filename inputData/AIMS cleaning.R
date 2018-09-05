##Load Libraries and Data
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(reshape2)

#AIMS = read_excel("C:/Users/rrotberg/Desktop/Cambodia EBA/cambodia control variable.xlsx")
AIMS = read_excel("/Users/christianbaehr/Documents/GitHub/cambodia_eba_gie/inputData/cambodia control variable.xlsx")

### Reorder Variables
camb_names = names(AIMS)
order_of_names = c("ID", "Project Title", "Start", "Completion", "Project Status", "Province", "Sector",
                   "Sub Sector", "Total Budget", "Project Objectives")

camb_names = setdiff(camb_names, order_of_names)
AIMS = AIMS %>% select(order_of_names, camb_names)



###
all_provinces = na.omit(unique(unlist(str_split(AIMS$Province, pattern = " / "))))

province_dummies = as.data.frame(sapply(all_provinces, function(j) as.numeric(grepl(j, AIMS$Province))))
#province_dummies = province_dummies %>% gather("Province", "Dummy", 1:25)
## May need to fix spelling
AIMS = cbind.data.frame(AIMS, province_dummies)

AIMS = AIMS %>% filter(!is.na(`Project Title`))

completion_year =c(colsplit(AIMS$Completion, "-", c("day", "month", "Year"))[3])[[1]]
completion_year = str_sub(completion_year, 1, 4)

completion_dummies = sapply(completion_year, function(j) as.numeric(grepl(j, completion_year)))
completion_dummies = as.data.frame(completion_dummies[, !duplicated(t(completion_dummies))])

missing_years_names = c(as.character(seq(1994, 1999)), "2002", as.character(seq(2015, 2018)))

missing_years = as.data.frame(matrix(rep(0, (84*11)), nrow = 84, ncol = 11))
names(missing_years) = missing_years_names
completion_dummies = cbind.data.frame(completion_dummies, missing_years)
completion_dummies = completion_dummies[,order(colnames(completion_dummies))]
AIMS = cbind.data.frame(AIMS, completion_dummies)
AIMS = AIMS %>% select(ID,`Project Title`, 43:93)

write.csv(AIMS, "/Users/christianbaehr/Box Sync/cambodia_eba_gie/inputData/AIMS.csv")
