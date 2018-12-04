
cd "Results"

xtivreg2 ntl_dummy pointcount, fe cluster(communenumber year)
est sto a1
outreg2 using "count/camb_models_dummy_count.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_dummy pointcount boxcount, fe cluster(communenumber year)
est sto a2
outreg2 using "count/camb_models_dummy_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_dummy pointcount boxcount i.year, fe cluster(communenumber year)
est sto a3
outreg2 using "count/camb_models_dummy_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto a4
outreg2 using "count/camb_models_dummy_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a5
outreg2 using "count/camb_models_dummy_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a6
outreg2 using "count/camb_models_dummy_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)

* NTL binned dependent variable

xtivreg2 ntl_binned pointcount, fe cluster(communenumber year)
est sto b1
outreg2 using "count/camb_models_binned_count.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_binned pointcount boxcount, fe cluster(communenumber year)
est sto b2
outreg2 using "count/camb_models_binned_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_binned pointcount boxcount i.year, fe cluster(communenumber year)
est sto b3
outreg2 using "count/camb_models_binned_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto b4
outreg2 using "count/camb_models_binned_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b5
outreg2 using "count/camb_models_binned_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b6
outreg2 using "count/camb_models_binned_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

* NTL continuous dependent variable

xtivreg2 ntl pointcount, fe cluster(communenumber year)
est sto c1
outreg2 using "count/camb_models_continuous_count.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl pointcount boxcount, fe cluster(communenumber year)
est sto c2
outreg2 using "count/camb_models_continuous_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl pointcount boxcount i.year, fe cluster(communenumber year)
est sto c3
outreg2 using "count/camb_models_continuous_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto c4
outreg2 using "count/camb_models_continuous_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c5
outreg2 using "count/camb_models_continuous_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c6
outreg2 using "count/camb_models_continuous_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

* NTL standardized dependent variable

xtivreg2 ntl_standardized pointcount, fe cluster(communenumber year)
est sto d1
outreg2 using "count/camb_models_standardized_count.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL_i/max(NTL_i) for year i. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_standardized pointcount boxcount, fe cluster(communenumber year)
est sto d2
outreg2 using "count/camb_models_standardized_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_standardized pointcount boxcount i.year, fe cluster(communenumber year)
est sto d3
outreg2 using "count/camb_models_standardized_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto d4
outreg2 using "count/camb_models_standardized_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto d5
outreg2 using "count/camb_models_standardized_count.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto d6
outreg2 using "count/camb_models_standardized_count.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

*********

cd "count"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}


