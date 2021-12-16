library(tidyverse)  # install.packages("tidyverse")  # for everything
library(here)       # install.packages("here")       # for filenaming
library(janitor)    # install.packages("janitor")    # for pretty field names
library(glue)                                        # for string interpolation
library(psych)      # install.packages("psych")      # for PCA
library(paletteer)  # install.packages("paletteer")  # for pretty colors
library(conflicted) # install.packages("conflicted") # for namespace conflicts

# read the data in and transform it
d <- 
  here("data/laundry-input-data.csv") |>
  read_csv(show_col_types = F) |> 
  clean_names() |>
  separate(temp_trial, into = c("temp", "trial"), convert = T) |>
  pivot_longer(
    c(initial, starts_with("x")),
    names_to = "wash",
    names_prefix = "x",
    values_to = "hex_code",
    values_transform = list(hex_code = \(x) glue("#{x}"))
  ) |>
  mutate(
    wash = wash |> 
      fct_recode("0" = "initial") |> 
      as.character() |> 
      as.integer(),
    temp = temp |>
      str_replace("0$", "0°") |>
      fct_relevel("160°", "130°", "100°", "70°", "room", "40°") |>
      fct_recode("Room Temperature" = "room"),
    trial = glue("Trial {trial}")
  )

# convert the hex codes to RGB
d <-
  bind_cols(
    d,
    d |> pull(hex_code) |> col2rgb() |> t() |> as_tibble()
  )

# check the data for correlations
d |> 
  select(red, green, blue) |>
  pairs.panels(gap = 0, pch = 21)

# run a principal component analysis
pc <- 
  d |> 
  select(red, green, blue) |> 
  prcomp(center = T, scale = T)

# components are no longer correlated
pc$x |> pairs.panels(
  gap = 0,
  pch = 21
)

# how do the principal components relate to red, green, and blue?
print(pc)

# how much does each principal component explain of the color variance?
summary(pc)

# create an "intensity" score: the first principal component, scaled 0 to 10
intensities <- -pc$x[, "PC1"]
min_intensity <- min(intensities)
intensity_range <- max(intensities) - min(intensities)
d$intensity <- (intensities - min_intensity) / (intensity_range) * 10

# visualize the data
d |>
  ggplot() +
  aes(wash, intensity, color = trial) +
  geom_jitter(size = 4, width = 0.25) +
  facet_wrap(vars(temp)) +
  xlab("Number of Washes") +
  scale_y_continuous("Dye Intensity (0 to 10)", breaks = 0:5 * 2) +
  scale_color_paletteer_d("nationalparkcolors::Saguaro") +
  ggtitle("Dye intensity and durability increase with temperature") +
  theme(
    plot.title = element_text(size = 20),
    axis.title.x = element_text(size = 14, vjust = -1.25),
    axis.title.y = element_text(size = 14),
    axis.ticks = element_blank(),
    axis.text.x = element_text(size = 13),
    axis.text.y = element_text(size = 13, hjust = .75),
    strip.text = element_text(size = 14, vjust = 1.25),
    legend.text = element_text(size = 14),
    legend.key = element_blank(),
    legend.background = element_blank(),
    legend.title = element_blank(),
    legend.position = "bottom"
  )

ggsave(
  here("figures/results.png"),
  width = 12,
  height = 9,
  units = "in",
  dpi = 300
)

d |>
  mutate(
    temp = temp |> str_replace("°", " degrees"),
    intensity = intensity |> round(2)
  ) |>
  write_csv(here("data/laundry-output-data.csv"))
