
panel <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/panel.csv", stringsAsFactors = F)

test.data <- panel[sample(c(1:nrow(panel)), 5, replace = F),]
View(test.data)

###################

grid_1000_matched_data <- read.csv("inputdata/village_grid_files/grid_1000_matched_data.csv",
                                   stringsAsFactors = F)
merge_grid_1000_lite <- read.csv("inputdata/village_grid_files/merge_grid_1000_lite.csv",
                                 stringsAsFactors = F)
grid_1000_matched_data <- merge(grid_1000_matched_data, merge_grid_1000_lite, by = "cell_id")

pid2008 <- read.csv("pid/completed_pid/pid_2008.csv", stringsAsFactors = F)
pid2012 <- read.csv("pid/completed_pid/pid_2012.csv", stringsAsFactors = F)
pid2016 <- read.csv("pid/completed_pid/pid_2016.csv", stringsAsFactors = F)

###################

village1 <- 14010913
View(test.data[test.data$village.number==village1,])

grep(as.character(village1), grid_1000_matched_data$village_point_ids)
View(grid_1000_matched_data[40028,])

grep(as.character(village1), pid2008$vill.id)
View(pid2008[c(12297,12300),])

grep(as.character(village1), pid2012$vill.id)
View(pid2012[c(1392, 1393),])

grep(as.character(village1), pid2016$vill.id)
View(pid2016[c(8590, 8591, 8592),])

###

village2 <- 6011504
View(test.data[test.data$village.number==village2,])





















