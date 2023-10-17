test_that('`color = "html"`', {
    skip_if_not_installed("fansi")
    skip_if_not_installed("ppdf")

    s <- str_piece(ppdf::piecepack_american_checkers(), color = "html")
    expect_true(any(grepl("span style", s)))
})
