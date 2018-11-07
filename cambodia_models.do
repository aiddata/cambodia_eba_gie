
cd "/Users/christianbaehr"

insheet using "Box Sync/cambodia_eba_gie/ProcessedData/panel.csv", clear

* replacing year index with actual year
replace year = year + 1991

encode proven, gen(province)

* generating a numeric variable representing communes for clustering SEs
rename commid commune_id
drop cell_id
rename panel_id cell_id

* formatting missing data values for the treatment date variable
replace pointearliestenddate = "." if pointearliestenddate == "NA"
destring pointearliestenddate, replace
replace boxearliestenddate = "." if boxearliestenddate == "NA"
destring boxearliestenddate, replace

* generating the "village within cell" treatment variable 
gen within_trt = .
replace within_trt = 1 if pointearliestenddate != . & year >= pointearliestenddate
replace within_trt = 0 if pointearliestenddate == . | year < pointearliestenddate

* generating the "village surrounding cell" treatment variable
gen border_trt = .
replace border_trt = 1 if year >= boxearliestenddate
replace border_trt = 0 if year < boxearliestenddate

*******************

* NTL dummy dependent variable

gen ntl_dummy = .
replace ntl_dummy = 0 if ntl == 0
replace ntl_dummy = 1 if ntl > 0

xtset cell_id year

xtivreg2 ntl_dummy within_trt, fe cluster(commune_id year)
est sto a1
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_dummy.doc", replace noni ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("DV={0 if NTL=0, 1 otherwise}. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")

xtivreg2 ntl_dummy within_trt border_trt, fe cluster(commune_id year)
est sto a2
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_dummy.doc", append noni ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)

xi:xtivreg2 ntl_dummy within_trt border_trt i.year, fe cluster(commune_id year)
est sto a3
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_dummy.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) keep(within_trt border_trt)
	
reghdfe ntl_dummy within_trt border_trt i.year, cluster(commune_id year) absorb(cell_id)
est sto a4
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_dummy.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) keep(within_trt border_trt)

reghdfe ntl_dummy within_trt border_trt i.year i.province##c.year, cluster(commune_id year) absorb(cell_id)
est sto a5
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_dummy.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) keep(within_trt border_trt)

*********

egen ntl_binned = cut(ntl), at(0, 10, 20, 30, 40, 50, 60, 70)
* table ntl_binned, contents(min ntl max ntl)

xtivreg2 ntl_binned within_trt, fe cluster(commune_id year)
est sto b1
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_binned.doc", replace noni ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("DV=NTL rounded down to the nearest 10. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")


xtivreg2 ntl_binned within_trt border_trt, fe cluster(commune_id year)
est sto b2
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_binned.doc", append noni ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)

xi:xtivreg2 ntl_binned within_trt border_trt i.year, fe cluster(commune_id year)
est sto b3
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_binned.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) keep(within_trt border_trt)
	
reghdfe ntl_binned within_trt border_trt i.year, cluster(commune_id year) absorb(cell_id)
est sto b4
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_binned.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) keep(within_trt border_trt)

reghdfe ntl_binned within_trt border_trt i.year i.province##c.year, cluster(commune_id year) absorb(cell_id)
est sto b5
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_binned.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) keep(within_trt border_trt)

*********

xtivreg2 ntl within_trt, fe cluster(commune_id year)
est sto c1
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_continuous.doc", replace noni ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("DV=NTL. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")


xtivreg2 ntl within_trt border_trt, fe cluster(commune_id year)
est sto c2
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_continuous.doc", append noni ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)

xi:xtivreg2 ntl within_trt border_trt i.year, fe cluster(commune_id year)
est sto c3
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) keep(within_trt border_trt)
	
reghdfe ntl within_trt border_trt i.year, cluster(commune_id year) absorb(cell_id)
est sto c4
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) keep(within_trt border_trt)

reghdfe ntl within_trt border_trt i.year i.province##c.year, cluster(commune_id year) absorb(cell_id)
est sto c5
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) keep(within_trt border_trt)

*********

egen ntl_yearmax = max(ntl), by(year)
gen ntl_standardized = ntl/ntl_yearmax

xtivreg2 ntl_standardized within_trt, fe cluster(commune_id year)
est sto d1
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_standardized.doc", replace noni ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("DV=NTL_i/max(NTL_i) for year i. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")


xtivreg2 ntl_standardized within_trt border_trt, fe cluster(commune_id year)
est sto d2
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_standardized.doc", append noni ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)

xi:xtivreg2 ntl_standardized within_trt border_trt i.year, fe cluster(commune_id year)
est sto d3
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_standardized.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) keep(within_trt border_trt)
	
reghdfe ntl_standardized within_trt border_trt i.year, cluster(commune_id year) absorb(cell_id)
est sto d4
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_standardized.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) keep(within_trt border_trt)

reghdfe ntl_standardized within_trt border_trt i.year i.province##c.year, cluster(commune_id year) absorb(cell_id)
est sto d5
outreg2 using "Box Sync/cambodia_eba_gie/Results/camb_models_standardized.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) keep(within_trt border_trt)
