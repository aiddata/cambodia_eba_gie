
set matsize 11000
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

insheet using "ProcessedData/panel.csv", clear

* replacing year index with actual year
replace year = year + 1991

encode provincename, gen(provincenumber)

* generating a numeric variable representing communes for clustering SEs
drop cell_id
rename panel_id cell_id

* replace communenumber = "." if communenumber == "NA"
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

* generating dependent variables

* ntl dummy
gen ntl_dummy = .
replace ntl_dummy = 0 if ntl == 0
replace ntl_dummy = 1 if ntl > 0

* binned ntl (rounded down)
egen ntl_binned = cut(ntl), at(0, 10, 20, 30, 40, 50, 60, 70)
* table ntl_binned, contents(min ntl max ntl)

* standardized ntl
egen ntl_yearmax = max(ntl), by(year)
gen ntl_standardized = ntl/ntl_yearmax

*******************

* NTL dummy dependent variable

xtset cell_id year

xtivreg2 ntl_dummy within_trt, fe cluster(communenumber year)
est sto a1
outreg2 using "Results/camb_models_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")

xtivreg2 ntl_dummy within_trt border_trt, fe cluster(communenumber year)
est sto a2
outreg2 using "Results/camb_models_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)

xi:xtivreg2 ntl_dummy within_trt border_trt i.year, fe cluster(communenumber year)
est sto a3
outreg2 using "Results/camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
	
reghdfe ntl_dummy within_trt border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto a4
outreg2 using "Results/camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(within_trt border_trt)

reghdfe ntl_dummy within_trt border_trt i.year i.provincenumber##c.year, cluster(communenumber year) absorb(cell_id)
est sto a5
outreg2 using "Results/camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(within_trt border_trt)

*********

xtivreg2 ntl_binned within_trt, fe cluster(communenumber year)
est sto b1
outreg2 using "Results/camb_models_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")

xtivreg2 ntl_binned within_trt border_trt, fe cluster(communenumber year)
est sto b2
outreg2 using "Results/camb_models_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)

xi:xtivreg2 ntl_binned within_trt border_trt i.year, fe cluster(communenumber year)
est sto b3
outreg2 using "Results/camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(within_trt border_trt)
	
reghdfe ntl_binned within_trt border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto b4
outreg2 using "Results/camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)

reghdfe ntl_binned within_trt border_trt i.year i.provincenumber##c.year, cluster(communenumber year) absorb(cell_id)
est sto b5
outreg2 using "Results/camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)

*********

xtivreg2 ntl within_trt, fe cluster(communenumber year)
est sto c1
outreg2 using "Results/camb_models_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")

xtivreg2 ntl within_trt border_trt, fe cluster(communenumber year)
est sto c2
outreg2 using "Results/camb_models_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)

xi:xtivreg2 ntl within_trt border_trt i.year, fe cluster(communenumber year)
est sto c3
outreg2 using "Results/camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
	
reghdfe ntl within_trt border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto c4
outreg2 using "Results/camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)

reghdfe ntl within_trt border_trt i.year i.provincenumber##c.year, cluster(communenumber year) absorb(cell_id)
est sto c5
outreg2 using "Results/camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)

*********

xtivreg2 ntl_standardized within_trt, fe cluster(communenumber year)
est sto d1
outreg2 using "Results/camb_models_standardized.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL_i/max(NTL_i) for year i. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")

xtivreg2 ntl_standardized within_trt border_trt, fe cluster(communenumber year)
est sto d2
outreg2 using "Results/camb_models_standardized.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)

xi:xtivreg2 ntl_standardized within_trt border_trt i.year, fe cluster(communenumber year)
est sto d3
outreg2 using "Results/camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
	
reghdfe ntl_standardized within_trt border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto d4
outreg2 using "Results/camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)

reghdfe ntl_standardized within_trt border_trt i.year i.provincenumber##c.year, cluster(communenumber year) absorb(cell_id)
est sto d5
outreg2 using "Results/camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)

*********

cd "Results"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}
