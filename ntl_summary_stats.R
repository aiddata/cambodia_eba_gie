library(stargazer)

setwd("/Users/christianbaehr/Box Sync/cambodia_eba_gie")

panel <- read.csv("processeddata/panel.csv", stringsAsFactors = F)

panel$total_treated <- by(panel$intra_cell_count+panel$border_cell_count, factor(panel$cell_id), FUN = sum)

panel$year <- panel$year+1991

panel$ntl_1992 <- ifelse(panel$year==1992, panel$ntl, NA)
panel$baseline_ntl_treated <- ifelse(panel$year==2002 & panel$total_treated>0, panel$ntl, NA)
panel$endline_ntl_treated <- ifelse(panel$year==2013 & panel$total_treated>0, panel$ntl, NA)


stargazer(panel[,c("ntl","ntl_1992","baseline_ntl_treated","endline_ntl_treated","intra_cell_count",
                   "border_cell_count")], 
          type="html",
          covariate.labels=c("NTL", "1992 NTL", "Baseline NTL (treatment cells)", "Endline NTL (treatment cells)",
                             "Intra-cell project count", "Border-cell project count"),
          omit.summary.stat=c("n"), out = "report/ntl_sum_stats.html")







