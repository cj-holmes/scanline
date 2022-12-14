% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scanline.R
\name{scanline}
\alias{scanline}
\title{Convert an image to a retro-futuristic scanline image}
\usage{
scanline(
  image,
  vertical_res = 300,
  shades = 256,
  every = 6,
  background_scanline_thickness = 0.95,
  foreground_scanline_thickness = 0.5,
  col_background = "black",
  col_scanline = c("black", "darkslategrey", "darkseagreen2", "paleturquoise"),
  col_background_scanline_factor = 0.5,
  border_size = 0.1
)
}
\arguments{
\item{image}{a magick image or image file path/URL}

\item{vertical_res}{the image is resized to have a vertical dimension of \code{vertical_res} pixels before the scanlines are processed (default = 300)}

\item{shades}{preferred number of grey shades in image.
The actual number of colors in the image may be less than this value, but never more (default = 256)}

\item{every}{the increment between selected scanlines above and below the vertical center scanline of the resized image (default = 6).
Smaller numbers produce more scanlines.}

\item{background_scanline_thickness}{thickness of the background scanline (larger is thicker).
A value of 1 will make the background scanlines touch at the brightest colour shade (default = 0.95)}

\item{foreground_scanline_thickness}{thickness of the foreground scanline colour as a proportion of the background scanline thickness
A value of 1 will make the foreground scanline the same thickness as the background scanline (default = 0.5)}

\item{col_background}{colour for background of image (default = "grey10")}

\item{col_scanline}{vector of colours for foreground scanline}

\item{col_background_scanline_factor}{factor by which the foreground scanline colour brightness is reduced to make the
the background scanline colours (default = 0.5)}

\item{border_size}{image border size as proportion of \code{vertical_res} (default = 0.1)}
}
\value{
a ggplot2 object
}
\description{
Inspired by the aesthetics of the Alien films.
Give an image that old school computer terminal scanline feel.

This is just for fun \strong{and is experimental}. Images may not be rendered correctly and detail will certainly be missing!
}
\details{
Image processing is handled by the {magick} package. Images are resized using \code{magick::image_resize()}
}
