cat_piece <- function(df, ...) {
    ppcli::cat_piece(df, ..., color = FALSE, style = "Game Bit Mono")
}

test_that("Dominoes", {
    skip_if_not_installed("tibble")
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
    expect_snapshot(cat_piece(df))
})

# https://github.com/piecepackr/ppcli/issues/3
test_that("Can't rotate boards", {
    skip_if_not_installed("ppdf")
    expect_snapshot(cat_piece(ppdf::checkers_italian_checkers(), annotate = "cartesian"))
})
