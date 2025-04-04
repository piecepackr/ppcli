cat_piece <- function(df, ...) ppcli::cat_piece(df, ..., color = FALSE)

test_that("text diagrams", {
    skip_if_not_installed("dplyr")
    skip_if_not_installed("tibble")
    skip_if_not_installed("withr")
    library("tibble")

    style <- get_style("unicode")
    expect_warning(style$rotate("$", 90))
    expect_warning(style$rotate("&", 180))
    expect_warning(style$rotate("&", 270))
    expect_warning(style$rotate("&", 45))
    expect_warning(style$rotate("&", 35))
    f <- tempfile()
    expect_equal(cat_piece(tibble(), file = f), character())
    unlink(f)
    expect_warning(capture.output(cat_piece(tibble(piece_side = "saucer_face", x=2, y=2))))
    expect_error(cat_piece(tibble(piece_side = "pyramid_top", x=2, y=2, rank=7, cfg="icehouse_pieces")))
    expect_error(suppressWarnings(cat_piece(tibble(piece_side = "tile_face", x=2, y=2, angle=45))))
    expect_error(cat_piece(tibble(piece_side = "tile_back", x=2, y=2, angle=45)))

    expect_error(suppressWarnings(cat_piece(tibble(piece_side = "tile_face", x=2, y=2, angle = 45))))

    skip_on_os("windows")

    # checkers
    expect_snapshot({
        dft <- tibble(piece_side = "board_back", x=seq(1.5, 5.5, 2), y=1.5, rank=2,
                      cfg="checkers1")
        dfbb <- tibble(piece_side = "bit_back", x=1:6, y=1, suit=1:6, cfg="checkers1")
        dfbf <- tibble(piece_side = "bit_face", x=1:6, y=2, suit=1:6, cfg="checkers1")
        dfd <- tibble(piece_side = "die_face", x=1:6, y=3, suit=1:6, rank=1:6,
                      cfg="dice", angle = c(45, rep(0, 5)))
        df <- dplyr::bind_rows(dft, dfbb, dfbf, dfd)
        cat_piece(df)

        df <- dplyr::mutate(df, cfg = gsub("checkers1", "checkers2", cfg),
                            x = 2 * x, y = 2 * y)
        cat_piece(df, annotate = TRUE, annotation_scale = 2, reorient = "all")
    })

    # fudge dice
    expect_snapshot({
        df <- tibble(piece_side = "die_face", x=1:6, y=1, rank=1:6, suit=1:6, cfg="dice_fudge")
        cat_piece(df)

        df$angle <- 90
        cat_piece(df)
    })

    # icehouse
    expect_snapshot({
        dfb <- tibble(piece_side = "board_face", x=c(2.5,6.5), y=2, rank=4, cfg="checkers1")
        dfpt <- tibble(piece_side = "pyramid_top", x=1:8, y=4,
                       rank=rep(1:3, length.out=8), suit=c(1:6, 1:2),
                       angle=seq(0, by=45, length.out=8), cfg="icehouse_pieces")
        dfpf <- tibble(piece_side = rep(c("pyramid_face", "pyramid_left", "pyramid_right", "pyramid_back"), 6),
                       x=rep(1:8, 3), y=rep(1:3, each=8),
                       rank=rep(1:3, each=8), suit=rep(1:6, 4),
                       angle=rep(seq(0, by=45, length.out=8), 3),
                       cfg="icehouse_pieces")
        df <- dplyr::bind_rows(dfb, dfpt, dfpf)
        cat_piece(df)
    })

    expect_equal(get_dots(4), "\u0324\u0308")
    expect_equal(get_dots(5), "\u20e8\u0308")
    expect_equal(get_dots(6), "\u20e8\u20db")

    # stackpack
    expect_snapshot({
        dfpt <- tibble(piece_side = "tile_back", x = c(1.5, 3.5, 1.5, 3.5),
                       y = c(1.5, 1.5, 3.5, 3.5))
        dfbt <- tibble(piece_side = rep(c("tile_face", "tile_back"), 2),
                       x = 1:4, y = 1, suit = 1:4, rank = 1:4, cfg = "subpack")
        dfc <- tibble(piece_side = rep(c("coin_face", "coin_back"), 2),
                       x = 1:4, y = 2, suit = 1:4, rank = 1:4, cfg = "subpack")
        dfd <- tibble(piece_side = "die_face",
                       x = 1:4, y = 3, suit = 1:4, rank = 1:4, cfg = "subpack")
        dfp <- tibble(piece_side = rep(c("pawn_face", "pawn_back"), 2),
                       x = 1:4, y = 4, suit = 1:4, rank = 1:4, cfg = "subpack")
        df <- dplyr::bind_rows(dfpt, dfbt, dfc, dfd, dfp)
        cat_piece(df)
    })

    # misc
    expect_snapshot({
    dft <- tibble(piece_side = "tile_face", x=c(1.5, 3.5), y=1.5,
                  suit = 1, rank = 4, angle = c(90, 270))
    dfpb <- tibble(piece_side = "pawn_back", x=1:2, y=1,
                  suit=2:1, angle = c(0, 45))
    dfpf <- tibble(piece_side = "pawn_face", x=1, y=2,
                  suit=1, angle = 45)
    dfbf <- tibble(piece_side = "bit_back", x=3, y=1, suit=3, cfg="checkers1")
    df <- dplyr::bind_rows(dft, dfpb, dfpf, dfbf)
    cat_piece(df)
    })

    # dominoes
    expect_snapshot({
    dff <- tibble(piece_side = "tile_face",
                  x = rep(1:6, 2), y = rep(c(1,3), each = 6),
                  suit = rep(1:6, 2), rank = rep(2:7, 2),
                  angle = rep(c(0, 180), each = 6),
                  cfg = rep(paste0("dominoes_", c("black", "blue", "green", "red", "white", "yellow")), 2))
    dfb <- tibble(piece_side = "tile_back",
                  x = 1:6, y = 5, suit = 1:6, rank = 2:7, angle = rep(c(0, 180), each = 3),
                  cfg = paste0("dominoes_", c("black", "blue", "green", "red", "white", "yellow")))
    df <- dplyr::bind_rows(dff, dfb)
    cat_piece(df)

    dff <- tibble(piece_side = "tile_face",
                  x = rep(c(1,3), each = 6), y = rep(1:6, 2),
                  suit = rep(1:6, 2), rank = rep(2:7, 2),
                  angle = rep(c(90, 270), each = 6),
                  cfg = rep(paste0("dominoes_", c("black", "blue", "green", "red", "white", "yellow")), 2))
    dfb <- tibble(piece_side = "tile_back",
                  x = 5, y = 1:6, suit = 1:6, rank = 2:7, angle = rep(c(90, 270), each = 3),
                  cfg = paste0("dominoes_", c("black", "blue", "green", "red", "white", "yellow")))
    df <- dplyr::bind_rows(dff, dfb)
    cat_piece(df)
    })

    # matchsticks
    expect_snapshot({
        dft <- tibble(piece_side = "tile_back",
                      x=rep(seq(1, 9, 2), 7),
                      y = rep(seq(1, 13, 2), each = 5))
        for (angle in seq(0, 315, 45)) {
            dfm <- tibble(piece_side = "matchstick_face",
                          x = 1:6, y = seq(1, 11, 2),
                          suit = 1, rank = 1:6, angle = angle)
            df <- dplyr::bind_rows(dft, dfm)
            cat_piece(df)
        }

        dfm <- tibble(piece_side = "matchstick_back",
                      x = 1:4, y = seq(1, 7, 2),
                      suit = 1, rank = 5,
                      angle = c(60, 120, 240, 300))
        df <- dplyr::bind_rows(dft, dfm)
        cat_piece(df)
    })
    expect_error(cat_piece(tibble(piece_side = "matchstick_face", x=1, y=1, rank=7)))
    for (rank in 1:6) {
        expect_error(cat_piece(tibble(piece_side = "matchstick_face", x=1, y=1,
                                      rank=rank, angle=30)))
    }

    # chess
    expect_snapshot({
        dfb <- tibble(piece_side = "board_face", x = 4.5, y = 4.5,
                      suit = 2, cfg = "chess1")
        dfp <- tibble(piece_side = "bit_face", x = 1:6, y = 1,
                      rank = 1:6, suit = 1:6,
                      cfg = "chess1")
        df <- dplyr::bind_rows(dfb, dfp)
        cat_piece(df)
    })

    # go
    expect_snapshot({
        dfb <- tibble(piece_side = "board_face", x = 10, y = 10, suit = 2, cfg = "go")
        dfs <- tibble(piece_side = "bit_back", x = 1:19, y = 1:19,
                      suit = 1:19 %% 6 + 1, cfg = "go")
        df <- dplyr::bind_rows(dfb, dfs)
        cat_piece(df)
    })

    # marbles
    expect_snapshot({
        withr::local_seed(42)
        dfb <- tibble(piece_side = "board_face", suit = 4L, rank = 4L,
                      cfg ="marbles", x = 2, y = 2)
        dfm <- tibble(
            piece_side = "bit_face",
            suit = sample.int(6L, 30L, replace = TRUE),
            rank = 9L,
            cfg = "marbles",
            x = c(0.5 + rep(0:3, 4L), rep(rep(1:3, 3L)), 0.5 + rep(1:2, 2L), 2),
            y = c(0.5 + rep(0:3, each = 4L), rep(1:3, each = 3L), 0.5 + rep(1:2, each = 2L), 2)
        )
        df <- rbind(dfb, dfm)
        cat_piece(dfb)
        cat_piece(df, xbreaks = 1:7, ybreaks = 1:7,
                  annotate = TRUE, annotation_scale = 0.5)
    })

    # alquerque
    expect_snapshot({
        dfb <- tibble(piece_side = "board_face", x= 3, y = 3, suit = 3, cfg = "alquerque")
        dfs <- tibble(piece_side = "bit_back", x = 1:5, y = 1:5, suit = 1:5, cfg = "alquerque")
        df <- rbind(dfb, dfs)
        cat_piece(dfb)
        cat_piece(df)
    })

    # morris
    expect_snapshot({
        df2 <- tibble(piece_side = "board_face", x = 2, y = 2,
                      rank = 2L, suit = 3L, cfg = "morris")
        cat_piece(df2)

        df3 <- tibble(piece_side = "board_face", x = 2, y = 2,
                      rank = 3L, suit = 3L, cfg = "morris")
        dfs <- tibble(piece_side = "bit_back", x = rep(1:3, 2), y = rep(1:2, each = 3),
                      rank = 1L, suit = 1:6, cfg = "morris")
        df <- rbind(df3, dfs)
        cat_piece(df3)
        cat_piece(df)

        df6 <- tibble(piece_side = "board_face", x = 3, y = 3,
                      rank = 6L, suit = 3L, cfg = "morris")
        cat_piece(df6)

        df7 <- tibble(piece_side = "board_face", x = 3, y = 3,
                      rank = 7L, suit = 3L, cfg = "morris")
        cat_piece(df7)

        df9 <- tibble(piece_side = "board_face", x = 4, y = 4,
                      rank = 9L, suit = 3L, cfg = "morris")
        cat_piece(df9)

        df12 <- tibble(piece_side = "board_face", x = 4, y = 4,
                       rank = 12L, suit = 3L, cfg = "morris")
        cat_piece(df12)
    })

    # reversi
    expect_snapshot({
        dfx <- tibble(piece_side = "board_face", x = 4.5, y = 4.5,
                      rank = 8L, suit = 2L, cfg = "reversi")
        dff <- tibble(piece_side = "bit_face", x = 1:6, y = 1,
                      rank = 1L, suit = 1:6, cfg = "reversi")
        dfb <- tibble(piece_side = "bit_back", x = 1:6, y = 2,
                      rank = 1L, suit = 1:6, cfg = "reversi")
        df <- rbind(dfx, dff, dfb)
        cat_piece(df)
    })

    # numeral dice
    expect_snapshot({
        df <- tibble(piece_side = "die_face", x=1:6, y=1, rank=1:6, suit=1:6, cfg="dice_numeral")
        cat_piece(df)
    })
})
