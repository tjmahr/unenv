<!--- Timestamp to trigger book rebuilds: 2025-07-08 14:30:12.75301 --->



## OneNote archive

<small>Source: <code>2021-11-01-archival-notes.Rmd</code></small>

Here is a bunch of pre-2021 items from OneNote and elsewhere.

#### Added variable plots (2019-05-14)

  - Let `m = y ~ x1 + ...` be the full regression model
  - Let `m_y1 = y ~ ...` (all of the predictors except x1)
  - Let `m_x1 = x1 ~ ...` (regress x1 on those same predictors)
  - Let `m_partial = resid(m_y1) ~ resid(m_x1)`
  - The plot of `resid(m_x1)` versus `resid(m_y1)` is the added variable plot.
    It shows "X1 | others)" and "y | others"
  - Residuals in the final `m_partial` model will be same as residuals from full
    model `m`
  - Coefficient of `x1` in final `m_partial` model will be same as coefficient
    from full model `m`.

AV plots by hand and by `car::avPlot()`


``` r
par(mar = c(4, 4, 1, 1))

m <- lm(mpg ~ wt + hp + am, mtcars)
m_y1 <- lm(mpg ~ hp + am, mtcars)
m_x1 <- lm(wt ~ hp + am, mtcars)
m_partial <- lm(resid(m_y1) ~ resid(m_x1))

library(patchwork)
p1 <- wrap_elements(
  full = ~ plot(resid(m_x1), resid(m_y1))
) 
p2 <- wrap_elements(
  full = ~ car::avPlot(m, "wt")
)

p1 + p2
```

<figure>
  <img src="assets/figure/2021-11-01-archival-notes/av-plots-1.png" width="80%" style="margin-left: auto; margin-right: auto; display: block;width:80%;"/>
  <figcaption></figcaption>
</figure>

``` r
all.equal(residuals(m_partial), residuals(m))
#> [1] TRUE

coef(m)["wt"]
#>        wt 
#> -2.878575
coef(m_partial)[2]
#> resid(m_x1) 
#>   -2.878575
```

What about interactions?

#### R 3.6.0 released! (2019-04-26)

Highlights for me

  - New `sample()` implementation
  - New function `asplit()` allow splitting an array or matrix by its margins.
  - Functions mentioned I didn't know about: `lengths()`, `trimws()`,
    `extendrange()`, `convertColor()`, `strwidth()`


### Standardized gamma distributions (2019-04-18)

A gamma times a positive non-zero constant is still a gamma. Paul and I
used this fact to standardize results from different models onto a
single "z" scale. Here's a made-up example.

Simulate some gamma-distributed data.


``` r
library(patchwork)
set.seed(20211122)
par(mar = c(4, 4, 1, 1))

y <- rgamma(n = 100, shape = 20)
y2 <- rgamma(n = 100, shape = 200)
wrap_elements(full = ~ hist(y)) + 
  wrap_elements(full = ~ hist(y2))
```

<figure>
  <img src="assets/figure/2021-11-01-archival-notes/gamma-hists-1.png" width="80%" style="margin-left: auto; margin-right: auto; display: block;width:80%;"/>
  <figcaption></figcaption>
</figure>

Fit a GLM


``` r
get_shape <- function(model) { 
  1 / summary(model)[["dispersion"]]
}

m <- glm(y ~ 1, Gamma(link = "identity"))
m2 <- glm(y2 ~ 1, Gamma(link = "identity"))

get_shape(m)
#> [1] 21.09197
get_shape(m2)
#> [1] 178.6259
```

The two `z` values have similar scales.


``` r
par(mar = c(4, 4, 1, 1))
r <- residuals(m)
r2 <- residuals(m2)

z <- y / fitted(m)
z2 <- y2 / fitted(m2)

wrap_elements(
  full = ~ car::qqPlot(y, distribution = "gamma", shape = get_shape(m))
) + 
  wrap_elements(
    full = ~ car::qqPlot(y2, distribution = "gamma", shape = get_shape(m2))
  )
```

<figure>
  <img src="assets/figure/2021-11-01-archival-notes/z-gams-qqs-1.png" width="80%" style="margin-left: auto; margin-right: auto; display: block;width:80%;"/>
  <figcaption></figcaption>
</figure>

