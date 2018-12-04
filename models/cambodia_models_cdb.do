
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

insheet using "ProcessedData/cdb_panel.csv", clear

replace communename = "" if strpos(communename, "n.a") > 0

replace year = year + 1991

unab varlist: mal_tot fem_tot km_road hrs_road km_p_sch baby_die_midw baby_die_tba thatch_r ///
	zin_fibr_r tile_r flat_r_mult flat_r_one villa_r that_r_elec z_fib_r_elec til_r_elec ///
	flat_mult_elec flat_one_elec villa_r_elec fish_ro_boat trav_ro_boat fish_mo_boat ///
	trav_mo_boat m_boat_les1t m_boat_ov1t family_car bicy_num cow_num hors_num pig_fami ///
	goat_fami chick_fami duck_fami that_r_tv z_fib_r_tv til_r_tv flat_mult_tv flat_one_tv villa_r_tv

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
xtivreg2 electric_dummy pointcount if year>=2008, fe cluster(communenumber year)
est sto a1
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={1 if any village in cell i is attached to electricity grid, 0 otherwise}. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 electric_dummy pointcount boxcount if year>=2008, fe cluster(communenumber year)
est sto a2
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 electric_dummy pointcount boxcount i.year if year>=2008, fe cluster(communenumber year)
est sto a3
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe electric_dummy pointcount boxcount i.year if year>=2008, cluster(communenumber year) absorb(cell_id)
est sto a4
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe electric_dummy pointcount boxcount i.year c.year#i.provincenumber if year>=2008, cluster(communenumber year) absorb(cell_id)
est sto a5
outreg2 using "Results/cdb/cdb_models_electric_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)

* continuous dependent variable measuring # of infant deaths in cell i in year j
xtivreg2 infant_mort pointcount if year>=2008, fe cluster(communenumber year)
est sto b1
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={# of infant deaths in cell i in year j}. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 infant_mort pointcount boxcount if year>=2008, fe cluster(communenumber year)
est sto b2
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 infant_mort pointcount boxcount i.year if year>=2008, fe cluster(communenumber year)
est sto b3
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe infant_mort pointcount boxcount i.year if year>=2008, cluster(communenumber year) absorb(cell_id)
est sto b4
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe infant_mort pointcount boxcount i.year c.year#i.provincenumber if year>=2008, cluster(communenumber year) absorb(cell_id)
est sto b5
outreg2 using "Results/cdb/cdb_models_infant_mortality.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)

* hrs_road = Time taken to get from village to nearest year-road by motor or motorboat
xtivreg2 hrs_road pointcount if year>=2008, fe cluster(communenumber year)
est sto c1
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={Time taken to get from village to nearest year-road by motor or motorboat}. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 hrs_road pointcount boxcount if year>=2008, fe cluster(communenumber year)
est sto c2
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 hrs_road pointcount boxcount i.year if year>=2008, fe cluster(communenumber year)
est sto c3
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe hrs_road pointcount boxcount i.year if year>=2008, cluster(communenumber year) absorb(cell_id)
est sto c4
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe hrs_road pointcount boxcount i.year c.year#i.provincenumber if year>=2008, cluster(communenumber year) absorb(cell_id)
est sto c5
outreg2 using "Results/cdb/cdb_models_time_to_road.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)

*******************

gen non_motor_boat = fish_ro_boat + trav_ro_boat
gen motor_boat = fish_mo_boat + trav_mo_boat + m_boat_les1t + m_boat_ov1t

* should we just omit variables that have a high n of missing obs
su flat_mult_tv
replace flat_mult_tv = r(mean) if flat_mult_tv==.
su flat_one_tv
replace flat_one_tv = r(mean) if flat_one_tv==.
su villa_r_tv
replace villa_r_tv = r(mean) if villa_r_tv==.
gen tv = that_r_tv + z_fib_r_tv + til_r_tv + flat_mult_tv + flat_one_tv + villa_r_tv

su flat_r_one
replace flat_r_one = r(mean) if flat_r_one==.
su flat_r_mult
replace flat_r_mult = r(mean) if flat_r_mult==.

su cow_num
replace cow_num = r(mean) if cow_num==.
su hors_num
replace hors_num = r(mean) if hors_num==.


pca non_motor_boat motor_boat tv family_car thatch_r zin_fibr_r tile_r flat_r_mult flat_r_one villa_r ///
	bicy_num cow_num hors_num pig_fami goat_fami chick_fami duck_fami if year>=2008, comp(3)

predict pc1 pc2 pc3 if year>=2008, score

gen princ_comp = pc1 + pc2 + pc3

*******************

xtivreg2 princ_comp pointcount if year>=2008, fe cluster(communenumber year)
est sto c1
outreg2 using "Results/cdb/cdb_models_household_assets.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={Household asset index}. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 princ_comp pointcount boxcount if year>=2008, fe cluster(communenumber year)
est sto c2
outreg2 using "Results/cdb/cdb_models_household_assets.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 princ_comp pointcount boxcount i.year if year>=2008, fe cluster(communenumber year)
est sto c3
outreg2 using "Results/cdb/cdb_models_household_assets.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe princ_comp pointcount boxcount i.year if year>=2008, cluster(communenumber year) absorb(cell_id)
est sto c4
outreg2 using "Results/cdb/cdb_models_household_assets.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe princ_comp pointcount boxcount i.year c.year#i.provincenumber if year>=2008, cluster(communenumber year) absorb(cell_id)
est sto c5
outreg2 using "Results/cdb/cdb_models_household_assets.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)
	
cd "Results/cdb"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}

*******************










