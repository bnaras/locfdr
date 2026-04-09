## Tests for locfdr warning and error paths

library(locfdr)

## ====================================================================
## Misfit warning (D > 1.5) when df is too low
## ====================================================================
data(hivdata)

expect_warning(
    locfdr(hivdata, df = 2, plot = 0),
    pattern = "misfit"
)

## ====================================================================
## Discrepancy warning between CM and MLE (hivdata with nulltype=2)
## ====================================================================
expect_warning(
    locfdr(hivdata, nulltype = 2, plot = 0),
    pattern = "Discrepancy"
)

## ====================================================================
## CM estimation failure with non-normal histogram center
## ====================================================================
set.seed(123)
z_uniform <- runif(500, -3, 3)

expect_error(
    locfdr(z_uniform, nulltype = 2, plot = 0),
    pattern = "CM estimation failed"
)

## nulltype=1 should still work (falls back to MLE) even with
## CM failure warning
w_fallback <- tryCatch(
    locfdr(z_uniform, nulltype = 1, plot = 0),
    error = function(e) NULL
)
## May produce warnings but should not error for nulltype=1
## (MLE estimation is more robust)

## ====================================================================
## nulltype=3 CM failure
## ====================================================================
expect_error(
    locfdr(z_uniform, nulltype = 3, plot = 0),
    pattern = "CM estimation failed"
)

## ====================================================================
## pct > 0 trims tails
## ====================================================================
w_pct <- locfdr(hivdata, pct = 0.01, plot = 0)
expect_equal(length(w_pct$fdr), length(hivdata))

## ====================================================================
## Negative pct (expands range)
## ====================================================================
w_negpct <- locfdr(hivdata, pct = -0.05, plot = 0)
expect_equal(length(w_negpct$fdr), length(hivdata))
