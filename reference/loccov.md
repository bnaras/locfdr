# Covariance Calculations for Local FDR

Computes influence functions and covariance matrices for local false
discovery rate estimates under the MLE null.

## Usage

``` r
loccov(N, N0, p0, d, s, x, X, f, JV, Y, i0, H, h, sw)
```

## Arguments

- N:

  Total number of cases.

- N0:

  Number of cases in the estimation interval.

- p0:

  Estimated proportion of null cases.

- d:

  Estimated null mean (delta).

- s:

  Estimated null standard deviation (sigma).

- x:

  Vector of bin midpoints.

- X:

  Design matrix for the density fit.

- f:

  Fitted density values at bin midpoints.

- JV:

  Jacobian-variance product from MLE.

- Y:

  Two-vector of sufficient statistics from the MLE interval.

- i0:

  Indices of bins in the central matching region.

- H:

  Vector of truncated normal moments.

- h:

  Derivative terms from truncated normal.

- sw:

  Switch: 2 returns parameter derivatives with respect to bin counts; 3
  returns influence function of log(fdr); otherwise returns covariance
  matrix of log(fdr).

## Value

Depends on \`sw\`: derivative matrix (sw=2), influence function matrix
(sw=3), or covariance matrix (otherwise).
