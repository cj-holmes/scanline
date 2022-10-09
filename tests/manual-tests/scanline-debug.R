library(tidyverse)
library(magick)
library(scanline)

n <- 10
m <- matrix(rep("white", 100), nrow = n)
m[, 3] <- "black"
m[, 6] <- "grey"
m[2, ] <- grey.colors(10, start = 0, end = 1)

image_read(m) |>
    scanline(
        vertical_res = n,
        every = 1,
        shades = 200,
        background_scanline_thickness = 1,
        col_scanline = "seagreen1")+
    geom_raster(
        data =
            crossing(y = 1:n, x = 1:n) |>
            arrange(x, desc(y)) |>
            mutate(m = as.vector(m),
                   f = "f"),
        aes(x, y, fill = I(m)), alpha = 0.5)+
    geom_hline(yintercept = (0:9)+0.5, lty = 2)+
    scale_x_continuous(breaks = 0:n)+
    scale_y_continuous(breaks = 0:n)+
    theme_grey()+
    theme(panel.grid.minor = element_blank())


v <- 485
e <- 50
test_image <-
    image_read('https://i0.wp.com/testprint.net/wp-content/uploads/2022/05/Testprint-testpage-sec-BW.jpg?resize=362%2C485&ssl=1') |>
    image_resize(paste0("x", v))

scanline(
    test_image,
    vertical_res = v,
    every = e,
    background_scanline_thickness = 0.75)+
    geom_raster(
        data =
            test_image |> image_flip() |> image_raster(),
        aes(x, y, fill = I(col)), alpha = 0.5)+
    geom_hline(yintercept = unique(
        c(seq(from = floor(v/2), to = 1, by = -e),
          seq(from = floor(v/2), to = v, by = e))), col = "red", size = 1)+
    geom_hline(yintercept = floor(v/2), col = "blue", size = 1)+
    theme_grey()
