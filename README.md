# ppcli

[![CRAN Status Badge](https://www.r-pkg.org/badges/version/ppcli)](https://cran.r-project.org/package=ppcli)
[![R-CMD-check](https://github.com/piecepackr/ppcli/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main)](https://github.com/piecepackr/ppcli/actions)
[![codecov](https://codecov.io/github/piecepackr/ppcli/branch/main/graph/badge.svg)](https://app.codecov.io/github/piecepackr/ppcli)

### Table of Contents

* [Overview](#overview)
* [Installation](#installation)
* [Examples](#examples)
* [FAQ](#faq)
* [Related links](#links)

## <a name="overview">Overview</a>

* `cat_piece()` prints out plaintext Unicode board game diagrams while `str_piece()` returns just the character vector.
* Can optionally colorize output for the terminal using `{cli}` or HTML using `fansi::sgr_to_html()`.
* The board game data frame format used by this package is the same as:

  + The format expected by `piecepackr::pmap_piece()` or `piecepackr::render_piece()` for visualization
    with `{grid}`, `{ggplot2}`, `{rayrender}`, `{rayvertex}`, or `{rgl}`.
  + The format returned by 100+ functions in the [{ppdf}](https://www.github.com/piecepackr/ppdf) package.
  + The `dfs` attribute of games parsed by `ppgames::read_ppn()` i.e. can view any of the moves of games recorded using [Portable Piecepack Notation (PPN)](https://trevorldavis.com/piecepackr/portable-piecepack-notation.html).

* This is an extraction and refinement of functionality originally contained in the experimental [{ppgames}](https://www.github.com/piecepackr/ppgames) package.

## <a name="installation">Installation</a>


```r
remotes::install_github("piecepackr/ppcli")
```

## <a name="examples">Examples</a>

``` {.r}
library("ppcli")
library("tibble")
df <- tibble(piece_side = "tile_face",
             x=c(0.5, 1.0, 1.5, 2.0, 2.5, 2.5, 3.5, 4.0, 4.0,
                 4.5, 5.5, 6.0, 7.5, 8.0),
             y=c(5.0, 2.5, 1.0, 4.5, 6.0, 3.0, 1.0, 6.5, 2.5,
                 4.0, 6.0, 4.5, 4.0, 2.5),
             rank = c(4, 2, 5, 4, 1, 1, 5, 1, 5, 6, 2, 6, 6, 4) + 1,
             suit = c(4, 5, 0, 1, 1, 5, 4, 2, 5, 5, 6, 6, 4, 0) + 1,
             angle = c(0, 90, 0, 90, 0, 0, 0, 90, 90, 0, 0, 90, 0, 90),
             cfg = "dominoes_white")
cat_piece(df, style = "Game Bit Mono")
```

![Dominoes diagram](https://github.com/trevorld/game-bit-font/blob/main/png/dominoes_mono.png?raw=true)


``` {.r}
library("ppcli")
library("ppdf")
cat_piece(piecepack_xiangqi())
```

![Setup for playing Xiangqi with a piecepack](https://trevorldavis.com/share/piecepack/unicode_xiangqi.png)

## <a name="faq">FAQ</a>

### Why not in `{piecepackr}` yet?

The plaintext scheme used by `cat_piece()` / `str_piece()` requires more knowledge about the state of previously drawn pieces:

  + We need to know which [Box-drawing characters](https://en.wikipedia.org/wiki/Box-drawing_character) are already on the board.
  + We need to standardize on the target font scheme since some fonts like [Game Bit Mono and Game Bit Duo](https://github.com/trevorld/game-bit-font) rely on glyphs in the Unicode Private-Use-Area.

We don't need to know nearly as much state about how other game pieces were drawn when drawing with `{grid}`, `{ggplot2}`, `{rayrender}`, `{rayvertex}`, or `{rgl}` so it is much more straightforward to simply plot them in sequence using `piecepackr::pmap_piece()`.

## <a name="links">Related links</a>

### Supported Board Game Fonts

* [Game Bit Font](https://github.com/trevorld/game-bit-font)

### R packages

* [{piecepackr}](https://github.com/piecepackr/piecepackr)
* [{ppdf}](https://github.com/piecepackr/ppdf)
* [{ppn}](https://github.com/piecepackr/ppn)

### Blog/forum posts

* [Experimental piecepack Private Use Area font support](https://boardgamegeek.com/thread/2744191/experimental-piecepack-private-use-area-font-suppo)
* [Unicode piecepack diagrams](https://trevorldavis.com/piecepackr/unicode-piecepack-diagrams.html)
* [Unicode Piecepack Symbols](https://trevorldavis.com/piecepackr/unicode-piecepack-symbols.html)
