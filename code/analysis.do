/****************************************************************************************
Project: UK National Living Wage and Youth Employment
Purpose: Difference-in-Differences analysis of the effect of the April 2016 National
         Living Wage on youth employment in the UK.
Data: UK Labour Force Survey Two-Quarter Longitudinal Datasets, 2013–2018
Author: Mahita Dissanayake
****************************************************************************************/


/***************************************************************************************
0. SETUP
***************************************************************************************/

clear all
set more off

* Install required package if not already installed
capture which esttab
if _rc ssc install estout


/***************************************************************************************
1. CREATE CLEANED DATASETS
***************************************************************************************/

* NOTE:
* This section was repeated for each raw LFS dataset:
* - jan_june_2013.dta
* - july_dec_2013.dta
* - jan_june_2014.dta
* - july_dec_2014.dta
* - jan_june_2015.dta
* - july_dec_2015.dta
* - jan_june_2017.dta
* - july_dec_2017.dta
* - jan_june_2018.dta
* - july_dec_2018.dta
*
* 2016 is excluded to avoid ambiguity around the policy implementation period.


* Example: cleaning one raw dataset
use jan_june_2013.dta, clear

rename ETUKEUL2 ethnicity
rename SEX sex
rename MARSTA2 marstatus 
rename GORWKR1 region
rename HIQUL11D2 education
rename Inde07m1 industry
rename FTPTWK1 ftpt
rename DISEA2 disability 
rename SC10MMJ1 occupation 
rename AGE1 age
rename ILODEFR1 empstatus
rename HOURPAY1 hourlypay
rename PERSID id

keep id age sex ethnicity marstatus region education industry ftpt disability occupation empstatus hourlypay

gen year = 2013
gen post = 0

save clean_jan_june_2013.dta, replace


/***************************************************************************************
2. COMBINE CLEANED DATASETS INTO MASTER DATASET
***************************************************************************************/

use clean_jan_june_2013.dta, clear

append using clean_july_dec_2013.dta
append using clean_jan_june_2014.dta
append using clean_july_dec_2014.dta
append using clean_jan_june_2015.dta
append using clean_july_dec_2015.dta

append using clean_jan_june_2017.dta
append using clean_july_dec_2017.dta
append using clean_jan_june_2018.dta
append using clean_july_dec_2018.dta

save lfs_master_clean.dta, replace


/***************************************************************************************
3. LOAD MASTER DATASET AND CLEAN ANALYSIS VARIABLES
***************************************************************************************/

use lfs_master_clean.dta, clear

* Replace missing value codes with Stata missing values
foreach var in education sex occupation industry empstatus hourlypay region ftpt ethnicity disability marstatus {
    replace `var' = . if inlist(`var', -8, -9)
}

* Restrict sample to working-age individuals aged 18–64
drop if age < 18 | age > 64

* Create employment outcome variable
gen employed = (empstatus == 1)
label variable employed "Employed"

* Create treatment group indicator
gen young = (age >= 18 & age <= 24)
label variable young "Aged 18–24"

* Create post-policy indicator
* Assumes post = 1 for 2017 and 2018, and post = 0 for 2013–2015
label variable post "Post-NLW period"

* Create Difference-in-Differences interaction term
gen post_young = post * young
label variable post_young "Post-NLW x Aged 18–24"


/***************************************************************************************
4. DESCRIPTIVE STATISTICS
***************************************************************************************/

estpost tabstat employed age young post sex marstatus education ethnicity disability, ///
    stat(mean sd min max) columns(statistics)

eststo summary_stats


/***************************************************************************************
5. BASELINE DIFFERENCE-IN-DIFFERENCES MODEL
***************************************************************************************/

reg employed post young post_young, robust
eststo baseline


/***************************************************************************************
6. DIFFERENCE-IN-DIFFERENCES MODEL WITH CONTROLS
***************************************************************************************/

reg employed post young post_young ///
    i.sex i.marstatus i.education i.ethnicity i.disability, robust

eststo controls


/***************************************************************************************
7. PRE-TRENDS TEST
***************************************************************************************/

reg employed ib2013.year##i.young if year < 2016, robust
eststo pretrends

testparm 2014.year#1.young 2015.year#1.young

margins year#young

marginsplot, ///
    xdimension(year) ///
    legend(order(1 "Older workers" 2 "Young workers")) ///
    title("Pre-trends Test") ///
    ytitle("Employment Rate") ///
    xtitle("Year")

graph export "outputs/pre_trends_graph.png", replace


/***************************************************************************************
8. DYNAMIC DIFFERENCE-IN-DIFFERENCES / EVENT STUDY
***************************************************************************************/

reg employed ib2013.year##i.young ///
    i.sex i.marstatus i.education i.ethnicity i.disability, robust

eststo dynamic

margins year#young

marginsplot, ///
    xdimension(year) ///
    title("Event Study: NLW Impact on Youth Employment") ///
    ytitle("Employment Rate") ///
    xtitle("Year") ///
    legend(order(1 "Older workers" 2 "Young workers"))

graph export "outputs/event_study_graph.png", replace


/***************************************************************************************
9. ROBUSTNESS CHECKS
***************************************************************************************/

* Robustness check 1: Add full-time/part-time status
reg employed post young post_young ///
    i.ftpt i.sex i.marstatus i.education i.ethnicity i.disability, robust

eststo robust_ftpt


* Robustness check 2: Narrow comparison group to ages 25–40
reg employed post young post_young ///
    i.sex i.marstatus i.education i.ethnicity i.disability ///
    if age <= 40, robust

eststo robust_narrow


* Robustness check 3: Simplified controls, excluding ethnicity
reg employed post young post_young ///
    i.sex i.marstatus i.education i.disability, robust

eststo robust_simple


/***************************************************************************************
10. EXPORT TABLES
***************************************************************************************/

esttab baseline controls using "outputs/main_results.rtf", ///
    keep(post young post_young) ///
    se ///
    label ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Difference-in-Differences Estimates of the NLW on Youth Employment") ///
    mtitles("Baseline" "With Controls") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    replace


esttab summary_stats using "outputs/summary_stats.rtf", ///
    cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") ///
    label ///
    title("Descriptive Statistics") ///
    replace


esttab baseline controls using "outputs/full_results.rtf", ///
    se ///
    label ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Difference-in-Differences Estimates with Full Controls") ///
    mtitles("Baseline" "With Controls") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    replace


esttab pretrends using "outputs/pretrends_results.rtf", ///
    se ///
    label ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Pre-Trends Test") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    replace


esttab dynamic using "outputs/event_study_results.rtf", ///
    se ///
    label ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Dynamic Difference-in-Differences Event Study") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    replace


esttab robust_ftpt robust_narrow robust_simple using "outputs/robustness_results.rtf", ///
    keep(post_young) ///
    se ///
    label ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Robustness of Difference-in-Differences Estimates") ///
    mtitles("FT/PT Controls" "Age ≤40 Sample" "Simplified Controls") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    replace
