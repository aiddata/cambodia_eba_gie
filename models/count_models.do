
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie/Results"

* bysort cell_id (year): gen ntl_pre_baseline = ntl[11]
* xtile ntl_baseline = ntl_pre_baseline, n(4)

xtivreg2 ntl_dummy intra_cell_count, fe cluster(commune_number year)
est sto a1
outreg2 using "count_treatment/ntl_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_dummy intra_cell_count border_cell_count, fe cluster(commune_number year)
est sto a2
outreg2 using "count_treatment/ntl_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_dummy intra_cell_count border_cell_count i.year, fe cluster(commune_number year)
est sto a3
outreg2 using "count_treatment/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto a4
outreg2 using "count_treatment/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto a5
outreg2 using "count_treatment/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(intra_cell_count border_cell_count)

* NTL binned dependent variable

xtivreg2 ntl_binned intra_cell_count, fe cluster(commune_number year)
est sto b1
outreg2 using "count_treatment/ntl_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_binned intra_cell_count border_cell_count, fe cluster(commune_number year)
est sto b2
outreg2 using "count_treatment/ntl_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_binned intra_cell_count border_cell_count i.year, fe cluster(commune_number year)
est sto b3
outreg2 using "count_treatment/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto b4
outreg2 using "count_treatment/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto b5
outreg2 using "count_treatment/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

* NTL continuous dependent variable

xtivreg2 ntl intra_cell_count, fe cluster(commune_number year)
est sto c1
outreg2 using "count_treatment/ntl_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl intra_cell_count border_cell_count, fe cluster(commune_number year)
est sto c2
outreg2 using "count_treatment/ntl_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl intra_cell_count border_cell_count i.year, fe cluster(commune_number year)
est sto c3
outreg2 using "count_treatment/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto c4
outreg2 using "count_treatment/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto c5
outreg2 using "count_treatment/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

***

* NTL continuous dependent variable

* xtivreg2 ntl intra_cell_count intra_cell_count#ntl_baseline, fe cluster(commune_number year)
* est sto e1
* outreg2 using "count_treatment/ntl_continuous_baseline.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
* 	addnote("Notes: DV=NTL. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
* xtivreg2 ntl intra_cell_count border_cell_count intra_cell_count#ntl_baseline border_cell_count#ntl_baseline, fe cluster(commune_number year)
* est sto e2
* outreg2 using "count_treatment/ntl_continuous_baseline.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
* xi:xtivreg2 ntl intra_cell_count border_cell_count intra_cell_count#ntl_baseline border_cell_count#ntl_baseline i.year, fe cluster(commune_number year)
* est sto e3
* outreg2 using "count_treatment/ntl_continuous_baseline.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
* 	keep(intra_cell_count border_cell_count intra_cell_count#ntl_baseline border_cell_count#ntl_baseline)
* reghdfe ntl intra_cell_count border_cell_count C.intra_cell_count#C.ntl_baseline C.border_cell_count#C.ntl_baseline i.year if ntl_baseline>0, cluster(commune_number year) absorb(cell_id)
* est sto e4
* outreg2 using "count_treatment/ntl_continuous_baseline.doc", replace noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N, "Baseline NTL", Y) ///
* 	keep(intra_cell_count border_cell_count)
* reghdfe ntl intra_cell_count border_cell_count c.intra_cell_count#ntl_baseline C.border_cell_count#ntl_baseline i.year c.year#i.province_number if ntl_baseline>0, cluster(commune_number year) absorb(cell_id)
* est sto e5
* outreg2 using "count_treatment/ntl_continuous_baseline.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y, "Baseline NTL", Y) ///
* 	keep(intra_cell_count border_cell_count)

***

cd "count_treatment"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}
