# Trying to pick colours that match the Alien 3 images
library(magick)
library(scanline)
library(tidyverse)

img_q <- image_read('data-raw/bishop.png') |> image_quantize(32, dither = FALSE)

cols_df <-
    img_q |>
    image_raster() |>
    as_tibble() |>
    count(col) |>
    mutate(col2rgb(col) |> rgb2hsv() |> t() |> as_tibble()) |>
    arrange(v)

scales::show_col(cols_df$col)


i <- 'https://alienseries.files.wordpress.com/2012/11/alien_ripley_ref4.jpg'
patchwork::wrap_plots(
    img_q |> image_ggplot(),
    scanline(i, col_scanline = c("black", "darkslategrey", "darkseagreen3", "paleturquoise"), col_background = "black"),
    ncol = 2
    )

scales::show_col(c("black", "darkslategrey", "darkseagreen3", "paleturquoise"))
