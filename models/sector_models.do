set matsize 11000
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

***

insheet using "ProcessedData/heterogeneous_effects/panel_rural-domestic-water_only.csv", clear

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
egen projects_dummy = sum(project_count), by(cell_id)
drop if projects_dummy == 0

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/sector_models.doc", replace noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("Rural Domestic Water Projects")

***

set matsize 11000
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

***

insheet using "ProcessedData/heterogeneous_effects/panel_irrigation_only.csv", clear

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
egen projects_dummy = sum(project_count), by(cell_id)
drop if projects_dummy == 0

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/sector_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("Irrigation Projects")

***

insheet using "ProcessedData/heterogeneous_effects/panel_rural-transport_only.csv", clear

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
egen projects_dummy = sum(project_count), by(cell_id)
drop if projects_dummy == 0

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/sector_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("Rural Transport Projects")

***

insheet using "ProcessedData/heterogeneous_effects/panel_urban-transport_only.csv", clear

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
egen projects_dummy = sum(project_count), by(cell_id)
drop if projects_dummy == 0

reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/sector_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(project_count) ctitle("Urban Transport Projects")

erase "Report/sector_models.txt"





