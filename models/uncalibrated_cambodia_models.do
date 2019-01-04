
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

* generating dependent variables

* ntl dummy
gen uncalib_ntl_dummy = .
replace uncalib_ntl_dummy = 0 if ntl == 0
replace uncalib_ntl_dummy = 1 if ntl > 0

* binned ntl (rounded down)
egen uncalib_ntl_binned = cut(ntl), at(0, 10, 20, 30, 40, 50, 60, 70)
* table uncalib_ntl_binned, contents(min ntl max ntl)

***

xtset cell_id year

* NTL dummy dependent variable

xtivreg2 uncalib_ntl_dummy intra_cell_treatment, fe cluster(commune_number year)
est sto a1
outreg2 using "Results/uncalibrated/uncalib_ntl_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'intra_cell_treatment' refers to the treatment variable that only considers villages within a cell. 'border_cell_treatment' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 uncalib_ntl_dummy intra_cell_treatment border_cell_treatment, fe cluster(commune_number year)
est sto a2
outreg2 using "Results/uncalibrated/uncalib_ntl_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 uncalib_ntl_dummy intra_cell_treatment border_cell_treatment i.year, fe cluster(commune_number year)
est sto a3
outreg2 using "Results/uncalibrated/uncalib_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_treatment border_cell_treatment)
reghdfe uncalib_ntl_dummy intra_cell_treatment border_cell_treatment i.year, cluster(commune_number year) absorb(cell_id)
est sto a4
outreg2 using "Results/uncalibrated/uncalib_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_treatment border_cell_treatment)
reghdfe uncalib_ntl_dummy intra_cell_treatment border_cell_treatment i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto a5
outreg2 using "Results/uncalibrated/uncalib_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(intra_cell_treatment border_cell_treatment)

* NTL binned dependent variable

xtivreg2 uncalib_ntl_binned intra_cell_treatment, fe cluster(commune_number year)
est sto b1
outreg2 using "Results/uncalibrated/uncalib_ntl_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'intra_cell_treatment' refers to the treatment variable that only considers villages within a cell. 'border_cell_treatment' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 uncalib_ntl_binned intra_cell_treatment border_cell_treatment, fe cluster(commune_number year)
est sto b2
outreg2 using "Results/uncalibrated/uncalib_ntl_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 uncalib_ntl_binned intra_cell_treatment border_cell_treatment i.year, fe cluster(commune_number year)
est sto b3
outreg2 using "Results/uncalibrated/uncalib_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_treatment border_cell_treatment)
reghdfe uncalib_ntl_binned intra_cell_treatment border_cell_treatment i.year, cluster(commune_number year) absorb(cell_id)
est sto b4
outreg2 using "Results/uncalibrated/uncalib_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_treatment border_cell_treatment)
reghdfe uncalib_ntl_binned intra_cell_treatment border_cell_treatment i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto b5
outreg2 using "Results/uncalibrated/uncalib_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_treatment border_cell_treatment)

* NTL continuous dependent variable

xtivreg2 ntl intra_cell_treatment, fe cluster(commune_number year)
est sto c1
outreg2 using "Results/uncalibrated/uncalib_ntl_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'intra_cell_treatment' refers to the treatment variable that only considers villages within a cell. 'border_cell_treatment' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl intra_cell_treatment border_cell_treatment, fe cluster(commune_number year)
est sto c2
outreg2 using "Results/uncalibrated/uncalib_ntl_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl intra_cell_treatment border_cell_treatment i.year, fe cluster(commune_number year)
est sto c3
outreg2 using "Results/uncalibrated/uncalib_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_treatment border_cell_treatment)
reghdfe ntl intra_cell_treatment border_cell_treatment i.year, cluster(commune_number year) absorb(cell_id)
est sto c4
outreg2 using "Results/uncalibrated/uncalib_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_treatment border_cell_treatment)
reghdfe ntl intra_cell_treatment border_cell_treatment i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto c5
outreg2 using "Results/uncalibrated/uncalib_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_treatment border_cell_treatment)

***

cd "uncalibrated"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}

