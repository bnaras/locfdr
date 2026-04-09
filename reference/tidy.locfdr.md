# Tidy a locfdr Object

Returns the null parameter estimates (fp0 matrix) in a long-form tibble
with columns \`method\`, \`term\`, \`estimate\`, and \`std_error\`.

## Usage

``` r
# S3 method for class 'locfdr'
tidy(x, ...)
```

## Arguments

- x:

  An object of class \`"locfdr"\`.

- ...:

  Additional arguments (ignored).

## Value

A \[tibble::tibble\] with columns:

- method:

  Estimation method: "theoretical", "mle", or "central_matching".

- term:

  Parameter name: "delta", "sigma", or "p0" (plus "sigright" for
  nulltype 3).

- estimate:

  Parameter estimate.

- std_error:

  Standard error of the estimate.
