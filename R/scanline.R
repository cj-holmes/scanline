#' Convert an image to a retro-futuristic scanline image
#' 
#' Inspired by the aesthetics of the Alien films. 
#'     Give an image that old school computer terminal scanline feel. 
#'     This is just for fun **and is experimental**. Images may not be rendered correctly and detail will certainly be missing!
#'
#' @param image a magick image object or image file path/URL
#' @param n_scanlines the number of scanlines in the image (default = 60)
#' @param scanline_col character vector of colours from dark to light (reverse order for negative image)
#' @param opacities vector of opacities. The image will be expanded \code{length(opacities)} times in x and y (default = c(1, 0.6, 0, 0, 0.6, 1))
#' @param normalise normalise the image with \code{magick::image_normalise()} before applying scanlines (default = FALSE)
#' @param border_size size of border around image in units of scanlines (default = 1)
#' @param border_intensity intensity of border (from 0 (dark) to 255 (light)) (default = 255)
#' @param frame_size size of frame around image as a percentage of the number of \code{n_scanlines} (default = 10)
#' @param vertical_filter resize filter for vertical expansion from \code{magick::filter_types()} (default = "Point")
#' @param horizontal_filter resize filter for horizontal expansion from \code{magick::filter_types()} (default = "Triangle")
#' @param composite_operator blending operator for scanlines from \code{magick::compose_types()} (default = "HardLight")
#' @param debug return an output that contains debugging details (best run with small values for \code{n_scanlines}) (default = FALSE)
#' @param add_noise add noise to image (default = FALSE)
#' @param noise_type \code{magick::noise_types()} value to add to image if \code{add_noise = TRUE} (default = "gaussian")
#' @param print_details print information during processing (default = FALSE)
#' @details Image processing is handled by the {magick} package
#' @export
scanline <-
    function(
        image,
        n_scanlines = 60,
        scanline_col = c("black", "darkslategrey", "darkseagreen2", "paleturquoise"),
        opacities = c(1, 0.6, 0, 0, 0.6, 1),
        normalise = FALSE,
        border_size = 1,
        border_intensity = 255,
        frame_size = 10,
        vertical_filter = "Point",
        horizontal_filter = "Triangle",
        composite_operator = "HardLight",
        debug = FALSE,
        print_details = FALSE,
        add_noise = FALSE,
        noise_type = "gaussian"){

        # Read image file
        if('magick-image' %in% class(image)){i <- image} else {i <- magick::image_read(image)}
        
        # Parse the opacities and create the scanline vector using black
        l <- length(opacities)
        sl <- sapply(opacities, function(x) rgb(0,0,0, alpha = 255*x, maxColorValue = 255))
        
        # Resize image to correct vertical resolution (number of scanlines)        
        i <- 
            i |> 
            magick::image_resize(paste0("x", n_scanlines)) |> 
            magick::image_convert(colorspace = "gray")
        
        # Normalise image
        if(normalise) i <- i |> magick::image_normalize()

        # If inner border is > 0, add the inner border and assign an outer border value of 1  
        # If no inner border, assign outer border value of 0
        if(border_size != 0){
            i <-
                magick::image_border(
                    i,
                    col = scales::col_numeric(palette = c("black", "white"), domain = c(0, 255), na.color = "white")(border_intensity), 
                    geometry = paste0(border_size, "x", border_size))
            
            outside_border <- 1
        } else {
            outside_border <- 0    
        }
        
        # Compute width and height
        info <- magick::image_info(i)
        w <- info$width
        h <- info$height
        
        # Map the colour to the greyscale image
        i <- 
            i |> 
            magick::image_raster() |> 
            dplyr::mutate(
                col2rgb(col) |> 
                    t() |> 
                    dplyr::as_tibble() |> 
                    dplyr::transmute(x, y, i = red)) |> 
            # dplyr::mutate(col = scales::col_numeric(palette = col_scanline, domain = c(min(i), max(i)))(i)) |>
            dplyr::mutate(
                col = 
                    scales::col_numeric(
                        palette = scanline_col, 
                        domain = c(0, 255))(i)) |>
            dplyr::pull(col) |> 
            matrix(nrow = h, ncol = w, byrow = TRUE) |> 
            magick::image_read() |> 
            magick::image_border(col = "black", geometry = paste0(outside_border, "x", outside_border))
        
        if(add_noise){i <- magick::image_noise(i, noisetype = noise_type)}
        
        # Recompute image width and height using the outside border value
        w <- w + (2*outside_border)
        h <- h + (2*outside_border)
        
        # Resize image with separate vertical and horizontal filters
        i <- 
            i |>
            magick::image_resize(geometry = paste0('x', h*l, '!'), filter = vertical_filter) |>
            magick::image_resize(geometry = paste0(w*l, 'x!'), filter = horizontal_filter)
        
        # Create scanline image to blend
        sl_filter <-
            rep(sl, length.out = h*l) |> 
            rep(each = w*l) |> 
            matrix(ncol = w*l, nrow = h*l, byrow = TRUE) |> 
            magick::image_read()
        
        # Create composite image and add border - ggplot
        frame_px <- round(((n_scanlines*l)/100)*frame_size)
        
        i <- 
            magick::image_composite(
                image = i,
                composite_image = sl_filter, 
                operator = composite_operator) |> 
            magick::image_border(
                color = "black", 
                geometry = paste0(frame_px, "x", frame_px))
        
        # Recompute width and height
        info <- magick::image_info(i)
        w <- info$width
        h <- info$height
        ar <- info$height/info$width
        
        if(print_details) cat(paste0("Output width: ", w, "\nOutput height: ", h, "\nOutput aspect ratio (height/width): ", ar))
        

        # Output ---------------------------------------------------------------
        if(debug){
            
            rast <-
                i |> 
                magick::image_flip() |> 
                magick::image_raster() |> 
                dplyr::mutate(type = "Output") |> 
                dplyr::bind_rows(
                    sl_filter |> 
                        magick::image_border(
                            color = "black", 
                            geometry = paste0(frame_px, "x", frame_px)) |> 
                        magick::image_flip() |> 
                        magick::image_raster() |> 
                        dplyr::mutate(type = "Output filter"))
            
            out <-
                ggplot2::ggplot(rast) +
                ggplot2::geom_raster(ggplot2::aes(x = x, y = y, fill = I(col))) +
                ggplot2::geom_vline(
                    xintercept = 
                        seq(
                            from = frame_px+0.5, 
                            to = info$width-frame_px+0.5,
                            by = l), 
                    col = 2)+
                ggplot2::geom_hline(
                    yintercept = 
                        seq(
                            from = frame_px+0.5, 
                            to = info$height-frame_px+0.5,
                            by = l), 
                    col = 2) +
                ggplot2::coord_equal(expand = FALSE) +
                ggplot2::facet_wrap(~type, ncol = ifelse(ar > 1, 2, 1)) +
                ggplot2::theme(legend.position = "") +
                ggplot2::labs(
                    caption = paste0(
                        "Height = ", h,
                        "\nWidth = ", w,
                        "\nH/W = " , h/w,
                        "\nHorizontal filter = ", horizontal_filter,
                        "\nVertical filter = ", vertical_filter))
        } else {
            
            out <- 
                ggplot2::ggplot(
                    data = data.frame(x = 0, y = 0),
                    mapping = ggplot2::aes_string('x', 'y')) +
                ggplot2::geom_blank() +
                ggplot2::theme_void() +
                ggplot2::coord_fixed(expand = FALSE, xlim = c(0, info$width), ylim = c(0, info$height)) +
                ggplot2::annotation_raster(i, 0, info$width, info$height, 0, interpolate = FALSE)
        }
        
        out
    }

