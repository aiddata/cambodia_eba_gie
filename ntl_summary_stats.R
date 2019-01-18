library(stargazer)

setwd("/Users/christianbaehr/Box Sync/cambodia_eba_gie")

panel <- read.csv("report/ntl_sum_stats.csv", stringsAsFactors = F)

panel$total_treated <- by(panel$intra_cell_count+panel$border_cell_count, factor(panel$cell_id), FUN = sum)

panel$ntl_1992 <- ifelse(panel$year==1992, panel$ntl, NA)
panel$baseline_ntl_treated <- ifelse(panel$year==2002 & panel$total_treated>0, panel$ntl, NA)
panel$endline_ntl_treated <- ifelse(panel$year==2013 & panel$total_treated>0, panel$ntl, NA)

irrigation <- read.csv("processeddata/heterogeneous_effects/panel_irrigation_only.csv", stringsAsFactors = F)
water <- read.csv("processeddata/heterogeneous_effects/panel_rural-domestic-water_only.csv", stringsAsFactors = F)
rural_transport <- read.csv("processeddata/heterogeneous_effects/panel_rural-transport_only.csv", stringsAsFactors = F)
urban_transport <- read.csv("processeddata/heterogeneous_effects/panel_urban-transport_only.csv", stringsAsFactors = F)
uni_village <- read.csv("processeddata/panel_uni-village_projectsONLY.csv", stringsAsFactors = F)
multi_village <- read.csv("processeddata/panel_multi-village_projectsONLY.csv", stringsAsFactors = F)
new_project <- read.csv("processeddata/panel_newProjects.csv", stringsAsFactors = F)
repair_project <- read.csv("processeddata/panel_repairProjects.csv", stringsAsFactors = F)
upgrade_project <- read.csv("processeddata/panel_upgradeProjects.csv", stringsAsFactors = F)

panel$mergevar <- paste(as.character(panel$cell_id), as.character(panel$year))
irrigation$mergevar <- paste(as.character(irrigation$cell_id), as.character(irrigation$year+1991))
water$mergevar <- paste(as.character(water$cell_id), as.character(water$year+1991))
rural_transport$mergevar <- paste(as.character(rural_transport$cell_id), as.character(rural_transport$year+1991))
urban_transport$mergevar <- paste(as.character(urban_transport$cell_id), as.character(urban_transport$year+1991))
uni_village$mergevar <- paste(as.character(uni_village$cell_id), as.character(uni_village$year+1991))
multi_village$mergevar <- paste(as.character(multi_village$cell_id), as.character(multi_village$year+1991))
new_project$mergevar <- paste(as.character(new_project$cell_id), as.character(new_project$year+1991))
repair_project$mergevar <- paste(as.character(repair_project$cell_id), as.character(repair_project$year+1991))
upgrade_project$mergevar <- paste(as.character(upgrade_project$cell_id), as.character(upgrade_project$year+1991))

irrigation <- irrigation[,c("intra_cell_count", "border_cell_count", "mergevar")]
water <- water[,c("intra_cell_count", "border_cell_count", "mergevar")]
rural_transport <- rural_transport[,c("intra_cell_count", "border_cell_count", "mergevar")]
urban_transport <- urban_transport[,c("intra_cell_count", "border_cell_count", "mergevar")]
uni_village <- uni_village[,c("intra_cell_count", "border_cell_count", "mergevar")]
multi_village <- multi_village[,c("intra_cell_count", "border_cell_count", "mergevar")]
new_project <- new_project[,c("intra_cell_count", "border_cell_count", "mergevar")]
repair_project <- repair_project[,c("intra_cell_count", "border_cell_count", "mergevar")]
upgrade_project <- upgrade_project[,c("intra_cell_count", "border_cell_count", "mergevar")]

