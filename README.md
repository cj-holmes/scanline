
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scanline <img src="data-raw/scanline-hex/hex.png" align="right" height="160"/>

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

## Update

-   June 2023
    -   I have completely re-written `{scanline}` after stumbling upon
        [Ole Ivar Rudi’s CRT scanline
        hack](https://twitter.com/oleivarrudi/status/895665025251123201?s=20).
    -   **There are a tonne of breaking changes - nothing will work as
        before!**
    -   The return image is still a ggplot render, but the
        parametrisation is very different
    -   Please log any bugs you find!

## Intro

-   I have always loved the aesthetic feel of David Fincher’s Alien 3
    film. From the cavernous, brutal and liminal environments, to the
    desolate and isolated nature of the story. In fact, I have always
    really loved the aesthetic of the Alien films in general, and more
    recently the incredible Alien Isolation game.
-   At the start of Alien 3, several ‘retro-futuristic’ scanline
    portrait images are seen (shown below), and I was keen to see if I
    could recreate this scanline style for any given image with R.
-   This project has been on the back-burner for a long time, but the
    rough code I initially wrote years ago has now turned into this
    `{scanline}` package. This package is super niche and is just for
    fun.

![](man/figures/README-unnamed-chunk-2-1.png)<!-- -->

-   `{scanline}` can be installed from github

``` r
remotes::install_github('https://github.com/cj-holmes/scanline')
```

-   Add `{scanline}` to the search path

``` r
library(scanline)
```

## Example outputs

-   The default arguments try to replicate the overall feel of the
    original scanline images shown above. However, custom parameters can
    be chosen to significantly change the look of the output

### Ripley

``` r
i <- 'https://www.looper.com/img/gallery/why-alien-3-almost-never-got-released/intro-1632832833.jpg'
magick::image_read(i) |> magick::image_ggplot()
```

![](man/figures/README-unnamed-chunk-5-1.png)<!-- -->

``` r
scanline(i, n_scanlines = 50)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="75%" />

### Dillon

-   Apparently he likes R

``` r
i <- 
    'https://m.media-amazon.com/images/M/MV5BMTM0OTI2MTg0MV5BMl5BanBnXkFtZTcwNjg3ODEyMw@@._V1_.jpg' |> 
    magick::image_read() |> 
    magick::image_resize("x500")

magick::image_ggplot(i)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="50%" />

``` r
i |> 
    magick::image_extent(geometry = "x600" ,color = "black", gravity = "north") |> 
    magick::image_annotate("I like R", size = 80, color = "white", gravity = "south", font = "Alien3") |> 
    scanline(n_scanlines = 100)
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="75%" />

## Clemens

``` r
i <- 'https://i.pinimg.com/originals/35/3c/40/353c40acae809215af994c06ea10d86d.jpg'
magick::image_read(i) |> magick::image_ggplot()
```

![](man/figures/README-unnamed-chunk-9-1.png)<!-- -->

``` r
scanline(i)
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="75%" />

## Morse

``` r
i <- 'https://static.wikia.nocookie.net/alienanthology/images/3/3b/Alien_3_Danny_Webb1.jpg/revision/latest?cb=20210320141122'
magick::image_read(i) |> magick::image_ggplot()
```

![](man/figures/README-unnamed-chunk-11-1.png)<!-- -->

-   Noise can also be added to achieve a certain aesthetic

``` r
scanline(i, n_scanlines = 100, add_noise = TRUE)
```

<img src="man/figures/README-unnamed-chunk-12-1.png" width="75%" />

## GIFs

-   Gif from
    [here](https://garrettzecker.files.wordpress.com/2017/04/alien-1979.gif)

<img src="man/figures/README-unnamed-chunk-13-1.gif" width="75%" />

-   `scanline_gif()` is an experimental function for creation of gifs

``` r
scanline_gif('data-raw/alien-1979.gif', width = 762, height = 456, add_noise = TRUE)
```

<img src="man/figures/README-unnamed-chunk-14-1.gif" width="75%" />

## Charts

-   **Not recommended!!** - but you absolutely could make your plots
    look like they are being viewed on a terminal onboard the Nostromo!
    Using the `{magick}` graphics device to create an image of the plot
    which is then passed to `scanline()`

``` r
library(ggplot2)
#> Warning: package 'ggplot2' was built under R version 4.2.2
fig <- magick::image_device(1800, 1000, res = 450)

diamonds |> 
    ggplot() + 
    geom_density(aes(price, after_stat(scaled)), fill = "grey70")+
    stat_ecdf(aes(price))+
    theme_linedraw()+
    theme(panel.grid = element_blank())+
    labs(
        title = "Diamond price distribution",
        x = "Price",
        y = "Scaled density")

dev.off()
#> png 
#>   2

fig |> magick::image_negate() |> scanline(n_scanlines = 160, border_size = 0, frame_size = 0)
```

![](man/figures/README-unnamed-chunk-15-1.png)<!-- -->
