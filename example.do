*******************************************************
* xtie2 example.do
* Version 2.3.0 — 29 September 2026
*
* Demonstrates:
*   1. fixed-effects estimation with all pairwise interactions
*   2. default focal-pair behavior
*   3. pair() selection
*   4. robust standard errors
*   5. Johnson-Neyman regions
*   6. stored results
*
* Requires Stata 17 or later.
*******************************************************

version 17
clear all
set more off
set seed 271828

*------------------------------------------------------*
* 1. Create a reproducible panel-data example
*------------------------------------------------------*

set obs 240

gen int panel = ceil(_n/12)
bysort panel: gen int year = 2000 + _n

xtset panel year

gen double x1 = rnormal()
gen double x2 = rnormal() + 0.2*x1
gen double z  = rnormal() + panel/30

gen double y = ///
      0.7*x1 ///
    - 0.3*x2 ///
    + 0.4*z ///
    + 0.5*x1*x2 ///
    + 0.2*x1*z ///
    - 0.15*x2*z ///
    + panel/10 ///
    + rnormal()

*------------------------------------------------------*
* 2. Basic use
*
* The first two explanatory variables, x1 and x2,
* are used as the focal pair by default.
* All pairwise interactions are included automatically.
*------------------------------------------------------*

xtie2 y x1 x2 z, robust level(95)

* Review stored results
ereturn list

display "Primary interaction: " e(primary_interaction)
display "Interaction coefficient = " e(beta_inter)
display "Interaction SE          = " e(se_inter)
display "Interaction p-value     = " e(p_inter)
display "Confidence level        = " e(level)

* Zero crossings, when defined
capture noisily display "Zero crossing across x2 = " e(zero_cross_x2)
capture noisily display "Zero crossing across x1 = " e(zero_cross_x1)

* Johnson-Neyman boundaries, when defined
capture noisily display "JN x2 lower = " e(JN_x2_low)
capture noisily display "JN x2 upper = " e(JN_x2_high)
capture noisily display "JN x1 lower = " e(JN_x1_low)
capture noisily display "JN x1 upper = " e(JN_x1_high)

* The command creates me_x1, me_x2, and—when the
* primary interaction is nonzero—regime_x2.
summarize me_x1 me_x2
capture tabulate regime_x2

*------------------------------------------------------*
* 3. Select a different focal pair with pair()
*
* Drop generated variables before running xtie2 again.
* xtie2 deliberately does not overwrite them.
*------------------------------------------------------*

capture drop me_x1 me_x2 regime_x2

xtie2 y x1 x2 z, pair(x2 z) robust level(90)

ereturn list

display "Selected focal interaction: " e(primary_interaction)
display "Interaction coefficient = " e(beta_inter)
display "Interaction p-value     = " e(p_inter)
display "Confidence level        = " e(level)

summarize me_x2 me_z
capture tabulate regime_z

*------------------------------------------------------*
* 4. Notes
*
* - pair() changes the focal pair used for conditional
*   effects; the fitted FE model still contains all
*   pairwise interactions.
*
* - Other explanatory variables are held at their
*   estimation-sample means in the focal effects.
*
* - Zero crossings are sign-change points of marginal
*   effects. They are not Hansen-type panel thresholds.
*
* - Johnson-Neyman boundaries identify changes in
*   statistical significance at the requested level().
*------------------------------------------------------*

display as result "xtie2 example completed."
