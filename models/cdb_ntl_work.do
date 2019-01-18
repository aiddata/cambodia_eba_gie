
insheet using "/Users/christianbaehr/Box Sync/cambodia_eba_gie/processeddata/ntl_cdb_merge.csv", clear

* generating a unique ID for each province
encode province_name, gen(province_number)

* generating a unique ID for each commune
replace unique_commune_name = province_name + district_name + commune_name
*replace unique_commune_name = "" if strpos(unique_commune_name, "n.a") > 0
replace unique_commune_name = "" if unique_commune_name == "NA"
encode unique_commune_name, gen(commune_number)

* rename treatment variable

* replace count = "0" if count == "NA"
* destring count, replace
* rename count treatment_count

* rename count treatment_count
* replace treatment_count = "0" if treatment_count == "NA"
* gen count = treatment_count
* drop treatment_count
* encode count, gen(treatment_count)

* local macro of all variables in analysis
unab varlist: family mal_tot fem_tot km_road baby_die_midw baby_die_tba thatch_r ///
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

collapse (mean) ntl electric_dummy infant_mort pc1 commune_number province_number, by(villgis year) 
	
reghdfe electric_dummy ntl i.year, cluster(commune_number year) absorb(villgis)
outreg2 using "Report/cdb_ntl_models.doc", replace noni addtext("Year FEs", Y, "Village FEs", Y) keep(ntl)
reghdfe infant_mort ntl i.year, cluster(commune_number year) absorb(villgis)
outreg2 using "Report/cdb_ntl_models.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(ntl)
reghdfe pc1 ntl i.year, cluster(commune_number year) absorb(villgis)
outreg2 using "Report/cdb_ntl_models.doc", append noni addtext("Year FEs", Y, "Village FEs", Y) keep(ntl)






	

	
	
	
