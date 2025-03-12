#' Prints plaintext piecepack diagrams
#'
#' `cat_piece()` generates plaintext piecepack diagrams and
#'  outputs them using `base::cat()`.  `cat_move()` generates
#' a plaintext diagram for a move within a game.  `cat_game()`
#' renders an animation of a game in the terminal.
#'
#' @inheritParams str_piece
#' @param ... Passed to [cat()].
#' @param file `file` argument of [cat()].
#'             Default (`""`) is to print to standard output.
#' @return String of text diagram (returned invisibly).
#'         As a side effect prints out the text diagram using [cat()].
#' @seealso [str_piece()] for just the character vector.  See <https://github.com/trevorld/game-bit-font> for more information about the \dQuote{Game Bit} family of fonts.
#' @export
cat_piece <- function(df, color = NULL, reorient = "none", annotate = FALSE, ...,
                      file = "", annotation_scale = NULL,
                      style = c("Unicode", "Game Bit Mono", "Game Bit Duo"),
                      xbreaks = NULL, ybreaks = NULL) {
    color <- color %||% (is.null(file) || file == "")
    s <- str_piece(df, color = color, reorient = reorient, annotate = annotate,
                   annotation_scale = annotation_scale, style = style,
                   xbreaks = xbreaks, ybreaks = ybreaks)
    if (!is.null(file)) cat(s, ..., file = file)
    invisible(s)
}
