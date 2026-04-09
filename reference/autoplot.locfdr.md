# Plot a locfdr Object with ggplot2

Creates a ggplot2 visualization of the local false discovery rate
estimation, showing the histogram of z-values with the fitted mixture
density and null subdensity overlay.

## Usage

``` r
autoplot.locfdr(object, ...)
```

## Arguments

- object:

  An object of class \`"locfdr"\`.

- ...:

  Additional arguments (ignored).

## Value

A \[ggplot2::ggplot\] object.
