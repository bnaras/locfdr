# Glance at a locfdr Object

Returns a one-row summary with key scalar statistics.

## Usage

``` r
# S3 method for class 'locfdr'
glance(x, ...)
```

## Arguments

- x:

  An object of class \`"locfdr"\`.

- ...:

  Additional arguments (ignored).

## Value

A one-row \[tibble::tibble\] with columns:

- n:

  Number of cases.

- nulltype:

  Null type used (0, 1, 2, or 3).

- p0:

  Estimated proportion of null cases.

- delta:

  Estimated null mean.

- sigma:

  Estimated null standard deviation.

- efdr:

  Expected false discovery rate for non-null cases.

- n_significant:

  Number of cases with fdr \< 0.2.
