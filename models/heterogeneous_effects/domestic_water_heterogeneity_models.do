set matsize 11000
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

insheet using "ProcessedData/heterogeneous_effects/panel_rural-domestic-water_only.csv", clear

* dropping observations if the commune name variable contains NA values. Keeping these observations
* creates problematic clusters when clustering errors at commune level

replace border_cell_enddate_type = "." if border_cell_enddate_type == "NA"
destring border_cell_enddate_type, replace
replace intra_cell_enddate_type = "." if intra_cell_enddate_type == "NA"
destring intra_cell_enddate_type, replace

* replacing year index with actual year
replace year = year + 1991

replace province_name = "" if province_name == "NA"
encode province_name, gen(province_number)

* replace unique_commune_name = "" if strpos(unique_commune_name, "n.a") > 0
encode unique_commune_name, gen(commune_number)
gen temp = (province_number==16 & strpos(unique_commune_name, "n.a") > 0)
drop if temp==1

* formatting missing data values for the treatment date variable
replace intra_cell_earliest_enddate = "." if intra_cell_earliest_enddate == "NA"
destring intra_cell_earliest_enddate, replace
replace border_cell_earliest_enddate = "." if border_cell_earliest_enddate == "NA"
destring border_cell_earliest_enddate, replace

* generating the "village within cell" treatment variable 
gen intra_cell_treatment = 0
replace intra_cell_treatment = 1 if year >= intra_cell_earliest_enddate

* generating the "village surrounding cell" treatment variable
gen border_cell_treatment = 0
replace border_cell_treatment = 1 if year >= border_cell_earliest_enddate

* generating dependent variables

* ntl dummy
gen ntl_dummy = .
replace ntl_dummy = 0 if ntl == 0
replace ntl_dummy = 1 if ntl > 0

* binned ntl (rounded down)
egen ntl_binned = cut(ntl), at(0, 10, 20, 30, 40, 50, 60, 70)
* table ntl_binned, contents(min ntl max ntl)

gen total_count = intra_cell_count + border_cell_count
egen projects_dummy = sum(total_count), by(cell_id)
drop if projects_dummy == 0

outsheet using "Report/tables/ntl_sum_stats_water.csv", comma

***

cgmreg ntl_dummy intra_cell_count, cluster(commune_number year)
est sto a1
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_dummy.doc", replace noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
cgmreg ntl_dummy intra_cell_count border_cell_count, cluster(commune_number year)
est sto a2
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_dummy.doc", append noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl_dummy intra_cell_count border_cell_count, cluster(commune_number year) absorb(year)
est sto a3
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto a4
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto a5
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(intra_cell_count border_cell_count)

* NTL binned dependent variable

cgmreg ntl_binned intra_cell_count, cluster(commune_number year)
est sto b1
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_binned.doc", replace noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
cgmreg ntl_binned intra_cell_count border_cell_count, cluster(commune_number year)
est sto b2
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_binned.doc", append noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl_binned intra_cell_count border_cell_count, cluster(commune_number year) absorb(year)
est sto b3
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto b4
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto b5
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

* NTL continuous dependent variable

cgmreg ntl intra_cell_count, cluster(commune_number year)
est sto c1
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_continuous.doc", replace noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
cgmreg ntl intra_cell_count border_cell_count, cluster(commune_number year)
est sto c2
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_continuous.doc", append noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl intra_cell_count border_cell_count, cluster(commune_number year) absorb(year)
est sto c3
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto c4
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto c5
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/rural-domestic-water_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

***

gen project_count = intra_cell_count + border_cell_count
cgmreg ntl project_count, cluster(commune_number year)
est sto d1
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/merged_treatment/ntl_continuous.doc", replace noni nocons ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
cgmreg ntl project_count, cluster(commune_number year)
est sto d2
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/merged_treatment/ntl_continuous.doc", append noni nocons ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl project_count, cluster(commune_number year) absorb(year)
est sto d3
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/merged_treatment/ntl_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) keep(project_count)
reghdfe ntl project_count i.year, cluster(commune_number year) absorb(cell_id)
est sto d4
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/merged_treatment/ntl_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) keep(project_count)
reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto d5
outreg2 using "Results/heterogeneous_effects/rural_domestic_water/merged_treatment/ntl_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) keep(project_count)

***

cd "Results/heterogeneous_effects/rural_domestic_water"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}

