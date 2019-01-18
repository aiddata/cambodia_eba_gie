
set matsize 11000
cd "/Users/rbtrichler/Box Sync/cambodia_eba_gie"
cd "/Users/christianbaehr/Box Sync/cambodia_eba_gie"

insheet using "ProcessedData/panel.csv", clear

* dropping observations if the commune name variable contains NA values. Keeping these observations
* creates problematic clusters when clustering errors at commune level

replace border_cell_enddate_type = "." if border_cell_enddate_type == "NA"
destring border_cell_enddate_type, replace
replace intra_cell_enddate_type = "." if intra_cell_enddate_type == "NA"
destring intra_cell_enddate_type, replace

* replacing year index with actual year
replace year = year + 1991

replace province_name = "" if province_name == "NA"
encode province_name, gen(province_number)

* replace unique_commune_name = "" if strpos(unique_commune_name, "n.a") > 0
encode unique_commune_name, gen(commune_number)
gen temp = (province_number==16 & strpos(unique_commune_name, "n.a") > 0)
drop if temp==1

* formatting missing data values for the treatment date variable
replace intra_cell_earliest_enddate = "." if intra_cell_earliest_enddate == "NA"
destring intra_cell_earliest_enddate, replace
replace border_cell_earliest_enddate = "." if border_cell_earliest_enddate == "NA"
destring border_cell_earliest_enddate, replace

* generating the "village within cell" treatment variable 
gen intra_cell_treatment = 0
replace intra_cell_treatment = 1 if year >= intra_cell_earliest_enddate

* generating the "village surrounding cell" treatment variable
gen border_cell_treatment = 0
replace border_cell_treatment = 1 if year >= border_cell_earliest_enddate

* gen earliest project end_date
gen earliest_end= border_cell_earliest_enddate 
replace earliest_end = intra_cell_earliest_enddate if intra_cell_earliest_enddate<border_cell_earliest_enddate

*gen ntl dummy that reflects if lit before 1992
gen ntl_dummy_pre92 = 0
*only equals 1 if lit before 1992
replace ntl_dummy_pre92=1 if ntl>0 & year==1992 
egen ntl_lit_pre92 = max(ntl_dummy_pre92), by(cell_id)

* gen dummy that reflects if become lit between 1992-2002
gen ntl_dummy_pre03=0
*only equals 1 if lit 2002 or earlier
replace ntl_dummy_pre03=1 if ntl>0 & year==2002
egen ntl_lit_pre03 = max(ntl_dummy_pre03), by(cell_id)


* generating dependent variables

* ntl dummy
gen ntl_dummy = .
replace ntl_dummy = 0 if ntl == 0
replace ntl_dummy = 1 if ntl > 0

* binned ntl (rounded down)
egen ntl_binned = cut(ntl), at(0, 10, 20, 30, 40, 50, 60, 70)
* table ntl_binned, contents(min ntl max ntl)

*** MODELS ****
gen project_count = intra_cell_count + border_cell_count
egen max_projects = max(project_count), by(cell_id)

* outsheet using "Report/ntl_sum_stats.csv", comma

***

* bysort cell_id (year): gen ntl_pre_baseline = ntl[11]
* xtile ntl_baseline = ntl_pre_baseline, n(4)

cgmreg ntl_dummy intra_cell_count, cluster(commune_number year)
est sto a1
outreg2 using "Results/count_treatment/ntl_dummy.doc", replace noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV={0 if NTL=0, 1 otherwise}. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
cgmreg ntl_dummy intra_cell_count border_cell_count, cluster(commune_number year)
est sto a2
outreg2 using "Results/count_treatment/ntl_dummy.doc", append noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl_dummy intra_cell_count border_cell_count, cluster(commune_number year) absorb(year)
est sto a3
outreg2 using "Results/count_treatment/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto a4
outreg2 using "Results/count_treatment/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_count border_cell_count)
reghdfe ntl_dummy intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto a5
outreg2 using "Results/count_treatment/ntl_dummy.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) /// 
	keep(intra_cell_count border_cell_count)

* NTL binned dependent variable

