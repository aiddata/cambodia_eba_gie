
setwd("~/box sync/cambodia_eba_gie")

panel <- read.csv("ProcessedData/panel.csv", stringsAsFactors = F)

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

village1 <- test.data$village.code[1]
View(test.data[test.data$village.code==village1,])

grep(as.character(village1), grid_1000_matched_data$village_point_ids)
grep(as.character(village1), grid_1000_matched_data$village_box_ids)
View(grid_1000_matched_data[grep(as.character(village1), grid_1000_matched_data$village_box_ids),])

grep(as.character(village1), pid2008$vill.id)
grep(as.character(village1), pid2012$vill.id)
grep(as.character(village1), pid2016$vill.id)
View(pid2008[grep(as.character(village1), pid2008$vill.id),])







grep(as.character(village1), pid2008$vill.id)
View(pid2008[c(12297,12300),])

grep(as.character(village1), pid2012$vill.id)
View(pid2012[c(1392, 1393),])

grep(as.character(village1), pid2016$vill.id)
View(pid2016[grep(as.character(village1), pid2016$vill.id),])

###

village2 <- 6011504
View(test.data[test.data$village.number==village2,])






