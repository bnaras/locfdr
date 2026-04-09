## Tests for locfdr()

library(locfdr)
data(hivdata)
data(lfdrsim)
zex <- lfdrsim[, "zex"]

## ====================================================================
## Default call (nulltype=1, type=0) with hivdata
## ====================================================================
w <- locfdr(hivdata, plot = 0)

## Return structure
expect_true(is.list(w))
## Must contain at least the classic elements (2.0-0 adds nulltype, N, class)
classic_names <- c("fdr", "fp0", "Efdr", "cdf1", "mat", "z.2", "call")
expect_true(all(classic_names %in% names(w)))
expect_true(inherits(w$call, "call"))

## fdr vector
expect_equal(length(w$fdr), length(hivdata))
expect_true(all(w$fdr >= 0 & w$fdr <= 1))

## fp0 matrix structure
expect_equal(dim(w$fp0), c(6, 3))
expect_equal(rownames(w$fp0), c("thest", "theSD", "mlest", "mleSD", "cmest", "cmeSD"))
expect_equal(colnames(w$fp0), c("delta", "sigma", "p0"))

## fp0 values: theoretical null is fixed
expect_equal(w$fp0["thest", "delta"], 0)
expect_equal(w$fp0["thest", "sigma"], 1)
expect_equal(w$fp0["theSD", "delta"], 0)
expect_equal(w$fp0["theSD", "sigma"], 0)

## fp0: MLE estimates for hivdata (reference from CRAN 1.1-8)
expect_equal(w$fp0["mlest", "delta"], -0.1160, tolerance = 0.005)
expect_equal(w$fp0["mlest", "sigma"], 0.7537, tolerance = 0.005)
expect_equal(w$fp0["mlest", "p0"], 0.9342, tolerance = 0.005)

## fp0: SDs should be positive
expect_true(all(w$fp0["mleSD", ] > 0, na.rm = TRUE))
expect_true(all(w$fp0["cmeSD", ] > 0, na.rm = TRUE))

## Efdr structure
expect_equal(length(w$Efdr), 6)
expect_equal(names(w$Efdr), c("Efdr", "Eleft", "Eright", "Efdrtheo", "Eleft0", "Eright0"))
expect_true(all(w$Efdr >= 0 & w$Efdr <= 1))

## mat structure
expect_equal(dim(w$mat), c(119, 11))
expect_equal(colnames(w$mat),
             c("x", "fdr", "Fdrleft", "Fdrright", "f", "f0", "f0theo",
               "fdrtheo", "counts", "lfdrse", "p1f1"))

## cdf1 structure
expect_equal(dim(w$cdf1), c(99, 2))
expect_equal(w$cdf1[, 1], seq(0.01, 0.99, 0.01))
## cdf1 should be non-decreasing
expect_true(all(diff(w$cdf1[, 2]) >= -1e-10))

## z.2: threshold where fdr < 0.2
expect_equal(length(w$z.2), 2)
expect_true(w$z.2[1] < 0)  # left threshold is negative
expect_true(w$z.2[2] > 0)  # right threshold is positive
expect_equal(w$z.2[1], -2.471, tolerance = 0.01)
expect_equal(w$z.2[2], 2.228, tolerance = 0.01)

## ====================================================================
## nulltype=0 (theoretical null)
## ====================================================================
w0 <- locfdr(hivdata, nulltype = 0, plot = 0)

expect_equal(length(w0$fdr), length(hivdata))
expect_true(all(w0$fdr >= 0 & w0$fdr <= 1))
## mat column names differ for nulltype=0
expect_equal(colnames(w0$mat)[c(3, 4, 10)],
             c("Fdrltheo", "Fdrrtheo", "lfdrsetheo"))

## ====================================================================
## nulltype=2 (central matching) — produces discrepancy warning for hivdata
## ====================================================================
expect_warning(
    w_cm <- locfdr(hivdata, nulltype = 2, plot = 0),
    pattern = "Discrepancy"
)
expect_equal(length(w_cm$fdr), length(hivdata))

