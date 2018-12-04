set matsize 11000
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

insheet using "ProcessedData/heterogeneous_effects/panel_urban_transport_only.csv", clear

cd "Results"

* dropping observations if the commune name variable contains NA values. Keeping these observations
* creates problematic clusters when clustering errors at commune level

replace communename = "" if strpos(communename, "n.a") > 0

replace boxenddatetype = "." if boxenddatetype == "NA"
destring boxenddatetype, replace
replace pointenddatetype = "." if pointenddatetype == "NA"
destring pointenddatetype, replace

* replacing year index with actual year
replace year = year + 1991

replace provincename = "" if provincename == "NA"
encode provincename, gen(provincenumber)

* generating a numeric variable representing communes for clustering SEs
drop cell_id
rename panel_id cell_id

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

xtset cell_id year

xtivreg2 ntl_dummy pointcount, fe cluster(communenumber year)
est sto a1
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_dummy_count.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_dummy pointcount boxcount, fe cluster(communenumber year)
est sto a2
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_dummy_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_dummy pointcount boxcount i.year, fe cluster(communenumber year)
est sto a3
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_dummy_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto a4
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_dummy_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a5
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_dummy_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a6
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_dummy_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)

* NTL binned dependent variable

xtivreg2 ntl_binned pointcount, fe cluster(communenumber year)
est sto b1
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_binned_count.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_binned pointcount boxcount, fe cluster(communenumber year)
est sto b2
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_binned_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_binned pointcount boxcount i.year, fe cluster(communenumber year)
est sto b3
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_binned_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto b4
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_binned_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b5
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_binned_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b6
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_binned_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

* NTL continuous dependent variable

xtivreg2 ntl pointcount, fe cluster(communenumber year)
est sto c1
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_continuous_count.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl pointcount boxcount, fe cluster(communenumber year)
est sto c2
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_continuous_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl pointcount boxcount i.year, fe cluster(communenumber year)
est sto c3
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_continuous_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto c4
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_continuous_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c5
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_continuous_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c6
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_continuous_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

* NTL standardized dependent variable

xtivreg2 ntl_standardized pointcount, fe cluster(communenumber year)
est sto d1
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_standardized_count.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL_i/max(NTL_i) for year i. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_standardized pointcount boxcount, fe cluster(communenumber year)
est sto d2
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_standardized_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_standardized pointcount boxcount i.year, fe cluster(communenumber year)
est sto d3
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_standardized_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto d4
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_standardized_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto d5
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_standardized_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto d6
outreg2 using "heterogeneous_effects/urban_transport/urban_transport_standardized_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

*********

cd "count"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}

