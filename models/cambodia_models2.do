
* this script can only be run after running the first part of the cambodia_models.do file

cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie/Results/cambodia_models_new"

* producing the correlation coefficient of the within cell treatment variable and border cell treatment variable
corr within_trt border_trt

* replacing ntl DV with border cell treatment measure and running original models

xtivreg2 border_trt within_trt, fe cluster(communenumber year)
est sto a1
outreg2 using "alternate_dep_vars/border_trt_dv.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 border_trt within_trt i.year, fe cluster(communenumber year)
est sto a2
outreg2 using "alternate_dep_vars/border_trt_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe border_trt within_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto a3
outreg2 using "alternate_dep_vars/border_trt_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe border_trt within_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a4
outreg2 using "alternate_dep_vars/border_trt_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)
reghdfe border_trt within_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a5
outreg2 using "alternate_dep_vars/border_trt_dv.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)

* replacing ntl DV with within cell treatment measure and running original models

xtivreg2 within_trt border_trt, fe cluster(communenumber year)
est sto b1
outreg2 using "alternate_dep_vars/within_trt_dv.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 within_trt border_trt i.year, fe cluster(communenumber year)
est sto b2
outreg2 using "alternate_dep_vars/within_trt_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe within_trt border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto b3
outreg2 using "alternate_dep_vars/within_trt_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe within_trt border_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b4
outreg2 using "alternate_dep_vars/within_trt_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)
reghdfe within_trt border_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b5
outreg2 using "alternate_dep_vars/within_trt_dv.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)

* running original models with border_trt omitted from independent variables

xtivreg2 ntl_dummy within_trt, fe cluster(communenumber year)
est sto c1
outreg2 using "omit_border_trt/no_border_trt_dummy_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_dummy within_trt i.year, fe cluster(communenumber year)
est sto c2
outreg2 using "omit_border_trt/no_border_trt_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe ntl_dummy within_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto c3
outreg2 using "omit_border_trt/no_border_trt_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe ntl_dummy within_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c4
outreg2 using "omit_border_trt/no_border_trt_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)
reghdfe ntl_dummy within_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c5
outreg2 using "omit_border_trt/no_border_trt_dummy_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)

xtivreg2 ntl_binned within_trt, fe cluster(communenumber year)
est sto d1
outreg2 using "omit_border_trt/no_border_trt_binned_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_binned within_trt i.year, fe cluster(communenumber year)
est sto d2
outreg2 using "omit_border_trt/no_border_trt_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe ntl_binned within_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto d3
outreg2 using "omit_border_trt/no_border_trt_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe ntl_binned within_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto d4
outreg2 using "omit_border_trt/no_border_trt_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)
reghdfe ntl_binned within_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto d5
outreg2 using "omit_border_trt/no_border_trt_binned_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)

xtivreg2 ntl within_trt, fe cluster(communenumber year)
est sto e1
outreg2 using "omit_border_trt/no_border_trt_continuous_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl within_trt i.year, fe cluster(communenumber year)
est sto e2
outreg2 using "omit_border_trt/no_border_trt_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe ntl within_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto e3
outreg2 using "omit_border_trt/no_border_trt_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe ntl within_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto e4
outreg2 using "omit_border_trt/no_border_trt_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)
reghdfe ntl within_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto e5
outreg2 using "omit_border_trt/no_border_trt_continuous_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)

xtivreg2 ntl_standardized within_trt, fe cluster(communenumber year)
est sto f1
outreg2 using "omit_border_trt/no_border_trt_standardized_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_standardized within_trt i.year, fe cluster(communenumber year)
est sto f2
outreg2 using "omit_border_trt/no_border_trt_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe ntl_standardized within_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto f3
outreg2 using "omit_border_trt/no_border_trt_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt)
reghdfe ntl_standardized within_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto f4
outreg2 using "omit_border_trt/no_border_trt_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)
reghdfe ntl_standardized within_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto f5
outreg2 using "omit_border_trt/no_border_trt_standardized_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt)

*********

xtivreg2 ntl_dummy border_trt, fe cluster(communenumber year)
est sto g1
outreg2 using "omit_within_trt/no_within_trt_dummy_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_dummy border_trt i.year, fe cluster(communenumber year)
est sto g2
outreg2 using "omit_within_trt/no_within_trt_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe ntl_dummy border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto g3
outreg2 using "omit_within_trt/no_within_trt_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe ntl_dummy border_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto g4
outreg2 using "omit_within_trt/no_within_trt_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)
reghdfe ntl_dummy border_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto g5
outreg2 using "omit_within_trt/no_within_trt_dummy_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)

xtivreg2 ntl_binned border_trt, fe cluster(communenumber year)
est sto h1
outreg2 using "omit_within_trt/no_within_trt_binned_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_binned border_trt i.year, fe cluster(communenumber year)
est sto h2
outreg2 using "omit_within_trt/no_within_trt_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe ntl_binned border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto h3
outreg2 using "omit_within_trt/no_within_trt_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe ntl_binned border_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto h4
outreg2 using "omit_within_trt/no_within_trt_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)
reghdfe ntl_binned border_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto h5
outreg2 using "omit_within_trt/no_within_trt_binned_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)

