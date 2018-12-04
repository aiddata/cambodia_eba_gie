* this script can only be run after running the first part of the cambodia_models.do file

cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie/Results/heterogeneous_effects/rural_transport/additional_models"

* producing the correlation coefficient of the within cell treatment variable and border cell treatment variable
corr pointcount boxcount

* replacing ntl DV with border cell treatment measure and running original models

xtivreg2 boxcount pointcount, fe cluster(communenumber year)
est sto a1
outreg2 using "alternate_dep_vars/rural_transport_boxcount_dv.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 boxcount pointcount i.year, fe cluster(communenumber year)
est sto a2
outreg2 using "alternate_dep_vars/rural_transport_boxcount_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe boxcount pointcount i.year, cluster(communenumber year) absorb(cell_id)
est sto a3
outreg2 using "alternate_dep_vars/rural_transport_boxcount_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe boxcount pointcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a4
outreg2 using "alternate_dep_vars/rural_transport_boxcount_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)
reghdfe boxcount pointcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto a5
outreg2 using "alternate_dep_vars/rural_transport_boxcount_dv.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)

* replacing ntl DV with within cell treatment measure and running original models

xtivreg2 pointcount boxcount, fe cluster(communenumber year)
est sto b1
outreg2 using "alternate_dep_vars/rural_transport_pointcount_dv.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 pointcount boxcount i.year, fe cluster(communenumber year)
est sto b2
outreg2 using "alternate_dep_vars/rural_transport_pointcount_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe pointcount boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto b3
outreg2 using "alternate_dep_vars/rural_transport_pointcount_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe pointcount boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b4
outreg2 using "alternate_dep_vars/rural_transport_pointcount_dv.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)
reghdfe pointcount boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto b5
outreg2 using "alternate_dep_vars/rural_transport_pointcount_dv.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)

* running original models with boxcount omitted from independent variables

xtivreg2 ntl_dummy pointcount, fe cluster(communenumber year)
est sto c1
outreg2 using "omit_boxcount/rural_transport_no_boxcount_dummy_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_dummy pointcount i.year, fe cluster(communenumber year)
est sto c2
outreg2 using "omit_boxcount/rural_transport_no_boxcount_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe ntl_dummy pointcount i.year, cluster(communenumber year) absorb(cell_id)
est sto c3
outreg2 using "omit_boxcount/rural_transport_no_boxcount_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe ntl_dummy pointcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c4
outreg2 using "omit_boxcount/rural_transport_no_boxcount_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)
reghdfe ntl_dummy pointcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto c5
outreg2 using "omit_boxcount/rural_transport_no_boxcount_dummy_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)

xtivreg2 ntl_binned pointcount, fe cluster(communenumber year)
est sto d1
outreg2 using "omit_boxcount/rural_transport_no_boxcount_binned_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_binned pointcount i.year, fe cluster(communenumber year)
est sto d2
outreg2 using "omit_boxcount/rural_transport_no_boxcount_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe ntl_binned pointcount i.year, cluster(communenumber year) absorb(cell_id)
est sto d3
outreg2 using "omit_boxcount/rural_transport_no_boxcount_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe ntl_binned pointcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto d4
outreg2 using "omit_boxcount/rural_transport_no_boxcount_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)
reghdfe ntl_binned pointcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto d5
outreg2 using "omit_boxcount/rural_transport_no_boxcount_binned_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)

xtivreg2 ntl pointcount, fe cluster(communenumber year)
est sto e1
outreg2 using "omit_boxcount/rural_transport_no_boxcount_continuous_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl pointcount i.year, fe cluster(communenumber year)
est sto e2
outreg2 using "omit_boxcount/rural_transport_no_boxcount_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe ntl pointcount i.year, cluster(communenumber year) absorb(cell_id)
est sto e3
outreg2 using "omit_boxcount/rural_transport_no_boxcount_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe ntl pointcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto e4
outreg2 using "omit_boxcount/rural_transport_no_boxcount_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)
reghdfe ntl pointcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto e5
outreg2 using "omit_boxcount/rural_transport_no_boxcount_continuous_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)

xtivreg2 ntl_standardized pointcount, fe cluster(communenumber year)
est sto f1
outreg2 using "omit_boxcount/rural_transport_no_boxcount_standardized_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_standardized pointcount i.year, fe cluster(communenumber year)
est sto f2
outreg2 using "omit_boxcount/rural_transport_no_boxcount_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe ntl_standardized pointcount i.year, cluster(communenumber year) absorb(cell_id)
est sto f3
outreg2 using "omit_boxcount/rural_transport_no_boxcount_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount)
reghdfe ntl_standardized pointcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto f4
outreg2 using "omit_boxcount/rural_transport_no_boxcount_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)
reghdfe ntl_standardized pointcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto f5
outreg2 using "omit_boxcount/rural_transport_no_boxcount_standardized_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount)

*********

