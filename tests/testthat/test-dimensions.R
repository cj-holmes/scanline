# Tests to confirm that the output image has the correct number of vertical pixes

# Test image
i <- 'https://www.looper.com/img/gallery/why-alien-3-almost-never-got-released/intro-1632832833.jpg'


# 1 -----------------------------------------------------------------------
# Define params
n_scanlines <- 23
border_size <- 1
frame_size <- 10 # percent
opacities <- c(1,0,0,1)
l <- length(opacities)

# Create plot from debug mode to have access to data (non-debug mode uses annotation_raster() so cant get data)
p <- 
    scanline(
        i,
        n_scanlines = n_scanlines,
        border_size = border_size,
        frame_size = frame_size,
        opacities = opacities,
        debug = T)

# Number of pixels in y
ny <- 
    p$data |> 
    tibble::as_tibble() |> 
    dplyr::filter(type == "Output") |>
    dplyr::pull(y) |> 
    max()

# Number of pixels there SHOULD be in y
o <-
    (n_scanlines*l) + # number of pixels from scanlines
    (ifelse(border_size > 0, 2*(border_size + 1)*l, 0)) + # two lots of border size plus the extra one pixel outside (or 0 if no border)
    (round((((n_scanlines*l)/100)*frame_size))*2) # plus two lots of frame_size % of number of vertical pixels (not including border)

test_that("there are the correct number of pixles vertically", {
    expect_equal(ny, o)
})



# 2 -----------------------------------------------------------------------
# Define params
n_scanlines <- 75
border_size <- 4
frame_size <- 0 # percent
opacities <- c(1,0,0,0,0,1)
l <- length(opacities)

# Create plot from debug mode to have access to data (non-debug mode uses annotation_raster() so cant get data)
p <- 
    scanline(
        i,
        n_scanlines = n_scanlines,
        border_size = border_size,
        frame_size = frame_size,
        opacities = opacities,
        debug = T)

# Number of pixels in y
ny <- 
    p$data |> 
    tibble::as_tibble() |> 
    dplyr::filter(type == "Output") |>
    dplyr::pull(y) |> 
    max()

# Number of pixels there SHOULD be in y
o <-
    (n_scanlines*l) + # number of pixels from scanlines
    (ifelse(border_size > 0, 2*(border_size + 1)*l, 0)) + # two lots of border size plus the extra one pixel outside (or 0 if no border)
    (round((((n_scanlines*l)/100)*frame_size))*2) # plus two lots of frame_size % of number of vertical pixels (not including border)

test_that("there are the correct number of pixles vertically", {
    expect_equal(ny, o)
})



# 3 -----------------------------------------------------------------------

# Define params
n_scanlines <- 86
border_size <- 0
frame_size <- 100 # percent
opacities <- c(1,1)
l <- length(opacities)

# Create plot from debug mode to have access to data (non-debug mode uses annotation_raster() so cant get data)
p <- 
    scanline(
        i,
        n_scanlines = n_scanlines,
        border_size = border_size,
        frame_size = frame_size,
        opacities = opacities,
        debug = T,
        horizontal_filter = "Spline",
        vertical_filter = "Spline",
        add_noise = TRUE)

# Number of pixels in y
ny <- 
    p$data |> 
    tibble::as_tibble() |> 
    dplyr::filter(type == "Output") |>
    dplyr::pull(y) |> 
    max()

# Number of pixels there SHOULD be in y
o <-
    (n_scanlines*l) + # number of pixels from scanlines
    (ifelse(border_size > 0, 2*(border_size + 1)*l, 0)) + # two lots of border size plus the extra one pixel outside (or 0 if no border)
    (round((((n_scanlines*l)/100)*frame_size))*2) # plus two lots of frame_size % of number of vertical pixels (not including border)

test_that("there are the correct number of pixles vertically", {
    expect_equal(ny, o)
})





# 4 -----------------------------------------------------------------------

# Define params
n_scanlines <- 86
border_size <- 0
frame_size <- 0 # percent
opacities <- c(1,1)
l <- length(opacities)

# Create plot from debug mode to have access to data (non-debug mode uses annotation_raster() so cant get data)
p <- 
    scanline(
        i,
        n_scanlines = n_scanlines,
        border_size = border_size,
        frame_size = frame_size,
        opacities = opacities,
        debug = T,
        horizontal_filter = "Spline",
        vertical_filter = "Spline",
        add_noise = TRUE)

# Number of pixels in y
ny <- 
    p$data |> 
    tibble::as_tibble() |> 
    dplyr::filter(type == "Output") |>
    dplyr::pull(y) |> 
    max()

# Number of pixels there SHOULD be in y
o <-
    (n_scanlines*l) + # number of pixels from scanlines
    (ifelse(border_size > 0, 2*(border_size + 1)*l, 0)) + # two lots of border size plus the extra one pixel outside (or 0 if no border)
    (round((((n_scanlines*l)/100)*frame_size))*2) # plus two lots of frame_size % of number of vertical pixels (not including border)

test_that("there are the correct number of pixles vertically", {
    expect_equal(ny, o)
})
