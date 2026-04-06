cat_piece <- function(df, ...) {
    ppcli::cat_piece(df, ..., color = FALSE, style = "Game Bit Duo")
}

test_that("Piecepack", {
    skip_if_not_installed("ppdf")
    expect_snapshot(cat_piece(ppdf::piecepack_shopping_mall(seed = 42)))
})
