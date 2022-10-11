library(tidyverse)
library(magick)
library(scanline)

nx <- 20
ny <- 10

m <- matrix(rep("white", nx*ny), nrow = ny)
m[, 3] <- "black"
m[, 6] <- "grey"
m[2, ] <- grey.colors(nx, start = 0, end = 1)
m[4, 12:18] <- "grey50"
m[5:8, 15] <- "grey10"

image_read(m) |> 
    scanline(
        vertical_res = ny,
        every = 1,
        shades = 200,
        background_scanline_thickness = 1,
        col_scanline = "seagreen1")+
    geom_raster(
        data =
            crossing(y = 1:ny, x = 1:nx) |>
            arrange(x, desc(y)) |>
            mutate(m = as.vector(m),
                   f = "f"),
        aes(x, y, fill = I(m)), alpha = 0.5)+
    geom_hline(yintercept = (0:9)+0.5, lty = 2)+
    geom_hline(yintercept = c(1, ny), col = "red")+
    geom_vline(xintercept = c(1, nx), col = "red")+
    scale_x_continuous(breaks = 0:nx)+
    scale_y_continuous(breaks = 0:ny)+
    theme_grey()+
    theme(panel.grid.minor = element_blank())


v <- 485
e <- 40
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