cgmreg ntl_binned intra_cell_count, cluster(commune_number year)
est sto b1
outreg2 using "Results/count_treatment/ntl_binned.doc", replace noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL rounded down to the nearest 10. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
cgmreg ntl_binned intra_cell_count border_cell_count, cluster(commune_number year)
est sto b2
outreg2 using "Results/count_treatment/ntl_binned.doc", append noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl_binned intra_cell_count border_cell_count, cluster(commune_number year) absorb(year)
est sto b3
outreg2 using "Results/count_treatment/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) /// 
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto b4
outreg2 using "Results/count_treatment/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl_binned intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto b5
outreg2 using "Results/count_treatment/ntl_binned.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

* NTL continuous dependent variable

cgmreg ntl intra_cell_count, cluster(commune_number year)
est sto c1
outreg2 using "Results/count_treatment/ntl_continuous.doc", replace noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
cgmreg ntl intra_cell_count border_cell_count, cluster(commune_number year)
est sto c2
outreg2 using "Results/count_treatment/ntl_continuous.doc", append noni nocons addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl intra_cell_count border_cell_count, cluster(commune_number year) absorb(year)
est sto c3
outreg2 using "Results/count_treatment/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year, cluster(commune_number year) absorb(cell_id)
est sto c4
outreg2 using "Results/count_treatment/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) ///
	keep(intra_cell_count border_cell_count)
reghdfe ntl intra_cell_count border_cell_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto c5
outreg2 using "Results/count_treatment/ntl_continuous.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(intra_cell_count border_cell_count)

reghdfe ntl intra_cell_count border_cell_count year##province_number, cluster(commune_number year) absorb(cell_id)

***

* Additional NTL continuous models
reghdfe ntl intra_cell_count border_cell_count year##province_number, cluster(commune_number year) absorb(cell_id)

reghdfe ntl intra_cell_count border_cell_count i.year c.year#i.province_number if ntl_lit_pre03==1, cluster(commune_number year) absorb(cell_id)
reghdfe ntl intra_cell_count border_cell_count i.year c.year#i.province_number if ntl_lit_pre03==0, cluster(commune_number year) absorb(cell_id)


* gen project_count for single merged count
***

gen project_count = intra_cell_count + border_cell_count
egen max_projects = max(project_count), by(cell_id)
cgmreg ntl project_count, cluster(commune_number year)
est sto d1
outreg2 using "Results/count_treatment/additional_models/merged_treatment/ntl_continuous.doc", replace noni nocons ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) ///
	addnote("Notes: DV=NTL. 'intra_cell_count' refers to the treatment variable that only considers villages within a cell. 'border_cell_count' refers to the treatment variable that only considers villages in the eight cells bordering a cell, but NOT within the cell itself.")
cgmreg ntl project_count, cluster(commune_number year)
est sto d2
outreg2 using "Results/count_treatment/additional_models/merged_treatment/ntl_continuous.doc", append noni nocons ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl project_count, cluster(commune_number year) absorb(year)
est sto d3
outreg2 using "Results/count_treatment/additional_models/merged_treatment/ntl_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) keep(project_count)
reghdfe ntl project_count i.year, cluster(commune_number year) absorb(cell_id)
est sto d4
outreg2 using "Results/count_treatment/additional_models/merged_treatment/ntl_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) keep(project_count)
reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
est sto d5
outreg2 using "Results/count_treatment/additional_models/merged_treatment/ntl_continuous.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) keep(project_count)

	
* gen cell count categories
	
gen trt1_intra = (intra_cell_count>=1)
gen trt2_intra = (intra_cell_count>=2)
gen trt3_intra = (intra_cell_count>=3)
gen trt4_intra = (intra_cell_count>=4)
gen trt5_intra = (intra_cell_count>=5)
reghdfe ntl trt1_intra trt2_intra trt3_intra trt4_intra trt5_intra i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)

gen trt1 = (intra_cell_count+border_cell_count>=1)
gen trt2_4 = (intra_cell_count+border_cell_count>=2)
gen trt5_9 = (intra_cell_count+border_cell_count>=5)
gen trt10_ = (intra_cell_count+border_cell_count>=10)
***

