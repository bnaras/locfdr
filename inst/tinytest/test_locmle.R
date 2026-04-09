## Tests for locmle()

library(locfdr)
locmle <- locfdr:::locmle

## -- hivdata MLE estimates --
data(hivdata)
z <- hivdata
N <- length(z)
b <- 4.3 * exp(-0.26 * log(N, 10))
med <- median(z)
sc <- diff(quantile(z)[c(2, 4)]) / (2 * qnorm(.75))

ml <- locmle(z, xlim = c(med, b * sc))

## Return structure
expect_equal(length(ml), 6)
expect_equal(names(ml), c("del0", "sig0", "p0", "sd.del0", "sd.sig0", "sd.p0"))

## Estimates (known from CRAN 1.1-8)
expect_equal(ml["del0"], c(del0 = -0.1116), tolerance = 0.01)
expect_equal(ml["sig0"], c(sig0 = 0.7612), tolerance = 0.01)
expect_equal(ml["p0"], c(p0 = 0.9399), tolerance = 0.01)

## SDs should be positive and small
expect_true(all(ml[4:6] > 0))
expect_true(all(ml[4:6] < 0.1))

## -- auto xlim (missing xlim) --
ml_auto <- locmle(z)
expect_equal(ml, ml_auto, tolerance = 1e-6)

## -- sw=1 returns correlation matrix --
ml1 <- locmle(z, xlim = c(med, b * sc), d = ml["del0"], s = ml["sig0"], sw = 1)
expect_true(is.list(ml1))
expect_true("mle" %in% names(ml1))
expect_true("Cor" %in% names(ml1))
expect_equal(dim(ml1$Cor), c(3, 3))
expect_equal(rownames(ml1$Cor), c("d", "s", "p0"))
## Correlation matrix: diagonal = 1, symmetric
expect_equal(diag(ml1$Cor), c(d = 1, s = 1, p0 = 1))
expect_equal(ml1$Cor, t(ml1$Cor))

## -- lfdrsim: statistical validation against known truth --
## True: p0 = 0.9, delta = 0, sigma = 1
data(lfdrsim)
zex <- lfdrsim[, "zex"]
ml_sim <- locmle(zex)

## MLE delta should be near 0 (within ~0.15 given sampling variability)
expect_true(abs(ml_sim["del0"]) < 0.15,
            info = "MLE delta estimate should be near 0 for lfdrsim")

## MLE sigma should be near 1 (within ~0.1)
expect_true(abs(ml_sim["sig0"] - 1) < 0.1,
            info = "MLE sigma estimate should be near 1 for lfdrsim")

## MLE p0 should be near 0.9 (within ~0.05)
expect_true(abs(ml_sim["p0"] - 0.9) < 0.05,
            info = "MLE p0 estimate should be near 0.9 for lfdrsim")
