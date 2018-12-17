
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

insheet using "ProcessedData/cdb_panel.csv", clear

replace year = year + 2007

unab varlist: family mal_tot fem_tot km_road hrs_road km_p_sch baby_die_midw baby_die_tba thatch_r ///
	zin_fibr_r tile_r flat_r_mult flat_r_one villa_r that_r_elec z_fib_r_elec til_r_elec ///
	flat_mult_elec flat_one_elec villa_r_elec fish_ro_boat trav_ro_boat fish_mo_boat ///
	trav_mo_boat m_boat_les1t m_boat_ov1t family_car bicy_num cow_num hors_num pig_fami ///
	goat_fami chick_fami duck_fami that_r_tv z_fib_r_tv til_r_tv flat_mult_tv flat_one_tv villa_r_tv

foreach i of local varlist {
	replace `i' = "" if `i' == "NA"
	destring `i', replace
	* mvencode `i' if `i' == ., mv(0)
}

* su flat_mult_elec
* replace flat_mult_elec = r(mean) if flat_mult_elec==.
* su flat_one_elec
* replace flat_one_elec = r(mean) if flat_one_elec==.

* gen electricity = that_r_elec + z_fib_r_elec + til_r_elec + flat_mult_elec + flat_one_elec + villa_r_elec
gen electricity = that_r_elec + z_fib_r_elec + til_r_elec + villa_r_elec
gen electric_dummy = (electricity>0)

gen infant_mort = baby_die_midw + baby_die_tba

encode province_name, gen(province_number)

gen unique_commune_name = province_name + district_name + commune_name
replace unique_commune_name = "" if strpos(unique_commune_name, "n.a") > 0
replace unique_commune_name = "" if unique_commune_name == "NA"
encode unique_commune_name, gen(commune_number)

gen time_to_trt = year - earliest_end_date

drop if hrs_road > 1000 & !mi(hrs_road)

***

xtset villgis year

xtivreg2 electric_dummy time_to_trt, fe cluster(commune_number year)
est sto a1
outreg2 using "Results/cdb_outcomes/electricity_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N)
xi:xtivreg2 electric_dummy time_to_trt i.year, fe cluster(commune_number year)
est sto a2
outreg2 using "Results/cdb_outcomes/electricity_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N) keep(time_to_trt)
reghdfe electric_dummy time_to_trt i.year, cluster(commune_number year) absorb(villgis)
est sto a3
outreg2 using "Results/cdb_outcomes/electricity_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y) keep(time_to_trt)

xtivreg2 infant_mort time_to_trt, fe cluster(commune_number year)
est sto b1
outreg2 using "Results/cdb_outcomes/infant_mortality_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N)
xi:xtivreg2 infant_mort time_to_trt i.year, fe cluster(commune_number year)
est sto b2
outreg2 using "Results/cdb_outcomes/infant_mortality_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N) keep(time_to_trt)
reghdfe infant_mort time_to_trt i.year, cluster(commune_number year) absorb(villgis)
est sto b3
outreg2 using "Results/cdb_outcomes/infant_mortality_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y) keep(time_to_trt)

xtivreg2 hrs_road time_to_trt, fe cluster(commune_number year)
est sto c1
outreg2 using "Results/cdb_outcomes/time_to_road_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N)
xi:xtivreg2 hrs_road time_to_trt i.year, fe cluster(commune_number year)
est sto c2
outreg2 using "Results/cdb_outcomes/time_to_road_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N) keep(time_to_trt)
reghdfe hrs_road time_to_trt i.year, cluster(commune_number year) absorb(villgis)
est sto c3
outreg2 using "Results/cdb_outcomes/time_to_road_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y) keep(time_to_trt)

***

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

***

pca electricity non_motor_boat motor_boat tv family_car thatch_r zin_fibr_r tile_r flat_r_mult flat_r_one villa_r ///
	bicy_num cow_num hors_num pig_fami goat_fami chick_fami duck_fami, comp(3)
predict pc1 pc2 pc3, score

unab varlist: electricity non_motor_boat motor_boat tv family_car thatch_r zin_fibr_r tile_r flat_r_mult flat_r_one villa_r ///
	bicy_num cow_num hors_num pig_fami goat_fami chick_fami duck_fami	

foreach i of local varlist {
	* egen max_var = max(`i'), by(villgis)
	* gen wealthvar_`i' = `i'/max_var
	* drop max_var
	* replace wealthvar_`i' = wealthvar_`i'/family
	gen wealthvar_`i' = `i'/family
}

egen hh_wealth = rowmean(wealthvar_electricity wealthvar_non_motor_boat wealthvar_motor_boat wealthvar_tv ///
	wealthvar_family_car wealthvar_thatch_r wealthvar_zin_fibr_r wealthvar_tile_r wealthvar_flat_r_mult ///
	wealthvar_flat_r_one wealthvar_villa_r wealthvar_bicy_num wealthvar_pig_fami ///
	wealthvar_goat_fami wealthvar_chick_fami wealthvar_duck_fami)

***
	
xtivreg2 hh_wealth time_to_trt, fe cluster(commune_number year)
est sto d1
outreg2 using "Results/cdb_outcomes/household_wealth_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N)
xi:xtivreg2 hh_wealth time_to_trt i.year, fe cluster(commune_number year)
est sto d2
outreg2 using "Results/cdb_outcomes/household_wealth_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N) keep(time_to_trt)
reghdfe hh_wealth time_to_trt i.year, cluster(commune_number year) absorb(villgis)
est sto d3
outreg2 using "Results/cdb_outcomes/household_wealth_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y) keep(time_to_trt)

xtivreg2 pc1 time_to_trt, fe cluster(commune_number year)
est sto e1
outreg2 using "Results/cdb_outcomes/princ_comp_1_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N)
xi:xtivreg2 pc1 time_to_trt i.year, fe cluster(commune_number year)
est sto e2
outreg2 using "Results/cdb_outcomes/princ_comp_1_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N) keep(time_to_trt)
reghdfe pc1 time_to_trt i.year, cluster(commune_number year) absorb(villgis)
est sto e3
outreg2 using "Results/cdb_outcomes/princ_comp_1_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y) keep(time_to_trt)

xtivreg2 pc2 time_to_trt, fe cluster(commune_number year)
est sto f1
outreg2 using "Results/cdb_outcomes/princ_comp_2_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N)
xi:xtivreg2 pc2 time_to_trt i.year, fe cluster(commune_number year)
est sto f2
outreg2 using "Results/cdb_outcomes/princ_comp_2_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N) keep(time_to_trt)
reghdfe pc2 time_to_trt i.year, cluster(commune_number year) absorb(villgis)
est sto f3
outreg2 using "Results/cdb_outcomes/princ_comp_2_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y) keep(time_to_trt)

xtivreg2 pc3 time_to_trt, fe cluster(commune_number year)
est sto g1
outreg2 using "Results/cdb_outcomes/princ_comp_3_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N) keep(time_to_trt)
xi:xtivreg2 pc3 time_to_trt i.year, fe cluster(commune_number year)
est sto g2
outreg2 using "Results/cdb_outcomes/princ_comp_3_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N) keep(time_to_trt)
reghdfe pc3 time_to_trt i.year, cluster(commune_number year) absorb(villgis)
est sto g3
outreg2 using "Results/cdb_outcomes/princ_comp_3_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y) keep(time_to_trt)

***

cd "Results/cdb_outcomes"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}
