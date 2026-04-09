# Augment a locfdr Object

Returns a per-case tibble with the original z-values and their estimated
local false discovery rates.

## Usage

``` r
# S3 method for class 'locfdr'
augment(x, ...)
```

## Arguments

- x:

  An object of class \`"locfdr"\`.

- ...:

  Additional arguments (ignored).

## Value

A \[tibble::tibble\] with columns:

- z:

  The original z-values (from the mat midpoints, interpolated back to
  the input).

- fdr:

  The estimated local false discovery rate.
