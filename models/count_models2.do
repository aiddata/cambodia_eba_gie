* this script can only be run after running the first part of the cambodia_models.do file

cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie/Results/count_treatment/additional_models"

* producing the correlation coefficient of the within cell treatment variable and border cell treatment variable
corr intra_cell_count border_cell_count

***

egen any_ntl = total(ntl > 0), by(cell_id)

xtivreg2 ntl_dummy intra_cell_count if any_ntl>0, fe cluster(commune_number year)
est sto a1
outreg2 using "no_dark_subset/ntl_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that keeps a cumulative yearly count of completed projects within a cell. 'border_cell_count' refers to the treatment variable that keeps a cumulative yearly count of completed projects in the area surrounding a cell")
xtivreg2 ntl_dummy intra_cell_count border_cell_count if any_ntl>0, fe cluster(commune_number year)
est sto a2
outreg2 using "no_dark_subset/ntl_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi: xtivreg2 ntl_dummy intra_cell_count border_cell_count i.year if any_ntl>0, fe cluster(commune_number year)
est sto a3
outreg2 using "no_dark_subset/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year if any_ntl>0, cluster(commune_number) absorb(cell_id)
est sto a4
outreg2 using "no_dark_subset/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year c.year#i.province_number if any_ntl>0, cluster(commune_number) absorb(cell_id)
est sto a5
outreg2 using "no_dark_subset/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

xtivreg2 ntl_binned intra_cell_count if any_ntl>0, fe cluster(commune_number year)
est sto b1
outreg2 using "no_dark_subset/ntl_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that keeps a cumulative yearly count of completed projects within a cell. 'border_cell_count' refers to the treatment variable that keeps a cumulative yearly count of completed projects in the area surrounding a cell")
xtivreg2 ntl_binned intra_cell_count border_cell_count if any_ntl>0, fe cluster(commune_number year)
est sto b2
outreg2 using "no_dark_subset/ntl_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi: xtivreg2 ntl_binned intra_cell_count border_cell_count i.year if any_ntl>0, fe cluster(commune_number year)
est sto b3
outreg2 using "no_dark_subset/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year if any_ntl>0, cluster(commune_number) absorb(cell_id)
est sto b4
outreg2 using "no_dark_subset/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year c.year#i.province_number if any_ntl>0, cluster(commune_number) absorb(cell_id)
est sto b5
outreg2 using "no_dark_subset/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

xtivreg2 ntl intra_cell_count if any_ntl>0, fe cluster(commune_number year)
est sto c1
outreg2 using "no_dark_subset/ntl_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that keeps a cumulative yearly count of completed projects within a cell. 'border_cell_count' refers to the treatment variable that keeps a cumulative yearly count of completed projects in the area surrounding a cell")
xtivreg2 ntl intra_cell_count border_cell_count if any_ntl>0, fe cluster(commune_number year)
est sto c2
outreg2 using "no_dark_subset/ntl_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi: xtivreg2 ntl intra_cell_count border_cell_count i.year if any_ntl>0, fe cluster(commune_number year)
est sto c3
outreg2 using "no_dark_subset/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year if any_ntl>0, cluster(commune_number) absorb(cell_id)
est sto c4
outreg2 using "no_dark_subset/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year c.year#i.province_number if any_ntl>0, cluster(commune_number) absorb(cell_id)
est sto c5
outreg2 using "no_dark_subset/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

***

* replacing ntl DV with border cell treatment measure and running original models

xtivreg2 border_cell_count intra_cell_count, fe cluster(commune_number year)
est sto d1
outreg2 using "alternate_dep_vars/border-cell_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 border_cell_count intra_cell_count i.year, fe cluster(commune_number year)
est sto d2
outreg2 using "alternate_dep_vars/border-cell_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count)
reghdfe border_cell_count intra_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto d3
outreg2 using "alternate_dep_vars/border-cell_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count)
reghdfe border_cell_count intra_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto d4
outreg2 using "alternate_dep_vars/border-cell_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count)

* replacing ntl DV with within cell treatment measure and running original models

xtivreg2 intra_cell_count border_cell_count, fe cluster(commune_number year)
est sto e1
outreg2 using "alternate_dep_vars/intra-cell_outcome.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 intra_cell_count border_cell_count i.year, fe cluster(commune_number year)
est sto e2
outreg2 using "alternate_dep_vars/intra-cell_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_cell_count)
reghdfe intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto e3
outreg2 using "alternate_dep_vars/intra-cell_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_cell_count)
reghdfe intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto e4
outreg2 using "alternate_dep_vars/intra-cell_outcome.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_cell_count)

* running original models with border_cell_count omitted from independent variables

