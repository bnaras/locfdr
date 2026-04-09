## Tests for API patterns used by reverse dependencies
##
## These tests verify the exact access patterns used by the 8 revdep
## packages. Any breakage here means a revdep will fail.

library(locfdr)
data(hivdata)
data(lfdrsim)
zex <- lfdrsim[, "zex"]

## ====================================================================
## clusterExperiment pattern:
##   locfdr::locfdr(tstats, plot=0)
##   $fp0["mlest", "p0"]
## ====================================================================
w <- locfdr(hivdata, plot = 0)

p0_mlest <- w$fp0["mlest", "p0"]
expect_true(is.numeric(p0_mlest))
expect_equal(length(p0_mlest), 1)
expect_true(p0_mlest > 0 & p0_mlest < 1)

## ====================================================================
## EpiDISH / LPRelevance pattern:
##   locfdr(z, bre=bre, df=df, pct=0, pct0=pct0, nulltype=1, type=0, plot=0, sw=0)
##   $fp0[3,1]  (mlest delta, numeric indexing)
##   $fp0[3,2]  (mlest sigma, numeric indexing)
##   $fdr
## ====================================================================
w_epi <- locfdr(hivdata, bre = 120, df = 15, pct = 0, pct0 = 0.25,
                nulltype = 1, type = 0, plot = 0, sw = 0)

mu_numeric <- w_epi$fp0[3, 1]
sd_numeric <- w_epi$fp0[3, 2]
expect_true(is.numeric(mu_numeric))
expect_true(is.numeric(sd_numeric))
expect_equal(length(mu_numeric), 1)
expect_equal(length(sd_numeric), 1)

## Verify numeric and named indexing are consistent
expect_equal(mu_numeric, w_epi$fp0["mlest", "delta"])
expect_equal(sd_numeric, w_epi$fp0["mlest", "sigma"])

## $fdr is a numeric vector same length as input
expect_true(is.numeric(w_epi$fdr))
expect_equal(length(w_epi$fdr), length(hivdata))

## ====================================================================
## IHWpaper pattern:
##   locfdr::locfdr(qnorm(pv), nulltype=0, plot=0)$fdr
## ====================================================================
set.seed(42)
pv <- runif(1000)
w_ihw <- locfdr(qnorm(pv), nulltype = 0, plot = 0)
expect_true(is.numeric(w_ihw$fdr))
expect_equal(length(w_ihw$fdr), 1000)
expect_true(all(w_ihw$fdr >= 0 & w_ihw$fdr <= 1))

## ====================================================================
## GIGSEA pattern:
##   locfdr(c(zscore, -zscore), plot=0)$fdr
## ====================================================================
set.seed(42)
zscore <- rnorm(500)
w_gig <- locfdr(c(zscore, -zscore), plot = 0)
expect_true(is.numeric(w_gig$fdr))
expect_equal(length(w_gig$fdr), 1000)

## ====================================================================
## medScan/LPRelevance pattern:
##   locfdr(z, nulltype=1, plot=0)
##   $fp0[3,2]  (sigma)
##   $fdr
## ====================================================================
w_med <- locfdr(hivdata, nulltype = 1, plot = 0)
sigma_val <- w_med$fp0[3, 2]
expect_true(is.numeric(sigma_val))
expect_true(sigma_val > 0)

## ====================================================================
## LPRelevance also uses:
##   locfdr(z, bre=200, df=10, nulltype=1, plot=0)
## ====================================================================
w_lp <- locfdr(hivdata, bre = 200, df = 10, nulltype = 1, plot = 0)
expect_equal(length(w_lp$fdr), length(hivdata))
expect_equal(nrow(w_lp$mat), 199)  # bre-1 rows

## ====================================================================
## medScan DACT (commented out but documents intended usage):
##   locfdr::locfdr(Z_a, nulltype=0)$fp0[5,3]  (cmest p0)
## ====================================================================
cmest_p0 <- w$fp0[5, 3]
expect_true(is.numeric(cmest_p0))
expect_equal(cmest_p0, w$fp0["cmest", "p0"])

## ====================================================================
## satuRn pattern:
##   locfdr(zz=zvalues_mid, bre=120, df=7, pct=0, pct0=1/4,
##          nulltype=1, type=0, plot=1, sw=0)
##   (used for plotting only; satuRn handles internals itself)
## ====================================================================
pdf(file = NULL)
w_sat <- locfdr(zz = hivdata, bre = 120, df = 7, pct = 0, pct0 = 1/4,
                nulltype = 1, type = 0, plot = 1, sw = 0)
dev.off()
expect_true(is.list(w_sat))
expect_true("fdr" %in% names(w_sat))

## ====================================================================
## fcfdr pattern:
##   locfdr(c(zp_ind, -zp_ind), bre=..., mlests=c(...), plot=1, df=...)
##   Uses custom breakpoints and mlests
## ====================================================================
set.seed(42)
zp <- rnorm(500)
ml_est <- locfdr:::locmle(c(zp, -zp))
pdf(file = NULL)
w_fcfdr <- locfdr(c(zp, -zp), mlests = c(ml_est[1], ml_est[2]),
                  plot = 1, df = 10)
dev.off()
expect_true(is.list(w_fcfdr))
expect_equal(length(w_fcfdr$fdr), 1000)