xtivreg2 ntl_dummy boxcount, fe cluster(communenumber year)
est sto g1
outreg2 using "omit_pointcount/rural_transport_no_pointcount_dummy_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_dummy boxcount i.year, fe cluster(communenumber year)
est sto g2
outreg2 using "omit_pointcount/rural_transport_no_pointcount_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe ntl_dummy boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto g3
outreg2 using "omit_pointcount/rural_transport_no_pointcount_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe ntl_dummy boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto g4
outreg2 using "omit_pointcount/rural_transport_no_pointcount_dummy_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)
reghdfe ntl_dummy boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto g5
outreg2 using "omit_pointcount/rural_transport_no_pointcount_dummy_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)

xtivreg2 ntl_binned boxcount, fe cluster(communenumber year)
est sto h1
outreg2 using "omit_pointcount/rural_transport_no_pointcount_binned_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_binned boxcount i.year, fe cluster(communenumber year)
est sto h2
outreg2 using "omit_pointcount/rural_transport_no_pointcount_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe ntl_binned boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto h3
outreg2 using "omit_pointcount/rural_transport_no_pointcount_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe ntl_binned boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto h4
outreg2 using "omit_pointcount/rural_transport_no_pointcount_binned_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)
reghdfe ntl_binned boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto h5
outreg2 using "omit_pointcount/rural_transport_no_pointcount_binned_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)

xtivreg2 ntl boxcount, fe cluster(communenumber year)
est sto j1
outreg2 using "omit_pointcount/rural_transport_no_pointcount_continuous_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl boxcount i.year, fe cluster(communenumber year)
est sto j2
outreg2 using "omit_pointcount/rural_transport_no_pointcount_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe ntl boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto j3
outreg2 using "omit_pointcount/rural_transport_no_pointcount_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe ntl boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto j4
outreg2 using "omit_pointcount/rural_transport_no_pointcount_continuous_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)
reghdfe ntl boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto j5
outreg2 using "omit_pointcount/rural_transport_no_pointcount_continuous_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)

xtivreg2 ntl_standardized boxcount, fe cluster(communenumber year)
est sto k1
outreg2 using "omit_pointcount/rural_transport_no_pointcount_standardized_models.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xi:xtivreg2 ntl_standardized boxcount i.year, fe cluster(communenumber year)
est sto k2
outreg2 using "omit_pointcount/rural_transport_no_pointcount_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe ntl_standardized boxcount i.year, cluster(communenumber year) absorb(cell_id)
est sto k3
outreg2 using "omit_pointcount/rural_transport_no_pointcount_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(boxcount)
reghdfe ntl_standardized boxcount i.year c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto k4
outreg2 using "omit_pointcount/rural_transport_no_pointcount_standardized_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)
reghdfe ntl_standardized boxcount c.year#i.provincenumber, cluster(communenumber year) absorb(cell_id)
est sto k5
outreg2 using "omit_pointcount/rural_transport_no_pointcount_standardized_models.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(boxcount)

*********

xtivreg2 ntl_dummy pointcount if year<=2009, fe cluster(communenumber year)
est sto m1
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_dummy.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_dummy pointcount boxcount if year<=2009, fe cluster(communenumber year)
est sto m2
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_dummy pointcount boxcount i.year if year<=2009, fe cluster(communenumber year)
est sto m3
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount i.year if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto m4
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount i.year c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto m5
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)
reghdfe ntl_dummy pointcount boxcount c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto m6
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_dummy.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(pointcount boxcount)

xtivreg2 ntl_binned pointcount if year<=2009, fe cluster(communenumber year)
est sto n1
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_binned.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_binned pointcount boxcount if year<=2009, fe cluster(communenumber year)
est sto n2
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_binned pointcount boxcount i.year if year<=2009, fe cluster(communenumber year)
est sto n3
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount i.year if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto n4
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount i.year c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto n5
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl_binned pointcount boxcount c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto n6
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_binned.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

xtivreg2 ntl pointcount if year<=2009, fe cluster(communenumber year)
est sto p1
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_continuous.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl pointcount boxcount if year<=2009, fe cluster(communenumber year)
est sto p2
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl pointcount boxcount i.year if year<=2009, fe cluster(communenumber year)
est sto p3
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount i.year if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto p4
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount i.year c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto p5
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl pointcount boxcount c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto p6
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_continuous.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

xtivreg2 ntl_standardized pointcount if year<=2009, fe cluster(communenumber year)
est sto q1
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_standardized.doc", replace noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL_i/max(NTL_i) for year i. 'pointcount' refers to the treatment variable that only considers villages within a cell. 'boxcount' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
xtivreg2 ntl_standardized pointcount boxcount if year<=2009, fe cluster(communenumber year)
est sto q2
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
xi:xtivreg2 ntl_standardized pointcount boxcount i.year if year<=2009, fe cluster(communenumber year)
est sto q3
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount i.year if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto q4
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount i.year c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto q5
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)
reghdfe ntl_standardized pointcount boxcount c.year#i.provincenumber if year<=2009, cluster(communenumber year) absorb(cell_id)
est sto q6
outreg2 using "pre_2010/rural_transport_pre2010_camb_models_standardized.doc", append noni addtext("Year FEs", N, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(pointcount boxcount)

*********

cd "alternate_dep_vars"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}

cd ..
cd "omit_boxcount"
local txtfiles: dir . files "*.txt"
foreach txt in `txtfiles' {
	erase `"`txt'"'
}

cd ..
cd "omit_pointcount"
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