panel2 <- merge(panel, irrigation, by="mergevar")
panel2 <- merge(panel2, water, by="mergevar")
panel2 <- merge(panel2, rural_transport, by="mergevar")
panel2 <- merge(panel2, urban_transport, by="mergevar")
panel2 <- merge(panel2, uni_village, by="mergevar")
panel2 <- merge(panel2, multi_village, by="mergevar")
panel2 <- merge(panel2, new_project, by="mergevar")
panel2 <- merge(panel2, repair_project, by="mergevar")
panel2 <- merge(panel2, upgrade_project, by="mergevar")

a <- c("irrigation", "water", "rural_transport", "urban_transport", "uni_village", "multi_village", "new_project", 
       "repair_project", "upgrade_project")
names(panel2) <- c("mergevar", names(panel)[-length(names(panel))], as.vector(outer(c("intra_cell_count", "border_cell_count"), a, paste, sep=".")))

stargazer(panel[,c("ntl","ntl_1992","baseline_ntl_treated","endline_ntl_treated", "project_count")], type="html",
          covariate.labels=c("NTL", "NTL, 1992", "NTL (treatment cells only), 2002", "NTL (treatment cells only), 2013",
                             "CSF Project Count"),
          omit.summary.stat=c("n", "p25", "p75"), title = "NTL Panel Summary Statistics (Grid Cell-level)", out = "report/ntl_sum_stats_main.html")

panel2$project_count.uni_village <- panel2$intra_cell_count.uni_village + panel2$border_cell_count.uni_village
panel2$project_count.multi_village <- panel2$intra_cell_count.multi_village + panel2$border_cell_count.multi_village
panel2$project_count.new_project <- panel2$intra_cell_count.new_project + panel2$border_cell_count.new_project
panel2$project_count.repair_project <- panel2$intra_cell_count.repair_project + panel2$border_cell_count.repair_project
panel2$project_count.upgrade_project <- panel2$intra_cell_count.upgrade_project + panel2$border_cell_count.upgrade_project

stargazer(panel2[,c("project_count.uni_village", "project_count.multi_village", "project_count.new_project", 
                    "project_count.repair_project", "project_count.upgrade_project")], 
          type="html",
          covariate.labels=c("Single-village project count", "Multi-village project count", "New project count", "Repair project count", 
                             "Upgrade project count"),
          omit.summary.stat=c("n", "p25", "p75"), title = "NTL Panel Project Counts for Specific Subsets (Grid Cell-level)", 
          out = "report/ntl_sum_stats_additional.html")

panel.irrigation <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/report/tables/ntl_sum_stats_irrigation.csv", stringsAsFactors = F)
panel.irrigation$sector <- "irrigation"
panel.irrigation <- panel.irrigation[,c("cell_id", "year", "ntl", "total_count", "sector", "intra_cell_count", "border_cell_count", "projects_dummy")]
panel.rural_trans <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/report/tables/ntl_sum_stats_ruralTrans.csv", stringsAsFactors = F)
panel.rural_trans$sector <- "rural_trans"
panel.rural_trans <- panel.rural_trans[,c("cell_id", "year", "ntl", "total_count", "sector", "intra_cell_count", "border_cell_count", "projects_dummy")]
panel.urban_trans <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/report/tables/ntl_sum_stats_urbanTrans.csv", stringsAsFactors = F)
panel.urban_trans$sector <- "urban_trans"
panel.urban_trans <- panel.urban_trans[,c("cell_id", "year", "ntl", "total_count", "sector", "intra_cell_count", "border_cell_count", "projects_dummy")]
panel.water <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/report/tables/ntl_sum_stats_water.csv", stringsAsFactors = F)
panel.water$sector <- "water"
panel.water <- panel.water[,c("cell_id", "year", "ntl", "total_count", "sector", "intra_cell_count", "border_cell_count", "projects_dummy")]

panel3 <- rbind(panel.irrigation, panel.rural_trans)
panel3 <- rbind(panel3, panel.urban_trans)
panel3 <- rbind(panel3, panel.water)

