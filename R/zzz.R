# Re-export generics
#' @importFrom generics tidy
#' @export
generics::tidy

#' @importFrom generics glance
#' @export
generics::glance

#' @importFrom generics augment
#' @export
generics::augment

# Suppress R CMD check NOTE for ggplot2 aes() variables
utils::globalVariables(c("x", "counts", "f", "f0_scaled", "nonnull"))

# Register autoplot.locfdr method when ggplot2 is available
.onLoad <- function(libname, pkgname) {
    if (requireNamespace("ggplot2", quietly = TRUE)) {
        registerS3method("autoplot", "locfdr", autoplot.locfdr,
                         envir = asNamespace("ggplot2"))
    }
}
