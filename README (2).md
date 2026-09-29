# xtie2 for Stata

**Version 2.3.0 — 29 September 2026**

`xtie2` implements fixed-effects panel estimation with automatic pairwise interactions, full conditional marginal effects, marginal-effect zero crossings, and Johnson–Neyman significance regions.

Version 2.3.0 integrates the extended focal-effect and Johnson–Neyman functionality previously developed under `xtie3` into the maintained `xtie2` command, while preserving the original first-two-variable convention and legacy stored-result names.

## What the command does

The command estimates a fixed-effects panel model containing all pairwise interactions among the explanatory variables and then evaluates the conditional effects of a selected focal pair.

The implemented sequence is:

1. Fit a fixed-effects panel model with `xtreg, fe`.
2. Include all pairwise interactions among the explanatory variables automatically.
3. Use the first two explanatory variables as the focal pair by default.
4. Allow any two explanatory variables to be selected with `pair(var1 var2)`.
5. Hold the remaining explanatory variables at their estimation-sample means when computing the focal conditional effects.
6. Compute conditional marginal effects in both directions for the selected focal pair.
7. Compute standard errors and significance tests from the full estimated covariance matrix.
8. Report marginal effects at the moderator minimum, mean, median, and maximum.
9. Compute marginal-effect zero-crossing critical values and check whether they lie within the observed estimation-sample range.
10. Compute Johnson–Neyman significance boundaries at the confidence level requested with `level()`.
11. Store key interaction, zero-crossing, and Johnson–Neyman results in `e()`.

The marginal-effect zero crossing and the Johnson–Neyman boundary are different quantities. Neither should be interpreted as a Hansen-type panel threshold estimate.

## Requirements

- Stata 17 or later
- Panel data declared with `xtset`
- Continuous explanatory variables

The current version has been exercised under StataNow 19.

## Installation from GitHub

```stata
net install xtie2, from("https://raw.githubusercontent.com/zehrayalnizz41-cmd/xtie2/main/") replace
```

After installation:

```stata
which xtie2
help xtie2
```

## Syntax

```stata
xtie2 depvar indepvars [if] [in] [, robust level(#) pair(var1 var2)]
```

## Basic use

```stata
xtset country_id year
xtie2 unemployment inflation energy_dependency energy_price_index gdp_growth, robust
```

By default, the first two explanatory variables form the focal pair.

To select another focal pair:

```stata
xtie2 unemployment inflation energy_dependency energy_price_index gdp_growth, ///
    pair(inflation energy_dependency) robust level(95)
```

The fitted model still contains all pairwise interactions among the explanatory variables. `pair()` changes the focal pair used for the conditional-effect summaries.

## Main output

For each focal variable, `xtie2` reports its conditional marginal effect across the other focal variable at:

- minimum
- mean
- median
- maximum

The output also reports:

- the primary interaction coefficient, standard error, and p-value
- the marginal-effect zero crossing
- whether the zero crossing lies inside the observed moderator range
- Johnson–Neyman boundaries when they are uniquely determined
- the corresponding significance-region interpretation, subject to the observed moderator range

## Robust standard errors

The `robust` option calls:

```stata
xtreg ..., fe vce(robust)
```

within the fixed-effects estimation.

## Generated variables

For the selected focal pair, the command creates estimation-sample marginal-effect variables of the form:

```stata
me_x1
me_x2
```

where the suffixes correspond to the actual focal variable names.

When the primary interaction is nonzero, the command also creates:

```stata
regime_x2
```

for the second focal variable. This variable classifies observations relative to the marginal-effect zero crossing. It is not an estimated threshold regime.

`xtie2` does not overwrite pre-existing variables with these names; it stops before estimation if an output name already exists.

## Stored results

Useful stored results include:

```stata
ereturn list
```

Key results include:

```stata
e(cmd)
e(depvar)
e(indepvars)
e(primary_interaction)

e(beta_inter)
e(se_inter)
e(t_inter)
e(p_inter)
e(level)

e(critical_x1)
e(critical_x2)

e(zero_cross_x1)
e(zero_cross_x2)

e(JN_x1_low)
e(JN_x1_high)
e(JN_x2_low)
e(JN_x2_high)
```

Zero-crossing or Johnson–Neyman results are absent when they are not defined for the fitted model.

The underlying fixed-effects estimation results, including `e(b)`, `e(V)`, and `e(sample)`, are retained.

## Validation

Version 2.3.0 includes `xtie2_validation.do` for reproducible software checks.

The validation script checks, among other items:

- default focal-pair behavior
- user-selected `pair()`
- `level()` handling
- full conditional derivatives when additional regressors are present
- agreement with manually constructed `lincom` expressions
- generated marginal-effect variables
- stored results
- protection against overwriting existing generated variables

The command has also been used in Stata on empirical panel-data applications.

## Important interpretation note

The critical values reported by `xtie2` are marginal-effect zero-crossing values. They indicate where a conditional marginal effect changes sign.

Johnson–Neyman boundaries instead identify moderator values at which the statistical significance of a conditional effect changes at the requested confidence level.

These quantities should not be described as Hansen-type panel thresholds.

## Versioning

- **2.3.0**: integrates extended focal marginal effects and Johnson–Neyman calculations into `xtie2`; adds `pair()` and `level()`; uses the full covariance matrix for conditional-effect inference; reports marginal effects at four moderator values; retains legacy zero-crossing result names and adds extended stored results.
- Earlier `xtie2` versions: fixed-effects estimation with automatic pairwise interactions and the original first-two-variable focal convention.

## Authors

**Lead Developer:** Dr. Zehra Yalnız  
Kocaeli, Türkiye  
ORCID: 0000-0003-2633-2022  
Email: zehrayalnizz41@gmail.com

**Co-developer:** Prof. Dr. Figen Büyükakın  
Kocaeli University, Türkiye

## Citation

When using `xtie2`, please cite the software and the accompanying methodological work where applicable.

A formal software citation is also provided in `CITATION.cff`.

## License

MIT License. See `LICENSE`.
