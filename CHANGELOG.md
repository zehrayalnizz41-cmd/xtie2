# Change log

## 2.3.0 (29 September 2026)

- Retains automatic pairwise interactions and fixed-effects estimation.
- Adds `pair(var1 var2)` to choose any two focal explanatory variables; omitting it retains the original first-two-variable convention.
- Incorporates interactions with other regressors into both focal conditional marginal effects, holding those other regressors at their estimation-sample means.
- Computes focal-effect standard errors with the full coefficient covariance matrix and reports Johnson–Neyman boundaries using `level()`.
- Replays the complete fixed-effects regression table, reports all four selected moderator values, and explicitly flags an invalid calculated variance.
- Retains existing `e(critical_x1)` and `e(critical_x2)` names and adds the extended result names documented in the help file.
- Preserves preexisting dataset variables by stopping before estimation when an output name already exists.
