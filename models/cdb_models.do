
* set to your target directory
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

* read in CDB data
insheet using "ProcessedData/cdb_panel.csv", clear

* set year variable equal to actual year
replace year = year + 2007

* generating a unique ID for each province
encode province_name, gen(province_number)

* generating a unique ID for each commune
gen unique_commune_name = province_name + district_name + commune_name
*replace unique_commune_name = "" if strpos(unique_commune_name, "n.a") > 0
replace unique_commune_name = "" if unique_commune_name == "NA"
encode unique_commune_name, gen(commune_number)

* rename treatment variable
rename count treatment_count

* local macro of all variables in analysis
unab varlist: family mal_tot fem_tot km_road km_p_sch baby_die_midw baby_die_tba thatch_r ///
	zin_fibr_r tile_r flat_r_mult flat_r_one villa_r that_r_elec z_fib_r_elec til_r_elec ///
	flat_mult_elec flat_one_elec villa_r_elec fish_ro_boat trav_ro_boat fish_mo_boat ///
	trav_mo_boat m_boat_les1t m_boat_ov1t family_car bicy_num cow_fami hors_fami pig_fami ///
	goat_fami chick_fami duck_fami that_r_tv z_fib_r_tv til_r_tv flat_mult_tv flat_one_tv villa_r_tv

* formatting NA values and making each variable numeric
foreach i of local varlist {
	replace `i' = "" if `i' == "NA"
	destring `i', replace
}

* creating aggregate motorboat and NON-motor boat variables
gen non_motor_boat = fish_ro_boat + trav_ro_boat
gen motor_boat = fish_mo_boat + trav_mo_boat + m_boat_les1t + m_boat_ov1t

* creating aggregate television ownership variable
gen tv = villa_r_tv + that_r_tv + z_fib_r_tv + til_r_tv
* replacing NA values with the mean for the television variable
su tv
replace tv = r(mean) if tv==.

* creating aggregate variable of homes with electricity access
gen electricity = that_r_elec + z_fib_r_elec + til_r_elec + villa_r_elec
* creating dummy variable denoting any access to electricity grid in the village
gen electric_dummy = (electricity > 0)
replace electric_dummy = . if missing(electricity)
* creating aggregate infant mortality variable
gen infant_mort = baby_die_midw + baby_die_tba

* principal components analysis of household asset variables (retaining the first 3 components)
pca electricity non_motor_boat motor_boat tv family_car thatch_r zin_fibr_r tile_r villa_r bicy_num cow_fami ///
	pig_fami goat_fami chick_fami duck_fami, comp(3)
* generating predicted values of the first three principal components of the data
predict pc1 pc2 pc3, score

* local macro of household assets
unab varlist: electricity non_motor_boat motor_boat tv family_car thatch_r zin_fibr_r tile_r villa_r bicy_num ///
	cow_fami pig_fami goat_fami chick_fami duck_fami

* dividing each household asset variable by # of families in the village
foreach i of local varlist {
	gen wealthvar_`i' = `i'/family
}
* generating unweighted household asset index based on asset variables
egen hh_wealth = rowmean(wealthvar_electricity wealthvar_non_motor_boat wealthvar_motor_boat wealthvar_tv ///
	wealthvar_family_car wealthvar_thatch_r wealthvar_zin_fibr_r wealthvar_tile_r ///
	wealthvar_villa_r wealthvar_bicy_num wealthvar_pig_fami wealthvar_goat_fami wealthvar_chick_fami wealthvar_duck_fami)

outsheet using "ProcessedData/cdb_panel_sum_stats.csv", replace comma	

***

xtset village_code year

xtivreg2 electric_dummy treatment_count, fe cluster(commune_number year)
est sto a1
outreg2 using "Results/cdb_outcomes/electricity_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 electric_dummy treatment_count i.year, fe cluster(commune_number year)
est sto a2
outreg2 using "Results/cdb_outcomes/electricity_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe electric_dummy treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto a3
outreg2 using "Results/cdb_outcomes/electricity_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

xtivreg2 infant_mort treatment_count, fe cluster(commune_number year)
est sto b1
outreg2 using "Results/cdb_outcomes/infant_mortality_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 infant_mort treatment_count i.year, fe cluster(commune_number year)
est sto b2
outreg2 using "Results/cdb_outcomes/infant_mortality_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe infant_mort treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto b3
outreg2 using "Results/cdb_outcomes/infant_mortality_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)
	
xtivreg2 hh_wealth treatment_count, fe cluster(commune_number year)
est sto d1
outreg2 using "Results/cdb_outcomes/household_wealth_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 hh_wealth treatment_count i.year, fe cluster(commune_number year)
est sto d2
outreg2 using "Results/cdb_outcomes/household_wealth_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe hh_wealth treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto d3
outreg2 using "Results/cdb_outcomes/household_wealth_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

xtivreg2 pc1 treatment_count, fe cluster(commune_number year)
est sto e1
outreg2 using "Results/cdb_outcomes/princ_comp_1_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 pc1 treatment_count i.year, fe cluster(commune_number year)
est sto e2
outreg2 using "Results/cdb_outcomes/princ_comp_1_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe pc1 treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto e3
outreg2 using "Results/cdb_outcomes/princ_comp_1_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

