
setwd("~/box sync/cambodia_eba_gie")

pid2008 <- read.csv("PID/completed_pid/pid_2008.csv", stringsAsFactors = F)

test2008 <- NULL
for(i in unique(pid2008$vill.id)) {
  temp <- pid2008[pid2008$vill.id==i,]
  
  if(length(unique(temp$project.id))!=1) {
    
    test2008[length(test2008)+1] <- T
    
  } 
  else {
    test2008[length(test2008)+1] <- F
  }
}
sum(test2008)

###################

pid2012 <- read.csv("PID/completed_pid/pid_2012.csv", stringsAsFactors = F)

test2012 <- NULL
for(i in unique(pid2012$vill.id)) {
  temp <- pid2012[pid2012$vill.id==i,]
  
  if(length(unique(temp$project.id))!=1) {
    
    test2012[length(test2012)+1] <- T
    
  } 
  else {
    test2012[length(test2012)+1] <- F
  }
}
sum(test2012)

###################

pid2016 <- read.csv("PID/completed_pid/pid_2016.csv", stringsAsFactors = F)

test2016 <- NULL
for(i in unique(pid2016$vill.id)) {
  temp <- pid2016[pid2016$vill.id==i,]
  
  if(length(unique(temp$project.id))!=1) {
    
    test2016[length(test2016)+1] <- T
    
  } 
  else {
    test2016[length(test2016)+1] <- F
  }
}
sum(test2016)

###################













