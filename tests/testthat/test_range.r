test_that("`range_heuristic()`", {
    skip_if_not_installed("ppdf")
    skip_if_not_installed("tibble")
    library("tibble")

    df <- ppdf::piecepack_four_field_kono()
    df$cfg <- "piecepack"
    df$angle <- 0
    expect_equal(range_heuristic(df)$xmin, 0.5)
    expect_equal(range_heuristic(df)$xmax, 4.5)
    expect_equal(range_heuristic(df)$ymin, 0.5)
    expect_equal(range_heuristic(df)$ymax, 4.5)
    expect_equal(range_heuristic(tibble())$xmin, NA_real_)
    expect_equal(range_heuristic(tibble())$xmax, NA_real_)
    expect_equal(range_heuristic(tibble())$ymin, NA_real_)
    expect_equal(range_heuristic(tibble())$ymax, NA_real_)
})