## ====================================================================
## nulltype=3 (split normal) — fp0 has 4 columns
## ====================================================================
expect_warning(
    w3 <- locfdr(hivdata, nulltype = 3, plot = 0),
    pattern = "Discrepancy"
)
expect_equal(dim(w3$fp0), c(6, 4))
expect_equal(colnames(w3$fp0), c("delta", "sigleft", "p0", "sigright"))

## ====================================================================
## type=1 (polynomial fitting)
## ====================================================================
w_poly <- locfdr(hivdata, type = 1, plot = 0)
expect_equal(length(w_poly$fdr), length(hivdata))
expect_equal(dim(w_poly$mat), c(119, 11))

## ====================================================================
## mult argument
## ====================================================================
wm <- locfdr(hivdata, mult = c(2, 5), plot = 0)
expect_true("mult" %in% names(wm))
expect_equal(length(wm$mult), 3)  # includes mult=1
expect_equal(names(wm$mult), c("1", "2", "5"))
expect_equal(wm$mult["1"], c("1" = 1))  # baseline is always 1
expect_true(all(wm$mult > 0))

## ====================================================================
## Plot smoke tests — verify no errors for all plot modes
## ====================================================================
pdf(file = NULL)  # null device to suppress output
for (p in 0:4) {
    result <- tryCatch(locfdr(hivdata, plot = p), error = function(e) e)
    expect_false(inherits(result, "error"),
                 info = paste("plot =", p, "should not error"))
}
dev.off()

## ====================================================================
## lfdrsim: statistical validation against known ground truth
## True: p0 = 0.9, delta = 0, sigma = 1
## ====================================================================
ws <- locfdr(zex, plot = 0)

## MLE delta near 0
expect_true(abs(ws$fp0["mlest", "delta"]) < 0.15,
            info = "MLE delta should be near 0 for lfdrsim")

## MLE sigma near 1
expect_true(abs(ws$fp0["mlest", "sigma"] - 1) < 0.1,
            info = "MLE sigma should be near 1 for lfdrsim")

## MLE p0 near 0.9
expect_true(abs(ws$fp0["mlest", "p0"] - 0.9) < 0.05,
            info = "MLE p0 should be near 0.9 for lfdrsim")

## CM estimates also near truth
expect_true(abs(ws$fp0["cmest", "delta"]) < 0.15,
            info = "CM delta should be near 0 for lfdrsim")
expect_true(abs(ws$fp0["cmest", "sigma"] - 1) < 0.1,
            info = "CM sigma should be near 1 for lfdrsim")

## Non-null cases (mu != 0) should have lower average fdr than null cases
null_idx <- which(lfdrsim$mu == 0)
nonnull_idx <- which(lfdrsim$mu != 0)
expect_true(mean(ws$fdr[nonnull_idx]) < mean(ws$fdr[null_idx]),
            info = "Non-null cases should have lower average fdr")

## Right-side z.2 threshold should exist (non-null effects are positive)
expect_false(is.na(ws$z.2[2]),
             info = "Right z.2 threshold should exist for lfdrsim")

## Left-side z.2 may be NA since effects are one-sided
## (just check it's NA or negative)
expect_true(is.na(ws$z.2[1]) || ws$z.2[1] < 0)

## ====================================================================
## Custom breakpoints (bre as vector)
## ====================================================================
brk <- seq(-4, 4, length = 80)
wb <- locfdr(hivdata, bre = brk, plot = 0)
expect_equal(length(wb$fdr), length(hivdata))
expect_equal(nrow(wb$mat), length(brk) - 1)

## ====================================================================
## Custom pct0 as 2-vector
## ====================================================================
wp <- locfdr(hivdata, pct0 = c(0.2, 0.7), plot = 0)
expect_equal(length(wp$fdr), length(hivdata))
