capture program drop xtie3

program define xtie3, eclass
    version 18
    syntax varlist(min=3 numeric) [if] [in] [, ROBust LEVEL(real 95)]

    marksample touse

    if `level' <= 0 | `level' >= 100 {
        display as error "level() must be between 0 and 100."
        exit 198
    }

    local depvar : word 1 of `varlist'
    local totalvars : word count `varlist'

    local indepvars ""
    forvalues i = 2/`totalvars' {
        local v : word `i' of `varlist'
        local indepvars "`indepvars' `v'"
    }

    local nvars : word count `indepvars'

    if `nvars' < 2 {
        display as error "At least two independent variables are required."
        exit 198
    }

    local x1 : word 1 of `indepvars'
    local x2 : word 2 of `indepvars'

    local interactions ""

    display "--------------------------------------------------"
    display "Interactive Panel Data Estimation - xtie3"
    display "Dependent variable: `depvar'"
    display "Independent variables: `indepvars'"
    display "--------------------------------------------------"

    forvalues i = 1/`=`nvars'-1' {
        local var1 : word `i' of `indepvars'

        forvalues j = `=`i'+1'/`nvars' {
            local var2 : word `j' of `indepvars'
            local term "c.`var1'#c.`var2'"
            local interactions "`interactions' `term'"
            display "Included interaction: `var1' x `var2'"
        }
    }

    display "--------------------------------------------------"
    display "Estimating fixed-effects model..."
    display "--------------------------------------------------"

    if "`robust'" != "" {
        xtreg `depvar' `indepvars' `interactions' if `touse', fe vce(robust)
    }
    else {
        xtreg `depvar' `indepvars' `interactions' if `touse', fe
    }

    local primary "c.`x1'#c.`x2'"

    tempname V
    matrix `V' = e(V)

    tempname b a1 a2 va1 va2 vb cab1 cab2
    tempname tcrit A1 B1 C1 D1 A2 B2 C2 D2
    tempname root1a root1b root2a root2b temp
    tempname zcross1 zcross2

    scalar `b' = _b[`primary']
    scalar `vb' = `V'["`primary'","`primary'"]

    scalar `a1' = _b[`x1']
    scalar `va1' = `V'["`x1'","`x1'"]
    scalar `cab1' = `V'["`x1'","`primary'"]

    scalar `a2' = _b[`x2']
    scalar `va2' = `V'["`x2'","`x2'"]
    scalar `cab2' = `V'["`x2'","`primary'"]

    display "--------------------------------------------------"
    display "Conditioning values for additional moderators"
    display "--------------------------------------------------"

    if `nvars' > 2 {

        forvalues k = 3/`nvars' {

            local xk : word `k' of `indepvars'

            quietly summarize `xk' if e(sample), meanonly
            local mk = r(mean)

            display "`xk' fixed at sample mean = " %10.4f `mk'

            local int1 "c.`x1'#c.`xk'"
            local int2 "c.`x2'#c.`xk'"

            scalar `a1' = `a1' + (`mk') * _b[`int1']
            scalar `a2' = `a2' + (`mk') * _b[`int2']

            scalar `va1' = `va1' + (`mk')^2 * `V'["`int1'","`int1'"] + 2*(`mk')*`V'["`x1'","`int1'"]
            scalar `va2' = `va2' + (`mk')^2 * `V'["`int2'","`int2'"] + 2*(`mk')*`V'["`x2'","`int2'"]

            scalar `cab1' = `cab1' + (`mk') * `V'["`int1'","`primary'"]
            scalar `cab2' = `cab2' + (`mk') * `V'["`int2'","`primary'"]

            local mean`k' = `mk'
            local int1_`k' "`int1'"
            local int2_`k' "`int2'"
        }

        if `nvars' > 3 {

            forvalues k = 3/`=`nvars'-1' {

                forvalues l = `=`k'+1'/`nvars' {

                    local mk = `mean`k''
                    local ml = `mean`l''

                    local ik "`int1_`k''"
                    local il "`int1_`l''"

                    scalar `va1' = `va1' + 2*(`mk')*(`ml')*`V'["`ik'","`il'"]

                    local ik2 "`int2_`k''"
                    local il2 "`int2_`l''"

                    scalar `va2' = `va2' + 2*(`mk')*(`ml')*`V'["`ik2'","`il2'"]
                }
            }
        }
    }

    tempname beta1 beta2 seint tint pint
    scalar `beta1' = _b[`x1']
    scalar `beta2' = _b[`x2']
    scalar `seint' = _se[`primary']
    scalar `tint' = `b' / `seint'
    scalar `pint' = 2*ttail(e(df_r),abs(`tint'))

    quietly summarize `x1' if e(sample), detail
    local x1min = r(min)
    local x1mean = r(mean)
    local x1median = r(p50)
    local x1max = r(max)

    quietly summarize `x2' if e(sample), detail
    local x2min = r(min)
    local x2mean = r(mean)
    local x2median = r(p50)
    local x2max = r(max)

    display "--------------------------------------------------"
    display "Primary interaction"
    display "--------------------------------------------------"
    display "Main variable 1: `x1'"
    display "Main variable 2: `x2'"
    display "Primary interaction: `x1' x `x2'"
    display "Interaction coefficient = " %10.6f `b'
    display "SE = " %10.6f `seint'
    display "t = " %10.3f `tint'
    display "p = " %10.4f `pint'

    if `b' != 0 {

        scalar `zcross1' = -`a1'/`b'
        scalar `zcross2' = -`a2'/`b'

        display "--------------------------------------------------"
        display "Full marginal-effect zero-crossing values"
        display "--------------------------------------------------"

        display "Zero-crossing of marginal effect of `x1' over `x2':"
        display %10.4f `zcross1'
        display "Observed `x2' range: " %10.4f `x2min' " to " %10.4f `x2max'

        if `zcross1' >= `x2min' & `zcross1' <= `x2max' {
            display "Zero-crossing lies WITHIN the observed sample range."
        }
        else {
            display "Zero-crossing lies OUTSIDE the observed sample range."
        }

        display " "

        display "Zero-crossing of marginal effect of `x2' over `x1':"
        display %10.4f `zcross2'
        display "Observed `x1' range: " %10.4f `x1min' " to " %10.4f `x1max'

        if `zcross2' >= `x1min' & `zcross2' <= `x1max' {
            display "Zero-crossing lies WITHIN the observed sample range."
        }
        else {
            display "Zero-crossing lies OUTSIDE the observed sample range."
        }
    }

    scalar `tcrit' = invttail(e(df_r),(100-`level')/200)

    display "--------------------------------------------------"
    display "Johnson-Neyman significance regions (`level'% confidence)"
    display "--------------------------------------------------"

    scalar `A1' = `b'^2 - `tcrit'^2*`vb'
    scalar `B1' = 2*(`a1'*`b' - `tcrit'^2*`cab1')
    scalar `C1' = `a1'^2 - `tcrit'^2*`va1'
    scalar `D1' = `B1'^2 - 4*`A1'*`C1'

    display "Marginal effect of `x1' conditional on `x2':"

    if `D1' >= 0 & abs(`A1') > 1e-15 {

        scalar `root1a' = (-`B1' - sqrt(`D1'))/(2*`A1')
        scalar `root1b' = (-`B1' + sqrt(`D1'))/(2*`A1')

        if `root1a' > `root1b' {
            scalar `temp' = `root1a'
            scalar `root1a' = `root1b'
            scalar `root1b' = `temp'
        }

        display "JN lower bound = " %10.4f `root1a'
        display "JN upper bound = " %10.4f `root1b'
        display "Observed `x2' range = " %10.4f `x2min' " to " %10.4f `x2max'

        if `root1a' >= `x2min' & `root1a' <= `x2max' {
            display "Lower JN bound lies WITHIN the observed range."
        }
        else {
            display "Lower JN bound lies OUTSIDE the observed range."
        }

        if `root1b' >= `x2min' & `root1b' <= `x2max' {
            display "Upper JN bound lies WITHIN the observed range."
        }
        else {
            display "Upper JN bound lies OUTSIDE the observed range."
        }

        if `A1' < 0 {
            display "Statistically significant region: BETWEEN the two JN bounds."
        }
        else {
            display "Statistically significant regions: BELOW the lower bound and ABOVE the upper bound."
        }
    }
    else if `D1' < 0 {

        if `A1' > 0 {
            display "The marginal effect is statistically significant across the full moderator range."
        }
        else {
            display "No statistically significant Johnson-Neyman region was identified."
        }
    }
    else {
        display "Johnson-Neyman boundaries could not be uniquely determined."
    }

    display " "

    scalar `A2' = `b'^2 - `tcrit'^2*`vb'
    scalar `B2' = 2*(`a2'*`b' - `tcrit'^2*`cab2')
    scalar `C2' = `a2'^2 - `tcrit'^2*`va2'
    scalar `D2' = `B2'^2 - 4*`A2'*`C2'

    display "Marginal effect of `x2' conditional on `x1':"

    if `D2' >= 0 & abs(`A2') > 1e-15 {

        scalar `root2a' = (-`B2' - sqrt(`D2'))/(2*`A2')
        scalar `root2b' = (-`B2' + sqrt(`D2'))/(2*`A2')

        if `root2a' > `root2b' {
            scalar `temp' = `root2a'
            scalar `root2a' = `root2b'
            scalar `root2b' = `temp'
        }

        display "JN lower bound = " %10.4f `root2a'
        display "JN upper bound = " %10.4f `root2b'
        display "Observed `x1' range = " %10.4f `x1min' " to " %10.4f `x1max'

        if `root2a' >= `x1min' & `root2a' <= `x1max' {
            display "Lower JN bound lies WITHIN the observed range."
        }
        else {
            display "Lower JN bound lies OUTSIDE the observed range."
        }

        if `root2b' >= `x1min' & `root2b' <= `x1max' {
            display "Upper JN bound lies WITHIN the observed range."
        }
        else {
            display "Upper JN bound lies OUTSIDE the observed range."
        }

        if `A2' < 0 {
            display "Statistically significant region: BETWEEN the two JN bounds."
        }
        else {
            display "Statistically significant regions: BELOW the lower bound and ABOVE the upper bound."
        }
    }
    else if `D2' < 0 {

        if `A2' > 0 {
            display "The marginal effect is statistically significant across the full moderator range."
        }
        else {
            display "No statistically significant Johnson-Neyman region was identified."
        }
    }
    else {
        display "Johnson-Neyman boundaries could not be uniquely determined."
    }

    display "--------------------------------------------------"
    display "Selected full marginal effects"
    display "--------------------------------------------------"

    foreach zname in minimum mean median maximum {

        if "`zname'" == "minimum" local z = `x2min'
        if "`zname'" == "mean" local z = `x2mean'
        if "`zname'" == "median" local z = `x2median'
        if "`zname'" == "maximum" local z = `x2max'

        tempname me se tt pp vv

        scalar `me' = `a1' + `b'*(`z')
        scalar `vv' = `va1' + 2*(`z')*`cab1' + (`z')^2*`vb'

        if `vv' >= 0 {
            scalar `se' = sqrt(`vv')
            scalar `tt' = `me'/`se'
            scalar `pp' = 2*ttail(e(df_r),abs(`tt'))

            display "ME of `x1' at `zname' `x2' (" %9.3f `z' "): " %10.5f `me' "  SE = " %10.5f `se' "  p = " %7.4f `pp'
        }
    }

    display " "

    foreach zname in minimum mean median maximum {

        if "`zname'" == "minimum" local z = `x1min'
        if "`zname'" == "mean" local z = `x1mean'
        if "`zname'" == "median" local z = `x1median'
        if "`zname'" == "maximum" local z = `x1max'

        tempname me2 se2 tt2 pp2 vv2

        scalar `me2' = `a2' + `b'*(`z')
        scalar `vv2' = `va2' + 2*(`z')*`cab2' + (`z')^2*`vb'

        if `vv2' >= 0 {
            scalar `se2' = sqrt(`vv2')
            scalar `tt2' = `me2'/`se2'
            scalar `pp2' = 2*ttail(e(df_r),abs(`tt2'))

            display "ME of `x2' at `zname' `x1' (" %9.3f `z' "): " %10.5f `me2' "  SE = " %10.5f `se2' "  p = " %7.4f `pp2'
        }
    }

    display "--------------------------------------------------"
    display "Automatic interpretation"
    display "--------------------------------------------------"

    if `pint' < 0.01 {
        display "The primary interaction coefficient is statistically significant at the 1% level."
    }
    else if `pint' < 0.05 {
        display "The primary interaction coefficient is statistically significant at the 5% level."
    }
    else if `pint' < 0.10 {
        display "The primary interaction coefficient is statistically significant at the 10% level."
    }
    else {
        display "The primary interaction coefficient is not statistically significant at conventional levels."
    }

    if `b' > 0 {
        display "As `x2' increases, the conditional marginal effect of `x1' becomes more positive."
    }
    else if `b' < 0 {
        display "As `x2' increases, the conditional marginal effect of `x1' becomes more negative."
    }

    display "Additional moderators are held at their sample means in the full marginal-effect and JN calculations."

    ereturn local cmd "xtie3"
    ereturn local depvar "`depvar'"
    ereturn local indepvars "`indepvars'"
    ereturn local primary_interaction "`x1' x `x2'"

    ereturn scalar beta_inter = `b'
    ereturn scalar se_inter = `seint'
    ereturn scalar t_inter = `tint'
    ereturn scalar p_inter = `pint'
    ereturn scalar level = `level'

    if `b' != 0 {
        ereturn scalar zero_cross_x2 = `zcross1'
        ereturn scalar zero_cross_x1 = `zcross2'
    }

    if `D1' >= 0 & abs(`A1') > 1e-15 {
        ereturn scalar JN_x2_low = `root1a'
        ereturn scalar JN_x2_high = `root1b'
    }

    if `D2' >= 0 & abs(`A2') > 1e-15 {
        ereturn scalar JN_x1_low = `root2a'
        ereturn scalar JN_x1_high = `root2b'
    }

    display "--------------------------------------------------"
    display "xtie3 completed successfully."
    display "--------------------------------------------------"

end