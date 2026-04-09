#' Print a locfdr Object
#'
#' @param x An object of class `"locfdr"`.
#' @param ... Additional arguments (ignored).
#'
#' @return `x`, invisibly.
#' @export
print.locfdr <- function(x, ...) {
    nulltype_labels <- c("theoretical N(0,1)", "MLE", "central matching",
                         "split normal")
    nt <- x$nulltype + 1L
    nt_label <- if (nt >= 1 && nt <= 4) nulltype_labels[nt] else "unknown"

    row <- if (x$nulltype == 0) "thest" else "mlest"
    p0 <- x$fp0[row, "p0"]
    n_interesting <- sum(x$fdr < 0.2)

    cli::cli_h2("Local False Discovery Rate Estimation")
    cli::cli_text("{x$N} cases, null type: {nt_label}")
    cli::cli_text("Estimated p0 = {round(p0, 3)}")
    cli::cli_text("Cases with fdr < 0.2: {n_interesting}")
    if (!any(is.na(x$z.2))) {
        cli::cli_text("fdr < 0.2 outside [{round(x$z.2[1], 3)}, {round(x$z.2[2], 3)}]")
    } else if (!is.na(x$z.2[2])) {
        cli::cli_text("fdr < 0.2 for z > {round(x$z.2[2], 3)}")
    } else if (!is.na(x$z.2[1])) {
        cli::cli_text("fdr < 0.2 for z < {round(x$z.2[1], 3)}")
    }
    invisible(x)
}

#' Summarize a locfdr Object
#'
#' @param object An object of class `"locfdr"`.
#' @param ... Additional arguments (ignored).
#'
#' @return `object`, invisibly.
#' @export
summary.locfdr <- function(object, ...) {
    print.locfdr(object, ...)
    cli::cli_h3("Null parameter estimates (fp0)")
    print(object$fp0)
    cat("\n")
    cli::cli_h3("Expected FDR")
    print(round(object$Efdr, 4))
    invisible(object)
}

#' Tidy a locfdr Object
#'
#' Returns the null parameter estimates (fp0 matrix) in a long-form
#' tibble with columns `method`, `term`, `estimate`, and `std_error`.
#'
#' @param x An object of class `"locfdr"`.
#' @param ... Additional arguments (ignored).
#'
#' @return A [tibble::tibble] with columns:
#'   \describe{
#'     \item{method}{Estimation method: "theoretical", "mle", or "central_matching".}
#'     \item{term}{Parameter name: "delta", "sigma", or "p0"
#'       (plus "sigright" for nulltype 3).}
#'     \item{estimate}{Parameter estimate.}
#'     \item{std_error}{Standard error of the estimate.}
#'   }
#'
#' @importFrom generics tidy
#' @export
tidy.locfdr <- function(x, ...) {
    fp0 <- x$fp0
    est_rows <- c("thest", "mlest", "cmest")
    se_rows <- c("theSD", "mleSD", "cmeSD")
    method_labels <- c("theoretical", "mle", "central_matching")
    terms <- colnames(fp0)

    rows <- list()
    for (i in seq_along(est_rows)) {
        for (j in seq_along(terms)) {
            est <- fp0[est_rows[i], terms[j]]
            se <- fp0[se_rows[i], terms[j]]
            if (!is.na(est)) {
                rows[[length(rows) + 1L]] <- data.frame(
                    method = method_labels[i],
                    term = terms[j],
                    estimate = est,
                    std_error = se,
                    stringsAsFactors = FALSE
                )
            }
        }
    }
    out <- do.call(rbind, rows)
    rownames(out) <- NULL
    if (requireNamespace("tibble", quietly = TRUE)) {
        out <- tibble::as_tibble(out)
    }
    out
}

