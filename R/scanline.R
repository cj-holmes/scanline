#' Convert an image to a retro-futuristic scanline image
#' 
#' Inspired by the aesthetics of the Alien films. 
#'     Give an image that old school computer terminal scanline feel.
#'     
#' This is just for fun **and is experimental**. Images may not be rendered correctly and detail will certainly be missing!
#'
#' @param image a magick image or image file path/URL
#' @param vertical_res the image is resized to have a vertical dimension of \code{vertical_res} pixels before the scanlines are processed (default = 300)
#' @param shades preferred number of grey shades in image.
#'     The actual number of colors in the image may be less than this value, but never more (default = 256)
#' @param every the increment between selected scanlines above and below the vertical center scanline of the resized image (default = 6). 
#'     Smaller numbers produce more scanlines.
#' @param background_scanline_thickness thickness of the background scanline (larger is thicker).
#'     A value of 1 will make the background scanlines touch at the brightest colour shade (default = 0.95)
#' @param foreground_scanline_thickness thickness of the foreground scanline colour as a proportion of the background scanline thickness
#'     A value of 1 will make the foreground scanline the same thickness as the background scanline (default = 0.5)
#' @param col_background colour for background of image (default = "grey10")
#' @param col_scanline vector of colours for foreground scanline
#' @param col_background_scanline_factor factor by which the foreground scanline colour brightness is reduced to make the
#'     the background scanline colours (default = 0.5)
#' @param border_size image border size as proportion of \code{vertical_res} (default = 0.1)
#' 
#' @details Image processing is handled by the {magick} package. Images are resized using \code{magick::image_resize()}
#' @return a ggplot2 object
#' @export
scanline <-
    function(
        image,
        vertical_res = 300,
        shades = 256,
        every = 6,
        background_scanline_thickness = 0.95,
        foreground_scanline_thickness = 0.5,
        col_background = "black",
        col_scanline = c("black", "darkslategrey", "darkseagreen2", "paleturquoise"),
        # col_scanline = c("grey10", "darkslategrey", "darkseagreen3", "darkslategray2"),
        col_background_scanline_factor = 0.5,
        border_size = 0.1){

        # Read image file
        if('magick-image' %in% class(image)){
            i <- image
        } else {
            i <- magick::image_read(image)
        }

        # Create a darker shade of the fg colours:
        # Convert fg colours to HSV
        col_fg_hsv <- col_scanline |> col2rgb() |> rgb2hsv()
        # Decrease lightness of each one by col_background_scanline_factor and return hex colour
        col_fg_dark <-
            apply(
                X = col_fg_hsv,
                MARGIN = 2,
                FUN = function(x) hsv(x[1], x[2], x[3]*col_background_scanline_factor))

        # Create the two colour ramps for the foreground and darker background
        ramp_fg <- colorRamp(col_scanline, space = "Lab")
        ramp_fg_dark <- colorRamp(col_fg_dark, space = "Lab")

        # Process image, convert to scaled matrix
        # This matrix is a flipped (top to bottom) version of the image
        # So matrix row 1 (the top/first row as you look in the console) is the
        # bottom row of the image as you would look at it
        m <-
            i |>
            magick::image_resize(paste0("x", vertical_res)) |>
            magick::image_convert(colorspace = "gray") |>
            magick::image_quantize(shades, dither = FALSE, treedepth = 0) |>
            magick::image_flip() |>
            magick::image_raster() |>
            dplyr::mutate(
                col2rgb(col) |> 
                    t() |> 
                    tibble::as_tibble()) |>
            dplyr::pull(red) |>
            scales::rescale(to = c(0, (every/2)*background_scanline_thickness)) |>
            matrix(nrow = vertical_res, byrow = TRUE)

        # Compute scan line positions from middle row of image
        # Vertical midpoint
        mp <- floor(vertical_res/2)
        
        # Scanline y values
        sl <-
            unique(
                c(seq(from = mp, to = 1, by = -every),
                  seq(from = mp, to = vertical_res, by = every)))

        # Compute the rectangle start/stop and thickness values
        #   Start/stop from rle() across the scanline
        #   Thickness from the scaled values of the matrix
        # Each row of dataframe is a rectangle
        #    Assign colour for each rectangle in two columns in the dataframe
        #   This means I don't need to fill by two separate scales but can fill by identity instead
        df <-
            purrr::map_dfr(
                .x = sl,
                .f = function(x){

                    rl <- m[x,] |> rle()

                    dplyr::tibble(
                        xleft = c(0.5, cumsum(rl$lengths)+0.5),
                        xright = dplyr::lead(xleft),
                        sl = x,
                        thickness = c(rl$values, NA)) |>
                        # remove the final x right which is always NA (from the lead())
                        dplyr::filter(!is.na(xright)) |>
                        dplyr::mutate(
                            ybottom = sl - thickness,
                            ytop = sl + thickness,
                            ybottom2 = sl - thickness*foreground_scanline_thickness,
                            ytop2 = sl + thickness*foreground_scanline_thickness)}) |>
            dplyr::mutate(
                fill_col = ramp_fg(scales::rescale(thickness)) |> rgb(maxColorValue = 255),
                fill_col_dark = ramp_fg_dark(scales::rescale(thickness)) |> rgb(maxColorValue = 255))
        
        # Plot scanline image
        ggplot2::ggplot()+
            # Plot darker color scan line first (thicker with default settings)
            ggplot2::geom_rect(
                data = df,
                ggplot2::aes(
                    xmin = xleft,
                    xmax = xright,
                    ymin = ybottom,
                    ymax = ytop,
                    fill = I(fill_col_dark)),
                col = NA)+
            # Plot lighter (original) color scan line on top of darker one
            ggplot2::geom_rect(
                data = df,
                ggplot2::aes(
                    xmin = xleft,
                    xmax = xright,
                    ymin = ybottom2,
                    ymax = ytop2,
                    fill = I(fill_col)),
                col = NA)+
            ggplot2::coord_equal(expand = FALSE)+
            ggplot2::theme_void()+
            ggplot2::theme(panel.background = ggplot2::element_rect(colour = NA, fill = col_background))+
            ggplot2::expand_limits(
                y = c(0.5 - (vertical_res*border_size), vertical_res + 0.5 + (vertical_res*border_size)),
                x = c(0.5 - (vertical_res*border_size), ncol(m) + 0.5 + (vertical_res*border_size)))
    }
