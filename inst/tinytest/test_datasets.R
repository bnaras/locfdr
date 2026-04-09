## Tests for dataset integrity

library(locfdr)

## -- hivdata --
data(hivdata)

expect_true(is.numeric(hivdata))
expect_equal(length(hivdata), 7680)
expect_true(all(is.finite(hivdata)))
## z-values should be roughly centered around 0
expect_true(abs(mean(hivdata)) < 0.5)

## -- lfdrsim --
data(lfdrsim)

expect_true(is.data.frame(lfdrsim))
expect_equal(nrow(lfdrsim), 2000)
expect_equal(ncol(lfdrsim), 2)
expect_true("mu" %in% names(lfdrsim))
expect_true("zex" %in% names(lfdrsim))
expect_true(all(is.finite(lfdrsim$mu)))
expect_true(all(is.finite(lfdrsim$zex)))

## Known composition: 1800 null (mu=0), 200 non-null (mu!=0)
expect_equal(sum(lfdrsim$mu == 0), 1800)
expect_equal(sum(lfdrsim$mu != 0), 200)
## Non-null mu values drawn from N(3,1) — should be positive on average
expect_true(mean(lfdrsim$mu[lfdrsim$mu != 0]) > 1)