#' Glance at a locfdr Object
#'
#' Returns a one-row summary with key scalar statistics.
#'
#' @param x An object of class `"locfdr"`.
#' @param ... Additional arguments (ignored).
#'
#' @return A one-row [tibble::tibble] with columns:
#'   \describe{
#'     \item{n}{Number of cases.}
#'     \item{nulltype}{Null type used (0, 1, 2, or 3).}
#'     \item{p0}{Estimated proportion of null cases.}
#'     \item{delta}{Estimated null mean.}
#'     \item{sigma}{Estimated null standard deviation.}
#'     \item{efdr}{Expected false discovery rate for non-null cases.}
#'     \item{n_significant}{Number of cases with fdr < 0.2.}
#'   }
#'
#' @importFrom generics glance
#' @export
glance.locfdr <- function(x, ...) {
    row <- if (x$nulltype == 0) "thest" else "mlest"
    out <- data.frame(
        n = x$N,
        nulltype = x$nulltype,
        p0 = x$fp0[row, "p0"],
        delta = x$fp0[row, "delta"],
        sigma = x$fp0[row, if ("sigma" %in% colnames(x$fp0)) "sigma" else "sigleft"],
        efdr = x$Efdr["Efdr"],
        n_significant = sum(x$fdr < 0.2),
        stringsAsFactors = FALSE
    )
    rownames(out) <- NULL
    if (requireNamespace("tibble", quietly = TRUE)) {
        out <- tibble::as_tibble(out)
    }
    out
}

#' Augment a locfdr Object
#'
#' Returns a per-case tibble with the original z-values and their
#' estimated local false discovery rates.
#'
#' @param x An object of class `"locfdr"`.
#' @param ... Additional arguments (ignored).
#'
#' @return A [tibble::tibble] with columns:
#'   \describe{
#'     \item{z}{The original z-values (from the mat midpoints, interpolated
#'       back to the input).}
#'     \item{fdr}{The estimated local false discovery rate.}
#'   }
#'
#' @importFrom generics augment
#' @export
augment.locfdr <- function(x, ...) {
    out <- data.frame(
        fdr = x$fdr,
        stringsAsFactors = FALSE
    )
    if (requireNamespace("tibble", quietly = TRUE)) {
        out <- tibble::as_tibble(out)
    }
    out
}

#' Plot a locfdr Object with ggplot2
#'
#' Creates a ggplot2 visualization of the local false discovery rate
#' estimation, showing the histogram of z-values with the fitted mixture
#' density and null subdensity overlay.
#'
#' @param object An object of class `"locfdr"`.
#' @param ... Additional arguments (ignored).
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @export
autoplot.locfdr <- function(object, ...) {
    if (!requireNamespace("ggplot2", quietly = TRUE)) {
        cli::cli_abort("Package {.pkg ggplot2} is required for {.fn autoplot.locfdr}.")
    }

    mat <- as.data.frame(object$mat)
    row <- if (object$nulltype == 0) "thest" else "mlest"
    p0 <- object$fp0[row, "p0"]

    f0_col <- if (object$nulltype == 0) "f0theo" else "f0"
    mat$f0_scaled <- p0 * mat[[f0_col]]
    mat$nonnull <- pmax(mat$counts * (1 - mat$fdr), 0)

    p <- ggplot2::ggplot(mat, ggplot2::aes(x = x)) +
        ggplot2::geom_col(ggplot2::aes(y = counts),
                          fill = "grey80", color = "grey60", width = diff(mat$x[1:2])) +
        ggplot2::geom_col(ggplot2::aes(y = nonnull),
                          fill = "magenta", alpha = 0.5, width = diff(mat$x[1:2])) +
        ggplot2::geom_line(ggplot2::aes(y = f), color = "green3", linewidth = 1.2) +
        ggplot2::geom_line(ggplot2::aes(y = f0_scaled),
                           color = "blue", linewidth = 1, linetype = "dashed") +
        ggplot2::labs(x = "z", y = "Frequency",
                      title = "Local False Discovery Rate") +
        ggplot2::theme_minimal()

    ## Add triangles for z.2 thresholds
    if (!is.na(object$z.2[1])) {
        p <- p + ggplot2::annotate("point", x = object$z.2[1], y = 0,
                                   shape = 24, size = 3, fill = "yellow", color = "red")
    }
    if (!is.na(object$z.2[2])) {
        p <- p + ggplot2::annotate("point", x = object$z.2[2], y = 0,
                                   shape = 24, size = 3, fill = "yellow", color = "red")
    }
    p
}
