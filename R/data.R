#' HIV Gene Expression Data
#'
#' The data comprises 7680 z-values, each relating to a two-sample
#' t-test.  The test compares gene expression values for 4 HIV patients
#' with values for 4 normal subjects; the t-score `T[i]` for gene i has
#' been transformed to a normal scale, `z[i] = qnorm(pt(T[i], df=6))`,
#' so that the `z[i]`'s theoretically would have a standard \eqn{N(0,1)}
#' distribution under the null hypothesis.
#'
#' @format A numeric vector containing 7680 z-values.
#'
#' @references van't Wout, et al., Cellular gene expression upon human
#'   immunodeficiency virus type 1 infection of CD4+-T-Cell lines,
#'   \emph{Journal of Virology} 77, 1392-1402.
#'
#' @examples
#' data(hivdata)
#' hist(hivdata, breaks = 100)
"hivdata"

#' Simulated Data for locfdr
#'
#' A simulated dataset that involves 2000 "genes", each of which has
#' yielded a test statistic "zex", with \eqn{zex[i] \sim N(mu[i], 1)}
#' (independently for \eqn{i = 1, 2, \ldots, 2000}).  Of the 2000
#' \eqn{\mu_i} values, 1800 (90\%) are zero (null cases) and the
#' remaining 200 (10\%) are drawn from a \eqn{N(3, 1)} distribution
#' (non-null cases).
#'
#' @format A data frame with 2000 rows and 2 columns:
#' \describe{
#'   \item{mu}{the true score for each gene}
#'   \item{zex}{the observed z-value}
#' }
#'
#' @examples
#' data(lfdrsim)
#' hist(lfdrsim$zex, breaks = 80)
"lfdrsim"