xtivreg2 pc2 treatment_count, fe cluster(commune_number year)
est sto f1
outreg2 using "Results/cdb_outcomes/princ_comp_2_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 pc2 treatment_count i.year, fe cluster(commune_number year)
est sto f2
outreg2 using "Results/cdb_outcomes/princ_comp_2_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe pc2 treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto f3
outreg2 using "Results/cdb_outcomes/princ_comp_2_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

xtivreg2 pc3 treatment_count, fe cluster(commune_number year)
est sto g1
outreg2 using "Results/cdb_outcomes/princ_comp_3_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N) keep(treatment_count)
xi:xtivreg2 pc3 treatment_count i.year, fe cluster(commune_number year)
est sto g2
outreg2 using "Results/cdb_outcomes/princ_comp_3_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe pc3 treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto g3
outreg2 using "Results/cdb_outcomes/princ_comp_3_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

cd "Results/cdb_outcomes"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}

*******************

cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

winsor2 family that_r_elec z_fib_r_elec til_r_elec villa_r_elec baby_die_midw baby_die_tba fish_ro_boat trav_ro_boat ///
	fish_mo_boat trav_mo_boat m_boat_les1t m_boat_ov1t villa_r_tv that_r_tv z_fib_r_tv til_r_tv family_car thatch_r ///
	zin_fibr_r tile_r villa_r bicy_num cow_fami pig_fami goat_fami chick_fami duck_fami, cut(10 90) by(commune_number) suffix(_win)

gen electricity_win = that_r_elec_win + z_fib_r_elec_win + til_r_elec_win + villa_r_elec_win
gen electric_dummy_win = (electricity_win>0)

gen infant_mort_win = baby_die_midw_win + baby_die_tba_win

gen non_motor_boat_win = fish_ro_boat_win + trav_ro_boat_win
gen motor_boat_win = fish_mo_boat_win + trav_mo_boat_win + m_boat_les1t_win + m_boat_ov1t_win

gen tv_win = villa_r_tv_win + that_r_tv_win + z_fib_r_tv_win + til_r_tv_win
su tv_win
replace tv_win = r(mean) if tv_win==.

pca electricity_win non_motor_boat_win motor_boat_win tv_win family_car_win thatch_r_win zin_fibr_r_win tile_r_win ///
	villa_r_win bicy_num_win cow_fami_win pig_fami_win goat_fami_win chick_fami_win duck_fami_win, comp(3)
predict pc1_win pc2_win pc3_win, score

unab varlist: electricity_win non_motor_boat_win motor_boat_win tv_win family_car_win thatch_r_win zin_fibr_r_win ///
	tile_r_win villa_r_win bicy_num_win cow_fami_win pig_fami_win goat_fami_win chick_fami_win duck_fami_win	

foreach i of local varlist {
	gen wealthvar_`i'_win = `i'/family_win
}

egen hh_wealth_win = rowmean(wealthvar_electricity_win wealthvar_non_motor_boat_win wealthvar_motor_boat_win wealthvar_tv_win ///
	wealthvar_family_car_win wealthvar_thatch_r_win wealthvar_zin_fibr_r_win wealthvar_tile_r_win wealthvar_villa_r_win ///
	wealthvar_bicy_num_win wealthvar_pig_fami_win wealthvar_goat_fami_win wealthvar_chick_fami_win wealthvar_duck_fami_win)

***

xtset village_code year

xtivreg2 electric_dummy_win treatment_count, fe cluster(commune_number year)
est sto h1
outreg2 using "Results/cdb_outcomes/winsor/electricity_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 electric_dummy_win treatment_count i.year, fe cluster(commune_number year)
est sto h2
outreg2 using "Results/cdb_outcomes/winsor/electricity_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe electric_dummy_win treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto h3
outreg2 using "Results/cdb_outcomes/winsor/electricity_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

xtivreg2 infant_mort_win treatment_count, fe cluster(commune_number year)
est sto j1
outreg2 using "Results/cdb_outcomes/winsor/infant_mortality_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 infant_mort_win treatment_count i.year, fe cluster(commune_number year)
est sto j2
outreg2 using "Results/cdb_outcomes/winsor/infant_mortality_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe infant_mort_win treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto j3
outreg2 using "Results/cdb_outcomes/winsor/infant_mortality_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

xtivreg2 hh_wealth_win treatment_count, fe cluster(commune_number year)
est sto k1
outreg2 using "Results/cdb_outcomes/winsor/household_wealth_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 hh_wealth_win treatment_count i.year, fe cluster(commune_number year)
est sto k2
outreg2 using "Results/cdb_outcomes/winsor/household_wealth_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe hh_wealth_win treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto k3
outreg2 using "Results/cdb_outcomes/winsor/household_wealth_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

