## Tests for S3 class, print, summary, tidy, glance, augment, autoplot

library(locfdr)
data(hivdata)
data(lfdrsim)
zex <- lfdrsim[, "zex"]

w <- locfdr(hivdata, plot = 0)

## ====================================================================
## S3 class
## ====================================================================
expect_true(inherits(w, "locfdr"))
expect_true(inherits(w, "list"))
expect_equal(class(w), c("locfdr", "list"))

## New elements
expect_equal(w$nulltype, 1)
expect_equal(w$N, length(hivdata))

## $ and [[ still work (backward compat)
expect_equal(w$fdr, w[["fdr"]])
expect_true(is.matrix(w$fp0))

## ====================================================================
## print.locfdr — cli writes to stderr; capture with type="message"
## ====================================================================
out <- capture.output(print(w), type = "message")
expect_true(length(out) > 0)
expect_true(any(grepl("7680", out)))  # N cases

## ====================================================================
## summary.locfdr
## ====================================================================
out_s <- capture.output(summary(w), type = "message")
expect_true(length(out_s) > length(out))  # summary is longer than print

## ====================================================================
## tidy.locfdr
## ====================================================================
td <- tidy(w)
expect_true(is.data.frame(td))
expect_true(all(c("method", "term", "estimate", "std_error") %in% names(td)))
expect_true("mle" %in% td$method)
expect_true("theoretical" %in% td$method)
expect_true("central_matching" %in% td$method)
expect_true("delta" %in% td$term)
expect_true("sigma" %in% td$term)
expect_true("p0" %in% td$term)
## Values should match fp0 matrix
mle_p0 <- td$estimate[td$method == "mle" & td$term == "p0"]
expect_equal(mle_p0, w$fp0["mlest", "p0"], tolerance = 1e-10)

## ====================================================================
## glance.locfdr
## ====================================================================
gl <- glance(w)
expect_true(is.data.frame(gl))
expect_equal(nrow(gl), 1)
expect_true(all(c("n", "nulltype", "p0", "delta", "sigma", "efdr", "n_significant") %in% names(gl)))
expect_equal(gl$n, length(hivdata))
expect_equal(gl$nulltype, 1)
expect_equal(gl$p0, w$fp0["mlest", "p0"], tolerance = 1e-10)

## ====================================================================
## augment.locfdr
## ====================================================================
au <- augment(w)
expect_true(is.data.frame(au))
expect_equal(nrow(au), length(hivdata))
expect_true("fdr" %in% names(au))
expect_equal(au$fdr, w$fdr)

## ====================================================================
## autoplot.locfdr (requires ggplot2)
## ====================================================================
if (requireNamespace("ggplot2", quietly = TRUE)) {
    p <- ggplot2::autoplot(w)
    expect_true(inherits(p, "ggplot"))
    ## Also callable directly
    p2 <- autoplot.locfdr(w)
    expect_true(inherits(p2, "ggplot"))
}

## ====================================================================
## nulltype=0 preserves class
## ====================================================================
w0 <- locfdr(hivdata, nulltype = 0, plot = 0)
expect_true(inherits(w0, "locfdr"))
expect_equal(w0$nulltype, 0)

## glance uses theoretical null for nulltype=0
gl0 <- glance(w0)
expect_equal(gl0$p0, w0$fp0["thest", "p0"], tolerance = 1e-10)

## ====================================================================
## nulltype=3 (split normal) tidy has sigright column
## ====================================================================
w3 <- suppressWarnings(locfdr(hivdata, nulltype = 3, plot = 0))
td3 <- tidy(w3)
expect_true("sigright" %in% td3$term)

## ====================================================================
## sw=2 and sw=3 do NOT return locfdr class (different return types)
## ====================================================================
w_sw2 <- locfdr(hivdata, plot = 0, sw = 2)
expect_false(inherits(w_sw2, "locfdr"))

w_sw3 <- locfdr(hivdata, plot = 0, sw = 3)
expect_true(is.matrix(w_sw3))

## ====================================================================
## Backward compat: code that indexed by $ still works
## ====================================================================
ws <- locfdr(zex, plot = 0)
fdr_vals <- ws$fdr
fp0_mat <- ws$fp0
expect_true(is.numeric(fdr_vals))
expect_true(is.matrix(fp0_mat))
expect_equal(fp0_mat["mlest", "p0"], ws$fp0["mlest", "p0"])