panel3$project_count.irrigation <- ifelse(panel3$sector=="irrigation", panel3$intra_cell_count+panel3$border_cell_count, NA)
panel3$project_count.ruraltrans <- ifelse(panel3$sector=="rural_trans", panel3$intra_cell_count+panel3$border_cell_count, NA)
panel3$project_count.urbantrans <- ifelse(panel3$sector=="urban_trans", panel3$intra_cell_count+panel3$border_cell_count, NA)
panel3$project_count.water <- ifelse(panel3$sector=="water", panel3$intra_cell_count+panel3$border_cell_count, NA)

panel3$ntl.irrigation <- ifelse(panel3$sector=="irrigation", panel3$ntl, NA)
panel3$ntl.ruraltrans <- ifelse(panel3$sector=="rural_trans", panel3$ntl, NA)
panel3$ntl.urbantrans <- ifelse(panel3$sector=="urban_trans", panel3$ntl, NA)
panel3$ntl.water <- ifelse(panel3$sector=="water", panel3$ntl, NA)

panel3$ntl.irrigation_1992 <- ifelse(panel3$sector=="irrigation" & panel3$year==1992, panel3$ntl, NA)
panel3$ntl.ruraltrans_1992 <- ifelse(panel3$sector=="rural_trans" & panel3$year==1992, panel3$ntl, NA)
panel3$ntl.urbantrans_1992 <- ifelse(panel3$sector=="urban_trans" & panel3$year==1992, panel3$ntl, NA)
panel3$ntl.water_1992 <- ifelse(panel3$sector=="water" & panel3$year==1992, panel3$ntl, NA)

panel3$ntl.irrigation_2002 <- ifelse(panel3$sector=="irrigation" & panel3$year==2002, panel3$ntl, NA)
panel3$ntl.ruraltrans_2002 <- ifelse(panel3$sector=="rural_trans" & panel3$year==2002, panel3$ntl, NA)
panel3$ntl.urbantrans_2002 <- ifelse(panel3$sector=="urban_trans" & panel3$year==2002, panel3$ntl, NA)
panel3$ntl.water_2002 <- ifelse(panel3$sector=="water" & panel3$year==2002, panel3$ntl, NA)

panel3$ntl.irrigation_2013 <- ifelse(panel3$sector=="irrigation" & panel3$year==2013, panel3$ntl, NA)
panel3$ntl.ruraltrans_2013 <- ifelse(panel3$sector=="rural_trans" & panel3$year==2013, panel3$ntl, NA)
panel3$ntl.urbantrans_2013 <- ifelse(panel3$sector=="urban_trans" & panel3$year==2013, panel3$ntl, NA)
panel3$ntl.water_2013 <- ifelse(panel3$sector=="water" & panel3$year==2013, panel3$ntl, NA)

stargazer(panel3[,c("ntl.irrigation", "ntl.irrigation_1992", "ntl.irrigation_2002", "ntl.irrigation_2013", "project_count.irrigation")], 
          type="html",
          covariate.labels=c("NTL, Irrigation treated cells", "NTL, Irrigation treated cells, 1992", 
                             "NTL, Irrigation treated cells, 2002", "NTL, Irrigation treated cells, 2013", "Irrigation project count"),
          omit.summary.stat=c("n", "p25", "p75"), title = "NTL Panel Irrigation-specific Summary Statistics (Grid Cell-level)", 
          out = "report/ntl_sum_stats_irrigation.html")

stargazer(panel3[,c("ntl.ruraltrans", "ntl.ruraltrans_1992", "ntl.ruraltrans_2002", "ntl.ruraltrans_2013", "project_count.ruraltrans")], 
          type="html",
          covariate.labels=c("NTL, Rural transport treated cells", "NTL, Rural transport treated cells, 1992", 
                             "NTL, Rural transport treated cells, 2002", "NTL, Rural transport treated cells, 2013", 
                             "Rural Transport project count"),
          omit.summary.stat=c("n", "p25", "p75"), title = "NTL Panel Rural Transport-specific Summary Statistics (Grid Cell-level)", 
          out = "report/ntl_sum_stats_ruralTrans.html")

