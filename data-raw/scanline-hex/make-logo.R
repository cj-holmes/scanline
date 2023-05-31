scanline::scanline(
    'data-raw/scanline-hex/g34022.png', 
    add_noise = FALSE, 
    border_size = 0,
    frame_size = 0,
    n_scanlines = 20)

ggplot2::ggsave('data-raw/scanline-hex/text.pdf', width = 8, height = 3)