xtivreg2 ntl_dummy intra_cell_count, fe cluster(commune_number year)
est sto f1
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_dummy intra_cell_count i.year, fe cluster(commune_number year)
est sto f2
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count)
reghdfe ntl_dummy intra_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto f3
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count)
reghdfe ntl_dummy intra_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto f4
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count)

xtivreg2 ntl_binned intra_cell_count, fe cluster(commune_number year)
est sto g1
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_binned intra_cell_count i.year, fe cluster(commune_number year)
est sto g2
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count)
reghdfe ntl_binned intra_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto g3
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count)
reghdfe ntl_binned intra_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto g4
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count)

xtivreg2 ntl intra_cell_count, fe cluster(commune_number year)
est sto h1
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl intra_cell_count i.year, fe cluster(commune_number year)
est sto h2
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count)
reghdfe ntl intra_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto h3
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count)
reghdfe ntl intra_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto h4
outreg2 using "omit_border_cell_trt/no-border-treatment_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count)

***

xtivreg2 ntl_dummy border_cell_count, fe cluster(commune_number year)
est sto j1
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_dummy border_cell_count i.year, fe cluster(commune_number year)
est sto j2
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_cell_count)
reghdfe ntl_dummy border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto j3
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_cell_count)
reghdfe ntl_dummy border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto j4
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_cell_count)

xtivreg2 ntl_binned border_cell_count, fe cluster(commune_number year)
est sto k1
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_binned border_cell_count i.year, fe cluster(commune_number year)
est sto k2
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_cell_count)
reghdfe ntl_binned border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto k3
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_cell_count)
reghdfe ntl_binned border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto k4
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_cell_count)

xtivreg2 ntl border_cell_count, fe cluster(commune_number year)
est sto m1
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl border_cell_count i.year, fe cluster(commune_number year)
est sto m2
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_cell_count)
reghdfe ntl border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto m3
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_cell_count)
reghdfe ntl border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto m4
outreg2 using "omit_intra_cell_trt/no-intra-treatment_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_cell_count)

***

xtivreg2 ntl_dummy intra_cell_count if year<=2009, fe cluster(commune_number year)
est sto n1
outreg2 using "pre_2010/pre2010_ntl_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_dummy intra_cell_count border_cell_count if year<=2009, fe cluster(commune_number year)
est sto n2
outreg2 using "pre_2010/pre2010_ntl_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_dummy intra_cell_count border_cell_count i.year if year<=2009, fe cluster(commune_number year)
est sto n3
outreg2 using "pre_2010/pre2010_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year if year<=2009, cluster(commune_number year) absorb(cell_id)
est sto n4
outreg2 using "pre_2010/pre2010_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year c.year#i.province_number if year<=2009, cluster(commune_number year) absorb(cell_id)
est sto n5
outreg2 using "pre_2010/pre2010_ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(intra_cell_count border_cell_count)

xtivreg2 ntl_binned intra_cell_count if year<=2009, fe cluster(commune_number year)
est sto p1
outreg2 using "pre_2010/pre2010_ntl_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_binned intra_cell_count border_cell_count if year<=2009, fe cluster(commune_number year)
est sto p2
outreg2 using "pre_2010/pre2010_ntl_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_binned intra_cell_count border_cell_count i.year if year<=2009, fe cluster(commune_number year)
est sto p3
outreg2 using "pre_2010/pre2010_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year if year<=2009, cluster(commune_number year) absorb(cell_id)
est sto p4
outreg2 using "pre_2010/pre2010_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year c.year#i.province_number if year<=2009, cluster(commune_number year) absorb(cell_id)
est sto p5
outreg2 using "pre_2010/pre2010_ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

xtivreg2 ntl intra_cell_count if year<=2009, fe cluster(commune_number year)
est sto q1
outreg2 using "pre_2010/pre2010_ntl_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl intra_cell_count border_cell_count if year<=2009, fe cluster(commune_number year)
est sto q2
outreg2 using "pre_2010/pre2010_ntl_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl intra_cell_count border_cell_count i.year if year<=2009, fe cluster(commune_number year)
est sto q3
outreg2 using "pre_2010/pre2010_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year if year<=2009, cluster(commune_number year) absorb(cell_id)
est sto q4
outreg2 using "pre_2010/pre2010_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year c.year#i.province_number if year<=2009, cluster(commune_number year) absorb(cell_id)
est sto q5
outreg2 using "pre_2010/pre2010_ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

***

cd "no_dark_subset"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}

cd ..
cd "alternate_dep_vars"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}

cd ..
cd "omit_border_cell_trt"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}

cd ..
cd "omit_intra_cell_trt"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}

cd ..
cd "pre_2010"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}