stargazer(panel3[,c("ntl.urbantrans", "ntl.urbantrans_1992", "ntl.urbantrans_2002", "ntl.urbantrans_2013", "project_count.urbantrans")], 
          type="html",
          covariate.labels=c("NTL, Urban transport treated cells", "NTL, Urban transport treated cells, 1992",
                             "NTL, Urban transport treated cells, 2002", "NTL, Urban transport treated cells, 2013", 
                             "Urban transport project count"),
          omit.summary.stat=c("n", "p25", "p75"), title = "NTL Panel Urban Transport-specific Summary Statistics (Grid Cell-level)", 
          out = "report/ntl_sum_stats_urbanTrans.html")

stargazer(panel3[,c("ntl.water", "ntl.water_1992", "ntl.water_2002", "ntl.water_2013", "project_count.water")], 
          type="html",
          covariate.labels=c("NTL, Domestic water treated cells", "NTL, Domestic water treated cells, 1992", 
                             "NTL, Domestic water treated cells, 2002", "NTL, Domestic water treated cells, 2013",
                             "Domestic water project count"),
          omit.summary.stat=c("n", "p25", "p75"), title = "NTL Panel Domestic Water-specific Summary Statistics (Grid Cell-level)", 
          out = "report/ntl_sum_stats_water.html")

###################

cdb_sum_stats <- read.csv("ProcessedData/cdb_panel_sum_stats.csv", stringsAsFactors = F)

cdb_sum_stats$infant_mort <- cdb_sum_stats$baby_die_midw + cdb_sum_stats$baby_die_tba
cdb_sum_stats$electricity <- cdb_sum_stats$that_r_elec + cdb_sum_stats$z_fib_r_elec + cdb_sum_stats$til_r_elec + cdb_sum_stats$villa_r_elec
cdb_sum_stats$electric_dummy <- ifelse(cdb_sum_stats$electricity>0, 1, 0)

stargazer(cdb_sum_stats[,c("infant_mort","electric_dummy","hh_wealth","pc1","treatment_count")], type="html",
          covariate.labels=c("Infant Mortality","Electricity grid access indicator","Household Wealth (unweighted)","Household wealth (weighted)",
                             "Number of Projects"),
          omit.summary.stat=c("n", "p25", "p75"), title = "CDB Panel Summary Statistics (village-level)", out = "Report/cdb_sum_stats.html")

###################

pid <- read.csv("/Users/christianbaehr/Box Sync/cambodia_eba_gie/ProcessedData/pid.csv", stringsAsFactors = F)
pid$irrigation <- ifelse(pid$activity.type=="Irrigation", 1, 0)
pid$rural_trans <- ifelse(pid$activity.type=="Rural Transport", 1, 0)
pid$urban_trans <- ifelse(pid$activity.type=="Urban transport", 1, 0)
pid$water <- ifelse(pid$activity.type=="Rural Domestic Water Supplies", 1, 0)

pid$multi <- NA
for(i in unique(pid$project.id)) {
  temp <- pid[which(pid$project.id==i),]
  pid$multi[which(pid$project.id==i)] <- ifelse(length(unique(temp$village.code))>1, 1, 0)
}
pid$uni <- ifelse(pid$multi==0, 1, 0)

pid$new <- ifelse(pid$new.repair=="New", 1, 0)
pid$repair <- ifelse(pid$new.repair=="Repair", 1, 0)
pid$upgrade <- ifelse(pid$new.repair=="Upgrade", 1, 0)

stargazer(pid[,c("uni", "multi", "new", "repair", "upgrade", "irrigation", "rural_trans", "urban_trans", "water")], type="html",
          covariate.labels=c("% Single-Village Projects", "% Multi-Village Projects", "% New Projects", "% Repair Projects",
                             "% Upgrade Projects", "% Irrigation Projects", "% Rural Transport Projects", "% Urban Transport Projects",
                             "% Domestic Water Projects"),
          omit.summary.stat=c("p25", "p75", "min", "max", "sd", "n"), title = "CSF Project Breakdown", 
          out = "report/ntl_sum_stats_pct.html")










