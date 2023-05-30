#' Create scanline animation from a GIF
#' 
#' Inspired by the aesthetics of the Alien films. 
#'     Give an image that old school computer terminal scanline feel. 
#'     This is just for fun **and is experimental**. Images may not be rendered correctly and detail will certainly be missing!
#'
#' @param gif path to GIF file
#' @param width output width (default = 600)
#' @param height output height (default = 600)
#' @param scale multiplicative scale factor applied to width and height (default = 1)
#' @param fps frames per second (passed to \code{magick::image_animate()}) (default = 10)
#' @param delay delay after each frame, in 1/100 seconds. Must be length 1, or number of frames. 
#'     If specified, then fps is ignored.passed to \code{magick::image_animate()}.
#' @param background_col background colour for graphics device (default = "black")
#' @param ... named arguments passed on to \code{scanline::scanline()}
#'
#' @export
scanline_gif <- 
    function(
        gif,
        width = 600,
        height = 600,
        scale = 1,
        fps = 10,
        delay = NULL,
        background_col = "black",
        ...){
        
        message("This function is buggy, slow and experimental at best!")
        
        # Read image and modulate brightness ---------------------------------------
        if('magick-image' %in% class(gif)){x <- gif} else {x <- magick::image_read(gif)}

        # Process GIF -------------------------------------------------------------
        message(paste0("Processing GIF (", length(x), " frames)"))
        l <- list()
        for (i in seq_along(x)) l[[i]] <- magick::image_flatten(x[1:i])
        
        # Run ggboy ---------------------------------------------------------------
        message("Running scanline on all GIF frames")
        fig <- 
            magick::image_graph(
                width = width * scale, 
                height = height * scale, 
                bg = background_col, 
                clip = FALSE)
        
        purrr::map(
            .x = as.list(magick::image_join(l)), 
            .f = function(x) print(scanline(x, ...)), 
            .progress = TRUE)
        
        dev.off()
        
        # Animate GIF -------------------------------------------------------------
        message("Animating GIF")
        magick::image_animate(fig, fps = fps, delay = delay, optimize = TRUE)
    }