xtivreg2 pc1_win treatment_count, fe cluster(commune_number year)
est sto m1
outreg2 using "Results/cdb_outcomes/winsor/princ_comp_1_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 pc1_win treatment_count i.year, fe cluster(commune_number year)
est sto m2
outreg2 using "Results/cdb_outcomes/winsor/princ_comp_1_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(treatment_count)
reghdfe pc1_win treatment_count i.year, cluster(commune_number year) absorb(village_code)
est sto m3
outreg2 using "Results/cdb_outcomes/winsor/princ_comp_1_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(treatment_count)

cd "Results/cdb_outcomes/winsor"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}

*******************

cd"/Users/christianbaehr/box sync/cambodia_eba_gie/Results/cdb_outcomes"

gen time_to_trt = year - earliest_end_date
egen time_to_trt_p = cut(time_to_trt), at(-50 -4(1)8)

levelsof time_to_trt_p, loc(levels) sep()

foreach l of local levels{
	local j = `l' + 50
	local label `"`label' `j' "`l'" "'
	}

cap la drop time_to_trt_p `label'
la def time_to_trt_p `label', replace

replace time_to_trt_p = time_to_trt_p + 50
la values time_to_trt_p time_to_trt_p

unab varlist: electric_dummy infant_mort pc1
foreach i of local varlist {
	reghdfe `i' i.time_to_trt_p i.year, cluster(commune_number year) absorb(village_code)
	coefplot, keep(*.time_to_trt_p) xline(2) yline(0) vertical omit ///
		recast(line) color(blue) ciopts(recast(rline) color(blue) lp(dash)) graphregion(color(white)) ///
		bgcolor(white) xtitle("Years to Treatment") ytitle("Treatment effects on" `i')
	graph export `"time_to_trt/trt_byyear_`i'.png"', replace
}

reghdfe infant_mort i.time_to_trt_p i.year, cluster(commune_number year) absorb(village_code)
replace time_to_trt=time_to_trt+10
reghdfe infant_mort i.time_to_trt i.year, cluster(commune_number year) absorb(village_code)

xtset village_code year

xtivreg2 electric_dummy time_to_trt, fe cluster(commune_number year)
est sto a1
outreg2 using "time_to_trt/electricity_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 electric_dummy time_to_trt i.year, fe cluster(commune_number year)
est sto a2
outreg2 using "time_to_trt/electricity_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(time_to_trt)
reghdfe electric_dummy time_to_trt i.year, cluster(commune_number year) absorb(village_code)
est sto a3
outreg2 using "time_to_trt/electricity_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(time_to_trt)

xtivreg2 infant_mort time_to_trt, fe cluster(commune_number year)
est sto b1
outreg2 using "time_to_trt/infant_mortality_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 infant_mort time_to_trt i.year, fe cluster(commune_number year)
est sto b2
outreg2 using "time_to_trt/infant_mortality_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(time_to_trt)
reghdfe infant_mort time_to_trt i.year, cluster(commune_number year) absorb(village_code)
est sto b3
outreg2 using "time_to_trt/infant_mortality_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(time_to_trt)
	
xtivreg2 hh_wealth time_to_trt, fe cluster(commune_number year)
est sto d1
outreg2 using "time_to_trt/household_wealth_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 hh_wealth time_to_trt i.year, fe cluster(commune_number year)
est sto d2
outreg2 using "time_to_trt/household_wealth_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(time_to_trt)
reghdfe hh_wealth time_to_trt i.year, cluster(commune_number year) absorb(village_code)
est sto d3
outreg2 using "time_to_trt/household_wealth_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(time_to_trt)

xtivreg2 pc1 time_to_trt, fe cluster(commune_number year)
est sto e1
outreg2 using "time_to_trt/princ_comp_1_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 pc1 time_to_trt i.year, fe cluster(commune_number year)
est sto e2
outreg2 using "time_to_trt/princ_comp_1_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(time_to_trt)
reghdfe pc1 time_to_trt i.year, cluster(commune_number year) absorb(village_code)
est sto e3
outreg2 using "time_to_trt/princ_comp_1_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(time_to_trt)

xtivreg2 pc2 time_to_trt, fe cluster(commune_number year)
est sto f1
outreg2 using "time_to_trt/princ_comp_2_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N)
xi:xtivreg2 pc2 time_to_trt i.year, fe cluster(commune_number year)
est sto f2
outreg2 using "time_to_trt/princ_comp_2_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(time_to_trt)
reghdfe pc2 time_to_trt i.year, cluster(commune_number year) absorb(village_code)
est sto f3
outreg2 using "time_to_trt/princ_comp_2_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(time_to_trt)

xtivreg2 pc3 time_to_trt, fe cluster(commune_number year)
est sto g1
outreg2 using "time_to_trt/princ_comp_3_outcome.doc", replace noni addtext("Year FEs", N, "Village FEs", N) keep(time_to_trt)
xi:xtivreg2 pc3 time_to_trt i.year, fe cluster(commune_number year)
est sto g2
outreg2 using "time_to_trt/princ_comp_3_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", N) keep(time_to_trt)
reghdfe pc3 time_to_trt i.year, cluster(commune_number year) absorb(village_code)
est sto g3
outreg2 using "time_to_trt/princ_comp_3_outcome.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(time_to_trt)

cd "time_to_trt"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}



