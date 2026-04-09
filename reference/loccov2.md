# Covariance Calculations for Central Matching Null

Computes covariance and influence functions for local false discovery
rate estimates under the central matching or theoretical null.

## Usage

``` r
loccov2(X, X0, i0, f, ests, N)
```

## Arguments

- X:

  Design matrix for the mixture density fit.

- X0:

  Design matrix for the null density fit.

- i0:

  Indices of bins in the central matching region.

- f:

  Fitted mixture density values at bin midpoints.

- ests:

  Three-vector of null parameter estimates \`c(delta, sigma, p0)\`.

- N:

  Total number of cases.

## Value

A list with components:

- Ilfdr:

  Influence function matrix for log(fdr).

- pds.:

  Parameter derivative matrix (3 x K).

- stdev:

  Standard deviations of parameter estimates.

- Cov:

  Covariance matrix of log(fdr) estimates.
