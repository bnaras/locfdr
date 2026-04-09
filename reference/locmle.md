# Maximum Likelihood Estimation for Null Distribution Parameters

Uses z-values in a specified interval to find maximum likelihood
estimates for the null distribution parameters p0, delta0, and sigma0.

## Usage

``` r
locmle(z, xlim, Jmle = 35, d = 0, s = 1, ep = 1/1e+05, sw = 0, Cov.in)
```

## Arguments

- z:

  Vector of summary statistics (z-values).

- xlim:

  Two-vector \`c(center, half-width)\` defining the interval
  \`\[center - half-width, center + half-width\]\` used for estimation.
  If missing, computed automatically from \`z\`.

- Jmle:

  Number of iterations for the MLE algorithm.

- d:

  Initial value for delta (null mean).

- s:

  Initial value for sigma (null standard deviation).

- ep:

  Convergence tolerance.

- sw:

  If 1, returns correlation matrix along with MLE.

- Cov.in:

  Optional list with components \`x\`, \`X\`, \`f\`, \`sw\` for
  covariance and influence function calculations.

## Value

If \`sw\` is not 1 and \`Cov.in\` is not supplied, a named vector of
length 6: \`del0\`, \`sig0\`, \`p0\`, \`sd.del0\`, \`sd.sig0\`,
\`sd.p0\`.

If \`sw=1\`, a list with \`mle\` (the estimates) and \`Cor\`
(correlation matrix).

If \`Cov.in\` is supplied, a list with \`mle\` and either \`Cov.lfdr\`,
\`pds.\`, or \`Ilfdr\` depending on \`Cov.in\$sw\`.
