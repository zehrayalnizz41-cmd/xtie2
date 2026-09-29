# xtie2 2.3.0 release candidate

This is a review candidate, not an SSC or GitHub release. It merges full focal marginal effects and Johnson–Neyman regions from `xtie3` while keeping the `xtie2` command and legacy stored-result names. `pair(var1 var2)` can choose any two explanatory variables; if omitted, the first two are used as before. All pairwise interactions remain in the fitted FE model. The FE coefficient table is replayed before the conditional-effect summaries.

Copy these files to a working directory, change Stata's directory to that directory, and run `do xtie2_validation.do` in Stata 17 or later. Compare displayed Johnson–Neyman regions against `lincom` at values just inside and outside each reported boundary, including cases with zero, one, or two boundaries. Also check unbalanced panels, omitted interactions, and long variable names before release. A conditional effect's standard error is computed directly as a linear combination of the full estimated covariance matrix; an invalid variance is explicitly displayed rather than silently skipped.

The validation script is supplied but has not been executed here because Stata is unavailable in this workspace. Do not send this candidate to SSC until that run and a full review succeed.
