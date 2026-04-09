## Generate the locfdr hex sticker logo
##
## The logo shows the core concept of local false discovery rates:
## - f(z): the mixture density (dark, integrates to 1)
## - p0 f0(z): the null sub-density (teal, integrates to p0 < 1)
## - The shaded gap between them is the non-null signal
## - A vertical bar at z=2.2 decomposes into null (teal) and
##   non-null (coral) portions — this IS the local FDR at that z
## - The formula fdr(z) = p0 f0(z) / f(z) ties it together
##
## Requires: ggplot2, hexSticker, showtext, sysfonts

library(ggplot2)
library(hexSticker)
library(showtext)

font_add_google("EB Garamond", "garamond")
showtext_auto()

## Synthetic curves for clear visual separation
x <- seq(-4, 6, length = 500)
f0 <- dnorm(x, 0, 1)
f1 <- dnorm(x, 2.5, 0.8)
p0_val <- 0.70
f_mix <- p0_val * f0 + (1 - p0_val) * f1  # mixture PDF (integrates to 1)
f0_sub <- p0_val * f0                       # null sub-density (integrates to p0)

df <- data.frame(x = x, f = f_mix, f0s = f0_sub)

## Proportion bar at z = 2.2
z_slice <- 2.2
idx <- which.min(abs(x - z_slice))
f_at <- f_mix[idx]
f0s_at <- f0_sub[idx]

col_f   <- "#1A2530"   # dark blue-charcoal for f(z)
col_f0s <- "#4A90A4"   # teal for p0 f0(z)
peak_y  <- max(f_mix)

p <- ggplot(df, aes(x = x)) +
    ## Shaded gap between curves — the non-null signal
    geom_ribbon(aes(ymin = f0s, ymax = f),
                fill = "#B56B5C", alpha = 0.20) +
    ## Two curves
    geom_line(aes(y = f0s), color = col_f0s, linewidth = 0.25) +
    geom_line(aes(y = f), color = col_f, linewidth = 0.28) +
    ## Proportion bar: null portion (teal) + non-null portion (coral)
    geom_segment(x = z_slice, xend = z_slice, y = 0, yend = f0s_at,
                 color = col_f0s, linewidth = 0.35, alpha = 0.6) +
    geom_segment(x = z_slice, xend = z_slice, y = f0s_at, yend = f_at,
                 color = "#B56B5C", linewidth = 0.35, alpha = 0.7) +
    annotate("point", x = z_slice, y = f0s_at,
             color = col_f, size = 0.3) +
    ## Label: p0 f0(z) — below the teal curve
    annotate("text", x = 0.25, y = 0.04,
             label = "p\u2080 f\u2080(z)",
             family = "garamond", fontface = "bold.italic",
             color = col_f0s, size = 5.5) +
    ## Label: f(z) — on the right tail
    annotate("text", x = 4.5, y = 0.08,
             label = "f(z)",
             family = "garamond", fontface = "bold.italic",
             color = col_f, size = 5.5) +
    ## Formula in the open right-top area
    annotate("text", x = 5.2, y = peak_y - 0.02,
             label = "fdr(z) = p\u2080 f\u2080(z) / f(z)",
             family = "garamond", fontface = "bold.italic",
             color = "#4A3728", size = 5.0) +
    coord_cartesian(xlim = c(-5.5, 8.5), ylim = c(-0.03, 0.40)) +
    theme_void() +
    theme_transparent()

sticker(p,
        package = "locfdr",
        p_size = 22, p_color = "#2C3E50", p_y = 1.50,
        p_family = "sans",
        s_x = 1.0, s_y = 0.90, s_width = 1.5, s_height = 1.25,
        h_fill = "#FEFEFE", h_color = "#A8A098", h_size = 1.2,
        filename = "man/figures/logo.png",
        dpi = 300)

message("Logo saved to man/figures/logo.png")