gen trt1 = (project_count>=1)
gen trt2_4 = (project_count>=2)
gen trt5_9 = (project_count>=5)
gen trt10_ = (project_count>=10)

gen dummy_2008 = (year>=2008)
gen intra_interact_2008 = intra_cell_count*dummy_2008
gen border_interact_2008 = border_cell_count*dummy_2008
gen project_interact_2008 = project_count*dummy_2008

gen trt1_interact_2008 = trt1*dummy_2008
gen trt2_4_interact_2008 = trt2_4*dummy_2008
gen trt5_9_interact_2008 = trt5_9*dummy_2008
gen trt10_interact_2008 = trt10_*dummy_2008

gen proj_count_interact = project_count*vills

cgmreg ntl project_count, cluster(commune_number year)
outreg2 using "Report/main_models.doc", replace noni nocons ///
	addtext("Year FEs", N, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N)
reghdfe ntl project_count, cluster(commune_number year) absorb(year)
outreg2 using "Report/main_models.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", N, "Lin. Time Trends by Prov.", N) keep(project_count)
reghdfe ntl project_count i.year, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/main_models.doc", append noni ///
	addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", N) keep(project_count)
reghdfe ntl project_count i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/main_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(project_count)
reghdfe ntl project_count project_interact_2008 i.year ///
	c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/main_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(project_count project_interact_2008)
reghdfe ntl trt1 trt2_4 trt5_9 trt10_ i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/main_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(trt1 trt2_4 trt5_9 trt10_)
reghdfe ntl trt1 trt2_4 trt5_9 trt10_ trt1_interact_2008 trt2_4_interact_2008 trt5_9_interact_2008 ///
	trt10_interact_2008 i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/main_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(trt1 trt2_4 trt5_9 trt10_ trt1_interact_2008 trt2_4_interact_2008 trt5_9_interact_2008 trt10_interact_2008)
reghdfe ntl trt1 trt2_4 trt5_9 trt10_ proj_count_interact i.year c.year#i.province_number, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/main_models.doc", append noni addtext("Year FEs", Y, "Grid cell FEs", Y, "Lin. Time Trends by Prov.", Y) ///
	keep(trt1 trt2_4 trt5_9 trt10_ proj_count_interact)

erase "Report/main_models.txt"

***

* ntl pre-trend regressions
gen earliest_end_date = intra_cell_earliest_enddate if intra_cell_earliest_enddate<border_cell_earliest_enddate
replace earliest_end_date = border_cell_earliest_enddate if intra_cell_earliest_enddate>border_cell_earliest_enddate

* using trends
reg earliest_end ntlpre_9202 i.province_number if year==2002
reg intra_cell_earliest_enddate ntlpre_9202 i.province_number if year==2002
gen time_to_trt = year - earliest_end_date
qui sum time_to_trt, d
loc min = `r(min)'
loc max = `r(max)'
egen time_to_trt_p = cut(time_to_trt), at(-20(1)20)

reghdfe earliest_end ntlpre_9202 if year==2002, absorb (commune_number)
levelsof time_to_trt_p, loc(levels) sep()

foreach l of local levels{
	local j = `l' + 50
	local label `"`label' `j' "`l'" "'
	}

* using ntl_dummy
reghdfe earliest_end ntl_dummy if year==2002, absorb (commune_number)
reghdfe earliest_end ntl_dummy if year==2002 & ntl_lit_pre92==0, absorb (commune_number)	

cap la drop time_to_trt_p `label'
la def time_to_trt_p `label', replace

replace time_to_trt_p = time_to_trt_p + 50
la values time_to_trt_p time_to_trt_p

reghdfe ntl i.time_to_trt_p i.year, cluster(commune_number year) absorb(cell_id)
outreg2 using "Report/time_to_trt/NTL", replace excel ci

***

gen time_trend = c.year if year<=2002

collapse (min) earliest_end_date province_number, by(cell_id year)


* gen treatment = (year >= earliest_end_date)

drop if earliest_end_date > 2016
 
reg time_trend earliest_end_date i.province_number

***
















	

cd "Results/count_treatment"
local txtfiles: dir . files "ntl_continuous.doc"
foreach txt in `txtfiles' {
    erase `"`txt'"'
}
