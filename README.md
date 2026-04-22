
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EGprocess

<!-- badges: start -->

<!-- badges: end -->

The R package EGprocess facilitates simple and standard creation of
escapement goal data reporting.

## Package Installation

You can install the development version of EGprocess from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("adamreimer/EGprocess")
```

## Overview

EGprocess provides a standardized set of R functions to be used by ADF&G
staff during the escapement goal review process. This package is
designed to help staff from both fisheries divisions and all regions
produce consistent, high-quality figures and tables to be used as part
of the Board of Fisheries (BOF) meetings. Salmon escapement goals in
Alaska are reviewed every three years, aligned with the BOF’s regulatory
meeting cycle. EGprocess supports this work by creating standardized
outputs for spawner-recruit analyses, posterior summaries, expected
yield curves, optimal yield profiles (OYP), and comparisons among
updated and historical escapement goal findings. EGprocess can be used
directly in R, or as a downstream companion to the Pacific Salmon SR
Escapement Goal Analysis Shiny Application (“Hamachan Shiny App”), which
produces the input data structures used by the package.

### Why Standardize Figures?

Standardizing figure structure, captions, and themes reduces the
cognitive load on reviewers, allowing them to focus on interpretation
instead of formatting differences across regions or divisions. EGprocess
ensures: - Consistent plot titles (Stock Name + Species Name). -
Standardized layout, theming, and color schema. - Concise, reproducible
figure notes that act as built-in legends. - Reproducible workflows for
future users and archiving.

Standardization does not prevent customization. Staff can treat
EGprocess outputs as templates, modifying elements as needed for unique
stock-specific situations. In more complex cases, users can build new
plots from scratch using the tools provided by EGprocess.

### Package Structure / Workflow

EGprocess starts with MCMC output data created either by the Hamachan
Shiny App, or during personalized spawner-recruit analyses using rJAGS.
Specifically, the data must contain nodes of lnalpha, beta, phi, and
sigma.  
There are repeated elements within EGprocess for ease of use. Common
data inputs include:  
- *brood_data*: Brood table created by function `make_brood()`  
- *goal_data*: Current and historical escapement goals  
- *posterior_data*: MCMC samples for ln(alpha), beta, sigma, and related
parameters  
- *profile_data*: Data output from function `get_profile()`

### Flexible MSY Targets

While the typical escapement goal benchmark is 90% of MSY, it may be
necessary to demonstrate other MSY levels. For example, the included
dataset for Igushik River sockeye salmon shows a a near-zero probability
of achieving 90% MSY at the lower bound of its existing goal and
historical management reasoning for a suboptimal but stable yield.  
In cases like this, EGprocess supports side-by-side evaluation of
optimal and suboptimal yields. Users can specify a suboptimal target
directly in the `get_profile()` function and generate profile plots that
evaluate escapement goals relative to both targets.

### Updating Escapement Goals

Most frequently, researchers are tasked with updating an existing
escapement goal with additional returns. In such cases, it is helpful to
compare data since the previous assessment to the updated dataset.
EGprocess facilitates simple comparison between such datasets so that
researchers can assess the validity of the goal in light of additional
data. The plotting function `plot_profile_facet()` shows the Optimal
Yield Profile from both datasets.

## Function Overview

### get_profile()

Function `get_profile()` generates optimal yield profiles (OYP) and
expected yield curves from posterior MCMC samples.

``` r
library(EGprocess)
data("post_Igushik_byr63_15")
get_profile(posterior_data = post_Igushik_byr63_15, multiplier = 1e-5)
#> # A tibble: 1,001 × 4
#>         s OYP90     SY   S.msy
#>     <dbl> <dbl>  <dbl>   <dbl>
#>  1     0      0     0  381647.
#>  2  2290.     0  7137. 381647.
#>  3  4580.     0 14211. 381647.
#>  4  6870.     0 21209. 381647.
#>  5  9160.     0 28150. 381647.
#>  6 11449.     0 35021. 381647.
#>  7 13739.     0 41814. 381647.
#>  8 16029.     0 48566. 381647.
#>  9 18319.     0 55244. 381647.
#> 10 20609.     0 61901. 381647.
#> # ℹ 991 more rows
```

### make_age()

Function `make_age()` creates age-composition proportions (A3, A4, etc)
from run data for use in brood‑table construction.

``` r
make_age(age_data = data_Igushik, min_age = 3, max_age = 8) 
#>               A3          A4        A5           A6           A7 A8
#> X1  0.0000000000 0.555764167 0.3766676 6.756826e-02 0.000000e+00  0
#> X2  0.0000000000 0.219372533 0.7100296 7.059784e-02 0.000000e+00  0
#> X3  0.0000000000 0.095716122 0.8498052 5.447866e-02 0.000000e+00  0
#> X4  0.0000000000 0.056988887 0.8474545 9.555660e-02 0.000000e+00  0
#> X5  0.0002546232 0.477357932 0.4993162 2.307129e-02 0.000000e+00  0
#> X6  0.0010286048 0.430297401 0.5496121 1.906187e-02 0.000000e+00  0
#> X7  0.0000000000 0.420274924 0.5644736 1.525146e-02 0.000000e+00  0
#> X8  0.0006819845 0.104215277 0.8397835 5.531929e-02 0.000000e+00  0
#> X9  0.0013483240 0.130981323 0.7100417 1.576286e-01 0.000000e+00  0
#> X10 0.0000000000 0.379921229 0.5528422 6.723661e-02 0.000000e+00  0
#> X11 0.0000000000 0.008055034 0.8972150 9.419476e-02 5.352474e-04  0
#> X12 0.0000000000 0.086874734 0.8954707 1.765456e-02 0.000000e+00  0
#> X13 0.0002601857 0.166661538 0.5806786 2.523997e-01 0.000000e+00  0
#> X14 0.0000000000 0.307418579 0.5547262 1.378552e-01 0.000000e+00  0
#> X15 0.0002881760 0.108918752 0.7202282 1.704943e-01 7.057371e-05  0
#> X16 0.0001585414 0.491842807 0.4904775 1.752119e-02 0.000000e+00  0
#> X17 0.0000000000 0.390329818 0.5960777 1.359243e-02 0.000000e+00  0
#> X18 0.0003229606 0.174260418 0.8164945 8.922151e-03 0.000000e+00  0
#> X19 0.0000000000 0.132710475 0.6333931 2.338964e-01 0.000000e+00  0
#> X20 0.0000000000 0.050242976 0.8244419 1.253151e-01 0.000000e+00  0
#> X21 0.0000000000 0.515016558 0.4333081 5.151025e-02 1.650726e-04  0
#> X22 0.0000000000 0.047599669 0.9131298 3.927056e-02 0.000000e+00  0
#> X23 0.0000000000 0.378556346 0.6040013 1.744238e-02 0.000000e+00  0
#> X24 0.0018895461 0.094217923 0.8364664 6.742610e-02 0.000000e+00  0
#> X25 0.0000000000 0.224807188 0.5935127 1.816801e-01 0.000000e+00  0
#> X26 0.0000000000 0.104111822 0.8638066 3.208162e-02 0.000000e+00  0
#> X27 0.0029836950 0.443186255 0.5200156 3.381447e-02 0.000000e+00  0
#> X28 0.0018341127 0.189418072 0.7867202 2.202761e-02 0.000000e+00  0
#> X29 0.0000000000 0.053575747 0.9168175 2.858605e-02 1.020757e-03  0
#> X30 0.0003082830 0.225308124 0.7237741 4.888944e-02 1.720007e-03  0
#> X31 0.0002942510 0.301490081 0.6768706 2.134505e-02 0.000000e+00  0
#> X32 0.0000000000 0.155833300 0.8181893 2.597736e-02 0.000000e+00  0
#> X33 0.0000000000 0.145098254 0.8266256 2.827617e-02 0.000000e+00  0
#> X34 0.0000000000 0.035009165 0.8494743 1.155166e-01 0.000000e+00  0
#> X35 0.0000000000 0.481061894 0.4648853 5.405276e-02 0.000000e+00  0
#> X36 0.0000000000 0.384094659 0.5935855 2.231987e-02 0.000000e+00  0
#> X37 0.0000000000 0.437628445 0.5567136 5.657975e-03 0.000000e+00  0
#> X38 0.0000000000 0.078384924 0.9033793 1.823575e-02 0.000000e+00  0
#> X39 0.0000000000 0.003818095 0.9785852 1.759670e-02 0.000000e+00  0
#> X40 0.0000000000 0.652844759 0.3064357 4.071954e-02 0.000000e+00  0
#> X41 0.0000000000 0.123772817 0.8049286 7.117054e-02 1.280009e-04  0
#> X42 0.0000000000 0.198629422 0.7647808 3.658973e-02 0.000000e+00  0
#> X43 0.0000000000 0.039729767 0.8400136 1.202566e-01 0.000000e+00  0
#> X44 0.0000000000 0.323152097 0.6197413 5.710662e-02 0.000000e+00  0
#> X45 0.0000000000 0.755401276 0.2374968 7.101963e-03 0.000000e+00  0
#> X46 0.0000000000 0.315636948 0.6752858 9.077250e-03 0.000000e+00  0
#> X47 0.0000000000 0.205857641 0.7691113 2.503110e-02 0.000000e+00  0
#> X48 0.0000000000 0.134277217 0.8516902 1.403254e-02 0.000000e+00  0
#> X49 0.0000000000 0.158134306 0.7883031 5.356260e-02 0.000000e+00  0
#> X50 0.0000000000 0.103880121 0.8657222 3.039764e-02 0.000000e+00  0
#> X51 0.0000000000 0.190750427 0.7963699 1.287968e-02 0.000000e+00  0
#> X52 0.0005639977 0.395222452 0.5625153 4.146637e-02 2.318657e-04  0
#> X53 0.0002367074 0.309021839 0.6896431 1.098347e-03 0.000000e+00  0
#> X54 0.0000000000 0.197554710 0.7951823 7.263017e-03 0.000000e+00  0
#> X55 0.0014354083 0.737140660 0.2572664 4.157482e-03 0.000000e+00  0
#> X56 0.0000000000 0.382744958 0.6153650 1.890018e-03 0.000000e+00  0
#> X57 0.0006262294 0.171642774 0.8245712 3.159846e-03 0.000000e+00  0
#> X58 0.0017096202 0.457849161 0.5404396 1.649417e-06 0.000000e+00  0
#> X59 0.0000000000 0.501302133 0.4663781 3.231978e-02 0.000000e+00  0
#> X60 0.0002236942 0.222499087 0.7736382 3.639050e-03 0.000000e+00  0
#> X61 0.0000000000 0.220092937 0.7586368 2.127030e-02 0.000000e+00  0
```

### make_brood()

Function `make_brood()` builds the brood table by combining escapement,
recruitment, and age-composition information.

``` r
p_Igushik <- make_age(data_Igushik, min_age = 3, max_age = 8)
make_brood(data = data_Igushik, p = p_Igushik)
#>      yr       S b.Age3  b.Age4  b.Age5 b.Age6 b.Age7 b.Age8       R
#> 1  1955      NA     NA      NA      NA     NA     NA      0      NA
#> 2  1956      NA     NA      NA      NA     NA      0      0      NA
#> 3  1957      NA     NA      NA      NA   9213      0      0      NA
#> 4  1958      NA     NA      NA   51359  13488      0      0      NA
#> 5  1959      NA     NA   75779  135654  16194      0      0      NA
#> 6  1960      NA      0   41912  252608  29630      0      0  324150
#> 7  1961      NA      0   28452  262777   9514      0      0  300743
#> 8  1962      NA      0   17671  205905   5541      0      0  229117
#> 9  1963   92184      0  196850  159764  11591      0      0  368205
#> 10 1964  128532    105  125081  428996  28877      0      0  583059
#> 11 1965  180840    299  319406  438372  52842      0      0  810919
#> 12 1966  206360      0   54401  238028   8604     61      0  301094
#> 13 1967  281772    356   43909   70745  10735      0      0  125745
#> 14 1968  194508    452   48617  102252   7602      0      0  158923
#> 15 1969  512328      0     918  385587  90217      0      0  476722
#> 16 1970  370920      0   37408  207556  42459     12      0  287435
#> 17 1971  210960      0   59571  170854  28990      0      0  259415
#> 18 1972   60018     93   94684  122464  14809      0      0  232050
#> 19 1973   59508      0   18520  414554  18927      0      0  452001
#> 20 1974  358752     49  415708  830018  21355      0      0 1267130
#> 21 1975  241086    134  543521 1954264 312984      0      0 2810903
#> 22 1976  186120      0  417089  847563  89818    196      0 1354666
#> 23 1977   95970    773  177584  590908  61161      0      0  830426
#> 24 1978  536154      0   36011  514491  11773      0      0  562275
#> 25 1979  859560      0  611508  273749  11218      0      0  896475
#> 26 1980 1987530      0   14270  388461  41072      0      0  443803
#> 27 1981  591144      0  243467  509526  85652      0      0  838645
#> 28 1982  423768      0   57392  279808   9408      0      0  346608
#> 29 1983  180438   1151  105984  253313  30656      0      0  391104
#> 30 1984  184872      0   30531  471443  19300   1680      0  522954
#> 31 1985  212454      0  401790  689303  47048    809      0 1138950
#> 32 1986  307728   2705  165963 1508933  22995      0      0 1700596
#> 33 1987  169236   1607   88177  340425  15306      0      0  445515
#> 34 1988  170454      0  105973  485367  23557      0      0  614897
#> 35 1989  461610    145  216191  741957  33491      0      0  991784
#> 36 1990  365802    211  141314  979076 108897      0      0 1229498
#> 37 1991  756126      0  171858  800796  11284      0      0  983938
#> 38 1992  304920      0   33003   97049   9509      0      0  139561
#> 39 1993  405564      0  100426  252887   4862      0      0  358175
#> 40 1994  445920      0  163637  478394  17921      0      0  659952
#> 41 1995  473382      0  376062  887787  14407      0      0 1278256
#> 42 1996  400746      0   77032  801200   8131     63      0  886426
#> 43 1997  127704      0    3126   61190  35029      0      0   99345
#> 44 1998  215904      0  130362  396173   9819      0      0  536354
#> 45 1999  445536      0   60919  205232  96336      0      0  362487
#> 46 2000  413316      0   53303  672924  41559      0      0  767786
#> 47 2001  409596      0   31827  451013   7263      0      0  490103
#> 48 2002  123156      0  235172  242882  17146      0      0  495200
#> 49 2003  194088      0  772530 1275546  39683      0      0 2087759
#> 50 2004  109650      0  596206 1219309  19756      0      0 1835271
#> 51 2005  365712      0  326356 1199070  54412      0      0 1579838
#> 52 2006  305268      0  189045  800804  15413      0      0 1005262
#> 53 2007  415452      0  160642  438961   8919    333      0  608855
#> 54 2008 1054704      0   52672  551475  59553      0      0  663700
#> 55 2009  514188      0  132092  807871   1805      0      0  941768
#> 56 2010  518040      0  567609 1133345  13439      0      0 1714393
#> 57 2011  421380    810  507840 1471352   5115      0      0 1985117
#> 58 2012  193326    389  365542  316518   3629      0      0  686078
#> 59 2013  387036      0  906913 1181555   4294      0      0 2092762
#> 60 2014  340590   1766  734904 1120532      2      0      0 1857204
#> 61 2015  651172      0  233250  655310  65390      0      0  953950
#> 62 2016  469230    851  555165  943585  10867      0     NA      NA
#> 63 2017  578700   2073 1014244 2310253  29350     NA     NA      NA
#> 64 2018  770772      0  664431 1046811     NA     NA     NA      NA
#> 65 2019  256074    668  303697      NA     NA     NA     NA      NA
#> 66 2020  323814      0      NA      NA     NA     NA     NA      NA
#> 67 2021  878952     NA      NA      NA     NA     NA     NA      NA
#> 68 2022  378768     NA      NA      NA     NA     NA     NA      NA
#> 69 2023  542496     NA      NA      NA     NA     NA     NA      NA
```

### plot_profile()

Function `plot_profile()` generates a standardized Optimal Yield Profile
(OYP) plot from a single profile dataset.

``` r
Igushik_profile <- get_profile(post_Igushik_byr63_15, multiplier = 1e-5)
plot_profile(profile_data = Igushik_profile, goal_data = goal_Igushik, 
title = "Igushik River Sockeye Salmon")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

### 

Function `plot_profile_facet()` produces faceted OYP plots for comparing
multiple posterior datasets (e.g., updated vs. historical).

``` r
post_list <- list(
     'Brood Years: 1963-2005' = post_Igushik_byr63_05,
     'Brood Years: 1963-2015' = post_Igushik_byr63_15)
profile_list <- lapply(post_list, get_profile, multiplier = 1e-5)

plot_profile_facet(profile_data = profile_list, goal_data = goal_Igushik,
title = "Igushik River Sockeye Salmon")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" /> \###
Function

### 

Function

### 

Function

## Included Datasets
