# Simulated Data for locfdr

A simulated dataset that involves 2000 "genes", each of which has
yielded a test statistic "zex", with \\zex\[i\] \sim N(mu\[i\], 1)\\
(independently for \\i = 1, 2, \ldots, 2000\\). Of the 2000 \\\mu_i\\
values, 1800 (90%) are zero (null cases) and the remaining 200 (10%) are
drawn from a \\N(3, 1)\\ distribution (non-null cases).

## Usage

``` r
lfdrsim
```

## Format

A data frame with 2000 rows and 2 columns:

- mu:

  the true score for each gene

- zex:

  the observed z-value

## Examples

``` r
data(lfdrsim)
hist(lfdrsim$zex, breaks = 80)
```