``` r

wrap_elements(
  full = ~ car::qqPlot(
    z, 
    distribution = "gamma", 
    shape = get_shape(m), 
    scale = 1 / get_shape(m))
) + 
  wrap_elements(
    full = ~ car::qqPlot(
      z2, 
      distribution = "gamma", 
      shape = get_shape(m2), 
      scale = 1 / get_shape(m2))
  )
```

<figure>
  <img src="assets/figure/2021-11-01-archival-notes/z-gams-qqs-2.png" width="80%" style="margin-left: auto; margin-right: auto; display: block;width:80%;"/>
  <figcaption></figcaption>
</figure>


### Jaccard similarity (2019-03-14)

[Jaccard similarity](https://en.wikipedia.org/wiki/Jaccard_index) is the
size of intersection of A and B divided by size of union of A and B.

Suppose a listener types of a few sentences twice. These are probes for
intra-listener transcription reliability. Suppose that one of these
sentences is 6 words long. If a listener typed 8 unique words for the
two sentences, and 4 of them appear in both sentences, then they have
Jaccard similarity of 4 / 8 = 0.5. Then we take the weighted mean of the
Jaccard scores. We use the sentence length as the weight, so this
sentence would have a weight of 6.

Asked twitter if they knew any IRR tutorials

  - <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4913118/>
  - <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3402032/>

### Phylogenetic regression (2019-02-26)

Listened to bits of phylogenetic regression lecture.

  - You can model a simple linear regression as a multivariate
    regression.
  - Make the covariance matrix the identity matrix and multiple it by
    the error term sigma.
  - In this formulation, you can swap out the identity correlation
    matrix with something estimated using a correlation/distance matrix.
    If the distances were age, you can have units with similar ages have
    correlated errors. Now you have a gaussian process regression.
    
    
### multicomp (2019-02-25)

  - We are using the multcomp package and `glht()` to test hypotheses
    from fitted models. Never used this package before. Something to
    learn.
  - `glht()` will compute a group difference (like asymptote of SMI-LCT
    vs SMI-LCI) from a fitted model and give you a standard error, *z*
    statistic and *p* value for that difference.
  - I can get very similar results by sampling the multivariate normal
    distribution of the model coefficients/variance-covariance matrix
    and computing the group differences from the samples, using the
    standard deviation of the samples to get the standard error.


### Rolling list of bookmarks (2019-10-01)

dtool: Manage scientific data <https://dtool.readthedocs.io/en/latest/>

A very first introduction to Hamiltonian Monte Carlo
<https://blogs.rstudio.com/tensorflow/posts/2019-10-03-intro-to-hmc/>

Some things you maybe didn't know about linear regression
<https://ryxcommar.com/2019/09/06/some-things-you-maybe-didnt-know-about-linear-regression/>

dbx database tools for R <https://github.com/ankane/dbx>

Dash for R
<https://medium.com/@plotlygraphs/announcing-dash-for-r-82dce99bae13>

How to interpret F-statistic
<https://stats.stackexchange.com/questions/12398/how-to-interpret-f-and-p-value-in-anova>

The origin of statistically significant
<https://www.johndcook.com/blog/2008/11/17/origin-of-statistically-significant/>

tidymv: Tidy Model Visualisation for Generalised Additive Models
<https://cran.r-project.org/web/packages/tidymv/index.html>

Step-by-step examples of building publication-quality figures in ggplot2
<https://github.com/clauswilke/practical_ggplot2>

From data to viz <https://www.data-to-viz.com/>

Shapley model explanation <https://github.com/slundberg/shap>

JavaScript versus Data Science
<https://software-tools-in-javascript.github.io/js-vs-ds/en/>

Penalized likelihood estimation
<https://modernstatisticalworkflow.blogspot.com/2017/11/what-is-likelihood-anyway.html>

UTF-8 everywhere <https://utf8everywhere.org/>

Unicode programming
<https://begriffs.com/posts/2019-05-23-unicode-icu.html>

R package to simulate colorblindness
<https://github.com/clauswilke/colorblindr>

Data version control <https://dvc.org/>

Email tips
<https://twitter.com/LucyStats/status/1131285346455625734?s=20>

colorcet library (python) <https://colorcet.pyviz.org/>

HCL wizard <http://hclwizard.org/hclwizard/>

Coloring for colorblindness. Has 8 palettes of color pairs
<https://davidmathlogic.com/colorblind/>

5 things to consider when creating your CSS style guide by
@malimirkeccita
<https://medium.com/p/5-things-to-consider-when-creating-your-css-style-guide-7b85fa70039d>

Tesseract OCR engine for R
<https://cran.r-project.org/web/packages/tesseract/vignettes/intro.html>

Lua filters for rmarkdown documents <https://github.com/crsh/rmdfiltr>

An NIH Rmd template <https://github.com/tgerke/nih-rmd-template>

Commit message guide
<https://github.com/RomuloOliveira/commit-messages-guide>

Linear regression diagnostic plots in ggplot2
<https://github.com/yeukyul/lindia>

A graphical introduction to dynamic programming
<https://avikdas.com/2019/04/15/a-graphical-introduction-to-dynamic-programming.html>

Why software projects take longer than you think
<https://erikbern.com/2019/04/15/why-software-projects-take-longer-than-you-think-a-statistical-model.html>

Automatic statistical reporting <https://github.com/easystats/report>

Multilevel models and CSD
<https://pubs.asha.org/doi/pdf/10.1044/2018_JSLHR-S-18-0075>

Map of cognitive science
<http://www.riedlanna.com/cognitivesciencemap.html>

An additive Gaussian process regression model for interpretable
non-parametric analysis of longitudinal data
<https://www.nature.com/articles/s41467-019-09785-8>

Common statistical tests are linear models (or: how to teach stats)
<https://lindeloev.github.io/tests-as-linear/>

Monte Carlo sampling does not "explore" the posterior
<https://statmodeling.stat.columbia.edu/2019/03/25/mcmc-does-not-explore-posterior/>

How to develop the five skills that will make you a great analyst
<https://mode.com/blog/how-to-develop-the-five-soft-skills-that-will-make-you-a-great-analyst>

Confidence intervals are a ring toss
<https://twitter.com/epiellie/status/1073385427317465089>

Mathematics for Machine Learning <https://mml-book.github.io/>

20 Tips for Senior Thesis Writers
<http://hwpi.harvard.edu/files/complit/files/twenty_tips_for_senior_thesis_writers_revised_august_2012.pdf>

Comparing common analysis strategies for repeated measures data
<http://eshinjolly.com/2019/02/18/rep_measures/>

Cosine similarity, Pearson correlation, and OLS coefficients
<https://brenocon.com/blog/2012/03/cosine-similarity-pearson-correlation-and-ols-coefficients/>

qqplotr is a nice package for plotting qqplots
<https://cran.r-project.org/web/packages/qqplotr/index.html>

Multidimensional item response theory
<https://github.com/philchalmers/mirt>

Aki's tutorials/materials on model selection
<https://github.com/avehtari/modelselection_tutorial>

An Introverts Guide to Conferences
<https://laderast.github.io/2018/05/17/a-introvert-s-survival-guide-to-conferences/>

Best practice guidance for linear mixed-effects models in psychological
science <https://psyarxiv.com/h3duq/>

Viewing matrices and probabilities as graphs
<https://www.math3ma.com/blog/matrices-probability-graphs>

Cross-validation for hierarchical models
<https://avehtari.github.io/modelselection/rats_kcv.html>

All of Aki's tutorials <https://avehtari.github.io/modelselection/>

User-friendly p values
<http://thenode.biologists.com/user-friendly-p-values/research/>

Iodide is a Javascript notebook <https://alpha.iodide.io/>

Interesting question about what do when transformation changes the
"test" of a highest-density interval.
<https://discourse.mc-stan.org/t/exponentiation-or-transformation-of-point-estimates/7848>

Some ways to rethink statistical rules
<https://allendowney.blogspot.com/2015/12/many-rules-of-statistics-are-wrong.html>

Toward a Principled Bayesian Workflow
<https://betanalpha.github.io/assets/case_studies/principled_bayesian_workflow.html>

Stumbled across an article on mixed models and effect sizes:
<https://www.journalofcognition.org/articles/10.5334/joc.10/>


#### I had these quotes in the old notes

> In so complex a thing as human nature, we must consider, it is hard to find
> rules without exception. --- George Eliot

> If any one faculty of our nature may be called more wonderful than the rest, I
> do think it is memory...The memory is sometimes so retentive, so serviceable,
> so obedient; at others, so bewildered and so weak. We are, to be sure, a
> miracle every way; but our powers of recollecting and of forgetting do seem
> peculiarly past finding out. --- Jane Austen

