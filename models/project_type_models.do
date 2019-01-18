
set matsize 11000
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

***

insheet using "ProcessedData/panel_uni-village_projectsONLY.csv", clear

replace border_cell_enddate_type = "." if border_cell_enddate_type == "NA"
destring border_cell_enddate_type, replace
replace intra_cell_enddate_type = "." if intra_cell_enddate_type == "NA"
destring intra_cell_enddate_type, replace

replace year = year + 1991

replace province_name = "" if province_name == "NA"
encode province_name, gen(province_number)

encode unique_commune_name, gen(commune_number)
gen temp = (province_number==16 & strpos(unique_commune_name, "n.a") > 0)
drop if temp==1

gen project_count = intra_cell_count + border_cell_count

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/project_type_models.doc", replace noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("Single-Village Projects")

***

insheet using "ProcessedData/panel_multi-village_projectsONLY.csv", clear

replace border_cell_enddate_type = "." if border_cell_enddate_type == "NA"
destring border_cell_enddate_type, replace
replace intra_cell_enddate_type = "." if intra_cell_enddate_type == "NA"
destring intra_cell_enddate_type, replace

replace year = year + 1991

replace province_name = "" if province_name == "NA"
encode province_name, gen(province_number)

encode unique_commune_name, gen(commune_number)
gen temp = (province_number==16 & strpos(unique_commune_name, "n.a") > 0)
drop if temp==1

gen project_count = intra_cell_count + border_cell_count

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/project_type_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("Multi-Village Projects")

***

insheet using "ProcessedData/panel_newProjects.csv", clear

replace border_cell_enddate_type = "." if border_cell_enddate_type == "NA"
destring border_cell_enddate_type, replace
replace intra_cell_enddate_type = "." if intra_cell_enddate_type == "NA"
destring intra_cell_enddate_type, replace

replace year = year + 1991

replace province_name = "" if province_name == "NA"
encode province_name, gen(province_number)

encode unique_commune_name, gen(commune_number)
gen temp = (province_number==16 & strpos(unique_commune_name, "n.a") > 0)
drop if temp==1

gen project_count = intra_cell_count + border_cell_count

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/project_type_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("New Projects")

***

insheet using "ProcessedData/panel_repairProjects.csv", clear

replace border_cell_enddate_type = "." if border_cell_enddate_type == "NA"
destring border_cell_enddate_type, replace
replace intra_cell_enddate_type = "." if intra_cell_enddate_type == "NA"
destring intra_cell_enddate_type, replace

replace year = year + 1991

replace province_name = "" if province_name == "NA"
encode province_name, gen(province_number)

encode unique_commune_name, gen(commune_number)
gen temp = (province_number==16 & strpos(unique_commune_name, "n.a") > 0)
drop if temp==1

gen project_count = intra_cell_count + border_cell_count

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/project_type_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("Repair Projects")
	
***

insheet using "ProcessedData/panel_upgradeProjects.csv", clear

replace border_cell_enddate_type = "." if border_cell_enddate_type == "NA"
destring border_cell_enddate_type, replace
replace intra_cell_enddate_type = "." if intra_cell_enddate_type == "NA"
destring intra_cell_enddate_type, replace

replace year = year + 1991

replace province_name = "" if province_name == "NA"
encode province_name, gen(province_number)

encode unique_commune_name, gen(commune_number)
gen temp = (province_number==16 & strpos(unique_commune_name, "n.a") > 0)
drop if temp==1

gen project_count = intra_cell_count + border_cell_count

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/project_type_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("Upgrade Projects")

erase "Report/project_type_models.txt"

