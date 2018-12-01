
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

insheet using "ProcessedData/cdb_panel.csv", clear

replace communename = "" if strpos(communename, "n.a") > 0

replace year = year + 2007

unab varlist: mal_tot fem_tot km_road hrs_road km_p_sch baby_die_midw baby_die_tba thatch_r ///
	zin_fibr_r tile_r flat_r_mult flat_r_one villa_r that_r_elec z_fib_r_elec til_r_elec ///
	flat_mult_elec flat_one_elec villa_r_elec

foreach i of local varlist {
	replace `i' = "." if `i' == "NA"
	destring `i', replace
	mvencode `i' if `i' == ., mv(0)
}

gen electricity = that_r_elec + z_fib_r_elec + til_r_elec + flat_mult_elec + flat_one_elec + villa_r_elec
gen electric_dummy = (electricity>0)

gen infant_mort = baby_die_midw + baby_die_tba

replace boxenddatetype = "." if boxenddatetype == "NA"
destring boxenddatetype, replace
replace pointenddatetype = "." if pointenddatetype == "NA"
destring pointenddatetype, replace

encode provincename, gen(provincenumber)

* replace communenumber = "." if communenumber == "NA"
replace uniquecommunename = "" if strpos(uniquecommunename, "n.a") > 0
encode uniquecommunename, gen(communenumber)

* formatting missing data values for the treatment date variable
replace pointearliestenddate = "." if pointearliestenddate == "NA"
destring pointearliestenddate, replace
replace boxearliestenddate = "." if boxearliestenddate == "NA"
destring boxearliestenddate, replace

* generating the "village within cell" treatment variable 
gen within_trt = 0
replace within_trt = 1 if year >= pointearliestenddate

* generating the "village surrounding cell" treatment variable
gen border_trt = 0
replace border_trt = 1 if year >= boxearliestenddate

*****************************

xtset cell_id year

* dummy dependent variable indicating whether any homes in cell i in year j have electricity
xtivreg2 electric_dummy within_trt, fe cluster(communenumber year)
est sto a1
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={1 if any village in cell i is attached to electricity grid, 0 otherwise}. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 electric_dummy within_trt border_trt, fe cluster(communenumber year)
est sto a2
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 electric_dummy within_trt border_trt i.year, fe cluster(communenumber year)
est sto a3
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe electric_dummy within_trt border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto a4
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(within_trt border_trt)
reghdfe electric_dummy within_trt border_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a5
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(within_trt border_trt)

* continuous dependent variable measuring # of infant deaths in cell i in year j
xtivreg2 infant_mort within_trt, fe cluster(communenumber year)
est sto b1
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={# of infant deaths in cell i in year j}. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 infant_mort within_trt border_trt, fe cluster(communenumber year)
est sto b2
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 infant_mort within_trt border_trt i.year, fe cluster(communenumber year)
est sto b3
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe infant_mort within_trt border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto b4
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(within_trt border_trt)
reghdfe infant_mort within_trt border_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b5
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(within_trt border_trt)

* hrs_road = Time taken to get from village to nearest year-road by motor or motorboat
xtivreg2 hrs_road within_trt, fe cluster(communenumber year)
est sto c1
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={Time taken to get from village to nearest year-road by motor or motorboat}. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 hrs_road within_trt border_trt, fe cluster(communenumber year)
est sto c2
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 hrs_road within_trt border_trt i.year, fe cluster(communenumber year)
est sto c3
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe hrs_road within_trt border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto c4
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(within_trt border_trt)
reghdfe hrs_road within_trt border_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c5
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(within_trt border_trt)

*******************
	
cd "Results/cdb"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}
