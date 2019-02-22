
setwd("/Users/christianbaehr/Box sync/cambodia_eba_gie")

library(plyr); library(dplyr)

## read in all PID datasets and merge
pid2008 <- read.csv("PID/completed_pid/pid_2008.csv", stringsAsFactors = F)
pid2012 <- read.csv("PID/completed_pid/pid_2012.csv", stringsAsFactors = F)
pid2016 <- read.csv("PID/completed_pid/pid_2016.csv", stringsAsFactors = F)
pid <- do.call(rbind.fill, list(pid2008, pid2012, pid2016))

## removing observations with missing project or village IDs
pid <- pid[!is.na(pid$project_id) & !is.na(pid$vill_id),]

## remove all non-numeric digits from the project status variable and subset the 
## PID dataset to projects 100% complete
pid$status <- as.numeric(gsub("[^[:digit:]]", "", pid$status))
pid <- pid[which(pid$status==100),]

## remove special characters from the new/repair variable
pid$new_repair <- gsub("\\[| ", "", pid$new_repair)
pid$new_repair <- sapply(pid$new_repair, 
                         FUN = function(x) {paste(sort(unique(unlist(strsplit(x, "\\|")))), collapse = "|")})

pid$pct_comp_bid <- sapply(pid$n_bidders, FUN = function(x) {1-mean(as.numeric(unlist(strsplit(x, "\\|"))) %in% c(0, 1), na.rm = T)})

## removing special characters from the CS Fund and Local Contribution variables

names(pid) <- c("project.id", "contract.id", "activity.type", "activity.desc", "new.repair", "actual.start.yr", 
                "actual.start.mo", "actual.end.yr", "actual.end.mo", "last.report","status", "n.bidders",
                "cs.fund", "local.cont", "vill.id", "pid_id", "planned.start.yr", "planned.start.mo", 
                "planned.end.yr", "planned.end.mo", "pct_comp_bid")

# write.csv(pid, "PID/completed_pid/pid_merge.csv", row.names = F)

