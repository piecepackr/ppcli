ppcli 0.2.0 (development)
=========================

New features
------------

* `cat_piece()` and `str_piece()` adds support for the following game pieces (#4):

  + "alquerque" bit and board pieces.
  + "dice_numeral" dice.
  + "marbles" bit and board pieces.

    - However we currently do not distinguish between the nine marble bit ranks.

  + "morris" bit and board pieces.
  + "reversi" bit and board pieces.

* `cat_piece()` and `str_piece()` gain arguments `xbreaks` and `ybreaks`
  to provide a subset (of integers) to provide axis labels for if `annotate` is `TRUE` (#17).
* `cat_piece()` and `str_piece()` now supports the "cyan" and "magenta" colors (#5).

Bug fixes and minor improvements
--------------------------------

* "white" `go` and `marbles` bits should now render the same
  whether `piece_side` is `"bit_back"` or `"bit_face"`.

* `checkers1` and `checkers2` bit faces should now render
  as checker "kings".  Bit backs should continue to render as checker "men".

* `cat_piece()` and `str_piece()` now expand the drawing range for longer
  (piecepack) matchsticks if necessary (#14).

* `str_piece()`'s `color` argument if `NULL` now falls back to `FALSE`
  (instead of throwing an error).

* Should now be able to correctly rotate chess knights 315 degrees.

ppcli 0.1.1
===========

* ``cat_piece()`` prints out Unicode plaintext boardgame diagrams.

  + It supports the same data frame arguments also supported by
    ``piecepackr::pmap_piece()`` / ``piecepackr::render_piece()``
    as well as the board game setup functions in `{ppdf}`.
  + It is an extraction and refinement of ``ppgames::cat_piece()``.

* ``str_piece()`` computes the character vector of Unicode plaintext boardgame diagrams (#1).
