## Tests for loccov() and loccov2()

library(locfdr)
loccov2 <- locfdr:::loccov2

## Build inputs from hivdata (same as locfdr internals)
data(hivdata)
zz <- hivdata
N <- length(zz)
breaks <- seq(min(zz), max(zz), length = 120)
x <- (breaks[-1] + breaks[-length(breaks)]) / 2
K <- length(x)  # 119

zh <- hist(zz, breaks = breaks, plot = FALSE)
y <- zh$counts
X <- cbind(1, splines::ns(x, df = 7))
f <- glm(y ~ splines::ns(x, df = 7), poisson)$fit

imax <- which.max(log(f))
xmax <- x[imax]
lo0 <- quantile(zz, 0.25)
hi0 <- quantile(zz, 0.75)
i0 <- which(x > lo0 & x < hi0)
X0 <- cbind(1, x - xmax, (x - xmax)^2)

## Use approximate mlest values for ests
ests <- c(-0.1116, 0.7612, 0.9399)

## -- loccov2 basic output structure --
out <- loccov2(X, X0, i0, f, ests, N)

expect_true(is.list(out))
expect_equal(sort(names(out)), sort(c("Ilfdr", "pds.", "stdev", "Cov")))

## Ilfdr: K x K matrix
expect_equal(dim(out$Ilfdr), c(K, K))

## pds.: 3 x K matrix with correct row names
expect_equal(dim(out$pds.), c(3, K))
expect_equal(rownames(out$pds.), c("p", "d", "s"))

## stdev: length 3, positive
expect_equal(length(out$stdev), 3)
expect_true(all(out$stdev > 0))

## Cov: K x K, symmetric
expect_equal(dim(out$Cov), c(K, K))
expect_true(isSymmetric(out$Cov))

## -- loccov2 with theoretical null (ncol(X0)==1) --
X0_theo <- matrix(1, K, 1)
ests_theo <- c(0, 1, 0.94)

out_theo <- loccov2(X, X0_theo, i0, f, ests_theo, N)
expect_equal(dim(out_theo$pds.), c(3, K))
expect_equal(dim(out_theo$Cov), c(K, K))
expect_true(isSymmetric(out_theo$Cov))

## -- loccov via locfdr sw=2 --
## Tests the full integration path through locfdr -> locmle -> loccov
w2 <- locfdr(hivdata, plot = 0, sw = 2)
expect_true(is.list(w2))
expect_equal(sort(names(w2)), sort(c("pds", "x", "f", "pds.", "stdev")))
expect_equal(names(w2$pds), c("p0", "delhat", "sighat"))
expect_equal(names(w2$stdev), c("sdp0", "sddelhat", "sdsighat"))
expect_equal(dim(w2$pds.), c(K, 3))
expect_true(all(w2$stdev > 0))

## -- loccov via locfdr sw=3 (influence function matrix) --
w3 <- locfdr(hivdata, plot = 0, sw = 3)
expect_true(is.matrix(w3))
expect_equal(dim(w3), c(K, K))