xtivreg2 ntl border_trt, fe cluster(communenumber year)
est sto j1
outreg2 using "omit_within_trt/no_within_trt_continuous_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl border_trt i.year, fe cluster(communenumber year)
est sto j2
outreg2 using "omit_within_trt/no_within_trt_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe ntl border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto j3
outreg2 using "omit_within_trt/no_within_trt_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe ntl border_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto j4
outreg2 using "omit_within_trt/no_within_trt_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)
reghdfe ntl border_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto j5
outreg2 using "omit_within_trt/no_within_trt_continuous_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)

xtivreg2 ntl_standardized border_trt, fe cluster(communenumber year)
est sto k1
outreg2 using "omit_within_trt/no_within_trt_standardized_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_standardized border_trt i.year, fe cluster(communenumber year)
est sto k2
outreg2 using "omit_within_trt/no_within_trt_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe ntl_standardized border_trt i.year, cluster(communenumber year) absorb(cell_id)
est sto k3
outreg2 using "omit_within_trt/no_within_trt_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(border_trt)
reghdfe ntl_standardized border_trt i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto k4
outreg2 using "omit_within_trt/no_within_trt_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)
reghdfe ntl_standardized border_trt c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto k5
outreg2 using "omit_within_trt/no_within_trt_standardized_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(border_trt)

*********

xtivreg2 ntl_dummy within_trt if year<=2009, fe cluster(communenumber year)
est sto m1
outreg2 using "pre_2010/pre2010_camb_models_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_dummy within_trt border_trt if year<=2009, fe cluster(communenumber year)
est sto m2
outreg2 using "pre_2010/pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_dummy within_trt border_trt i.year if year<=2009, fe cluster(communenumber year)
est sto m3
outreg2 using "pre_2010/pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe ntl_dummy within_trt border_trt i.year if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto m4
outreg2 using "pre_2010/pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(within_trt border_trt)
reghdfe ntl_dummy within_trt border_trt i.year c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto m5
outreg2 using "pre_2010/pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(within_trt border_trt)
reghdfe ntl_dummy within_trt border_trt c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto m6
outreg2 using "pre_2010/pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(within_trt border_trt)

xtivreg2 ntl_binned within_trt if year<=2009, fe cluster(communenumber year)
est sto n1
outreg2 using "pre_2010/pre2010_camb_models_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_binned within_trt border_trt if year<=2009, fe cluster(communenumber year)
est sto n2
outreg2 using "pre_2010/pre2010_camb_models_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_binned within_trt border_trt i.year if year<=2009, fe cluster(communenumber year)
est sto n3
outreg2 using "pre_2010/pre2010_camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(within_trt border_trt)
reghdfe ntl_binned within_trt border_trt i.year if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto n4
outreg2 using "pre_2010/pre2010_camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe ntl_binned within_trt border_trt i.year c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto n5
outreg2 using "pre_2010/pre2010_camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)
reghdfe ntl_binned within_trt border_trt c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto n6
outreg2 using "pre_2010/pre2010_camb_models_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)

xtivreg2 ntl within_trt if year<=2009, fe cluster(communenumber year)
est sto p1
outreg2 using "pre_2010/pre2010_camb_models_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl within_trt border_trt if year<=2009, fe cluster(communenumber year)
est sto p2
outreg2 using "pre_2010/pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl within_trt border_trt i.year if year<=2009, fe cluster(communenumber year)
est sto p3
outreg2 using "pre_2010/pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe ntl within_trt border_trt i.year if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto p4
outreg2 using "pre_2010/pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe ntl within_trt border_trt i.year c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto p5
outreg2 using "pre_2010/pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)
reghdfe ntl within_trt border_trt c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto p6
outreg2 using "pre_2010/pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)

xtivreg2 ntl_standardized within_trt if year<=2009, fe cluster(communenumber year)
est sto q1
outreg2 using "pre_2010/pre2010_camb_models_standardized.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL_i/max(NTL_i) for year i. 'within_trt' refers to the treatment variable that only considers villages within a cell. 'border_trt' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_standardized within_trt border_trt if year<=2009, fe cluster(communenumber year)
est sto q2
outreg2 using "pre_2010/pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_standardized within_trt border_trt i.year if year<=2009, fe cluster(communenumber year)
est sto q3
outreg2 using "pre_2010/pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe ntl_standardized within_trt border_trt i.year if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto q4
outreg2 using "pre_2010/pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(within_trt border_trt)
reghdfe ntl_standardized within_trt border_trt i.year c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto q5
outreg2 using "pre_2010/pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)
reghdfe ntl_standardized within_trt border_trt c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto q6
outreg2 using "pre_2010/pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(within_trt border_trt)

*********

cd "alternate_dep_vars"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}

cd ..
cd "omit_border_trt"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}

cd ..
cd "omit_within_trt"
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
