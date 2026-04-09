# HIV Gene Expression Data

The data comprises 7680 z-values, each relating to a two-sample t-test.
The test compares gene expression values for 4 HIV patients with values
for 4 normal subjects; the t-score \`T\[i\]\` for gene i has been
transformed to a normal scale, \`z\[i\] = qnorm(pt(T\[i\], df=6))\`, so
that the \`z\[i\]\`'s theoretically would have a standard \\N(0,1)\\
distribution under the null hypothesis.

## Usage

``` r
hivdata
```

## Format

A numeric vector containing 7680 z-values.

## References

van't Wout, et al., Cellular gene expression upon human immunodeficiency
virus type 1 infection of CD4+-T-Cell lines, *Journal of Virology* 77,
1392-1402.

## Examples

``` r
data(hivdata)
hist(hivdata, breaks = 100)
```
