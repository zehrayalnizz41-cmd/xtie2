{smcl}
{* *! version 3.0 September 2026}{...}

{title:Title}

{phang}
{bf:xtie3} {hline 2} Extended Interactive Panel Data Estimation with full conditional marginal effects and Johnson-Neyman significance regions

{title:Syntax}

{p 8 17 2}
{cmd:xtie3} {it:depvar indepvars} [{cmd:,} {opt robust} {opt level(#)}]

{title:Description}

{pstd}
{cmd:xtie3} estimates fixed-effects panel-data models with all pairwise interaction terms among the specified independent variables.

{pstd}
The first two independent variables are treated as the primary interaction pair.

{pstd}
Compared with {cmd:xtie2}, {cmd:xtie3} extends the analysis by calculating full conditional marginal effects and Johnson-Neyman significance regions.

{pstd}
When additional independent variables are included in the model, their interactions with the focal variables are incorporated into the full marginal-effect calculation. Additional moderators are held at their sample means.

{title:Options}

{phang}
{opt robust} requests robust standard errors clustered at the panel level through the fixed-effects estimator.

{phang}
{opt level(#)} specifies the confidence level used in the Johnson-Neyman calculation. The default is {cmd:level(95)}.

{title:Main outputs}

{pstd}
{cmd:xtie3} reports:

{p 8 12 2}
- Fixed-effects panel estimation with all pairwise interaction terms

{p 8 12 2}
- Coefficient, standard error, t statistic, and p-value for the primary interaction

{p 8 12 2}
- Full conditional marginal effects

{p 8 12 2}
- Full marginal-effect zero-crossing values

{p 8 12 2}
- Johnson-Neyman lower and upper bounds

{p 8 12 2}
- Identification of statistically significant moderator regions

{p 8 12 2}
- Checks of whether critical values lie within the observed sample range

{p 8 12 2}
- Selected full marginal effects at minimum, mean, median, and maximum moderator values

{title:Example}

{phang}
{cmd:xtset country_id year}

{phang}
{cmd:xtie3 unemployment inflation energy_dependency energy_price_index gdp_growth, robust}

{title:Interpretation}

{pstd}
A zero-crossing value indicates the moderator value at which a conditional marginal effect changes sign.

{pstd}
Johnson-Neyman bounds indicate moderator values at which a conditional marginal effect changes between statistically significant and statistically insignificant.

{pstd}
These values are not Hansen-type panel threshold estimates.

{pstd}
Hansen-type panel thresholds represent separately estimated regime boundaries and require a dedicated threshold-estimation procedure.

{title:Stored results}

{pstd}
{cmd:xtie3} stores selected results in {cmd:e()} including:

{p 8 12 2}
{cmd:e(depvar)} dependent variable

{p 8 12 2}
{cmd:e(indepvars)} independent variables

{p 8 12 2}
{cmd:e(primary_interaction)} primary interaction

{p 8 12 2}
{cmd:e(beta_inter)} primary interaction coefficient

{p 8 12 2}
{cmd:e(se_inter)} standard error of primary interaction

{p 8 12 2}
{cmd:e(t_inter)} t statistic

{p 8 12 2}
{cmd:e(p_inter)} p-value

{p 8 12 2}
{cmd:e(zero_cross_x2)} zero-crossing for the marginal effect of the first focal variable

{p 8 12 2}
{cmd:e(zero_cross_x1)} zero-crossing for the marginal effect of the second focal variable

{p 8 12 2}
{cmd:e(JN_x2_low)} lower Johnson-Neyman bound for the first focal variable

{p 8 12 2}
{cmd:e(JN_x2_high)} upper Johnson-Neyman bound for the first focal variable

{p 8 12 2}
{cmd:e(JN_x1_low)} lower Johnson-Neyman bound for the second focal variable

{p 8 12 2}
{cmd:e(JN_x1_high)} upper Johnson-Neyman bound for the second focal variable

{title:Author}

{pstd}
Dr. Zehra Yalnız

{pstd}
Kocaeli University, Türkiye

{pstd}
Email: zehrayalnizz41@gmail.com

{pstd}
ORCID: 0000-0003-2633-2022

{title:Version}

{pstd}
Version 3.0, September 2026