
# Science Fair Dye Temps

My daughter's project involved dying fabrics at various temperatures.
The hypothesis was that the dye would take better and have better staying power.
She dyed cloths at 6 temperatures (3 trials each),
washed each load 4 times, and measured RGB colors at each point.

She was pretty bummed the night before it was due to realize
that she had no single way to measure the color variability.
No matter how she operationalized color values,
her results seemed pretty counter-intuitive.

I realized that if you have a 3D color space,
but all you really want is the distance from points A to B in that space,
then it's a simple case of dimensionality reduction,
and principle components analysis would do fine.
It might be overkill, and just using a different colorspace might be fine,
but PCA isn't hard to do!

It turned out the first component accounted
for more than 98% of the color variability.
So I called that component "dye intensity," scaled it elegantly,
and went from there.

We enjoyed using `ggplot2` of course,
and also Emil Hvitfeldt's `paletteer` package for colors.
Special thanks to R-bloggers for [this post on PCA][pca]
for making it really easy!

[pca]: https://www.r-bloggers.com/2021/05/principal-component-analysis-pca-in-r/
