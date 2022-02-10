#################################################################
# open xquartx first on your Mac, before even opening RStudio   #
# run analysis.R at least down to creating pc, before this file #
#################################################################

# set some options (which may not be necessary) and load rayshader
options(rgl.useNULL = FALSE)
options(cores = 2)

library(rayshader)

# these are standard 0-255 scales:
d |>
  summarise(across(c(red, green, blue), list(min = min, max = max)))

# so this is a simple normalization:
original <-
  d |>
  transmute(
    red = red / 255,
    blue = blue / 255,
    green = green / 255
  )

# and here's what it looks like:
p1 <-
  original |>
  ggplot(aes(red, green, color = blue)) +
  geom_point() +
  coord_fixed(xlim = c(0, 1)) +  # coord_fixed ensures 1:1 aspect ratio
  scale_color_gradient(low = "white", high = "blue", limits = c(0, 1))

plot_gg(
  p1,
  multicore = TRUE,
  width = 5,
  height = 5,
  scale = 250,
  windowsize = c(1400, 866),
  zoom = 0.55,
  phi = 30
)

# move it around, take snapshots with this line, and save to png
render_snapshot()

# get a tibble of the principal components
t <-
  pc$x |>
  as_tibble() |>
  rename(x = PC1, y = PC2, z = PC3)

# these mins and maxes look very different,
# because of how PCA works!
t |>
  summarise(across(c(x, y, z), list(min = min, max = max)))

# best to use the min and max from the first principal component
xmin <- min(t$x)
xmax <- max(t$x)

# here's the scaled version
rotated <-
  t |>
  mutate(across(.fns = \(x) (x - xmin) / (xmax - xmin)))

# and here's what it looks like
p2 <-
  rotated |>
  ggplot(aes(x, y, color = z)) +
  geom_point() +
  coord_fixed(xlim = c(0, 1)) +  # coord_fixed ensures 1:1 aspect ratio
  scale_color_gradient(low = "white", high = "blue", limits = c(0, 1))

plot_gg(
  p2,
  multicore = TRUE,
  width = 5,
  height = 5,
  scale = 250,
  windowsize = c(1400, 866),
  zoom = 0.55,
  phi = 30
)

# move it around, take snapshots with this line, and save to png
render_snapshot()
