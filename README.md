# xtie2

**Interactive Panel Data Estimation for Stata**

`xtie2` is a user-written Stata command for fixed-effects panel estimation with automatic pairwise interaction terms, marginal-effect calculations, and marginal-effect zero-crossing analysis.

## Installation

Install directly from GitHub in Stata:

`net install xtie2, from("https://raw.githubusercontent.com/zehrayalnizz41-cmd/xtie2/main/")`

After installation:

`help xtie2`

## Syntax

`xtie2 depvar indepvars [, robust]`

## Example

`xtset country_id year`

`xtie2 unemployment energy_dependency energy_price_index inflation gdp_growth, robust`

## Main Features

- Fixed-effects panel estimation
- Automatic pairwise interactions
- Optional robust standard errors
- Marginal-effect calculations
- Interaction coefficient and significance test
- Marginal-effect zero-crossing critical values
- Automatic check of whether critical values lie within the observed sample range
- Results stored in `e()`

## Important Note

The critical values reported by `xtie2` are marginal-effect zero-crossing values.

They are not Hansen-type panel threshold estimates.

## Author

Dr. Zehra Yalnız  
Kocaeli University, Türkiye  
Email: zehrayalnizz41@gmail.com  
ORCID: 0000-0003-2633-2022

## Version

Version 2.0, September 2026

## License

MIT License

Both `xtie2` and `xtie3` are distributed under the MIT License.
