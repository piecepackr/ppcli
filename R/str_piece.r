#' Generate plaintext piecepack diagrams
#'
#' `str_piece()` generates plaintext piecepack diagrams.
#'
#' @param df Data frame containing piece info.
#' @param color How should the text be colorized.
#'              If `FALSE` won't colorize output at all.
#'              If `"html"` will colorize output for html.
#'              Otherwise will colorize output for the terminal using ANSI CSI SGR control sequences.
#' @param reorient Determines whether and how we should reorient (the angle) of pieces or symbols:\enumerate{
#'        \item{The default "none" (or `FALSE`) means don't reorient any pieces/symbols.}
#'        \item{"all" (or `TRUE`) means setting the angle to zero for all pieces
#'              (reorienting them all \dQuote{up}).}
#'        \item{"symbols" means just re-orient suit/rank symbols but not the orientation of the piece itself.
#'              In particular, in contrast with "all" this preserves the location
#'              of the upper-left "corner" of piecepack tile faces.}}
#' @param annotate If `TRUE` or `"algebraic"` annotate the plot
#'                  with \dQuote{algrebraic} coordinates,
#'                 if `FALSE` or `"none"` don't annotate,
#'                 if `"cartesian"` annotate the plot with \dQuote{cartesian} coordinates.
#' @param ... Mainly ignored except for a couple of undocumented features.
#' @param annotation_scale Multiplicative factor that scales (stretches) any annotation coordinates.
#'                         By default uses `attr(df, "scale_factor") %||% 1`.
#' @param style If "Unicode" (default) only use glyphs in Unicode proper.
#'              If "Game Bit Duo" use glyphs in Private Use Area of "Game Bit Duo" font.
#'              If "Game Bit Mono" use glyphs in Private Use Area of "Game Bit Mono" font.
#' @param xbreaks,ybreaks Subset (of integers) to provide axis labels for if `annotate` is `TRUE`.
#'                        If `NULL` infer a reasonable choice.
#' @return Character vector for text diagram.
#' @seealso [cat_piece()] for printing to the terminal.
#'          See <https://github.com/trevorld/game-bit-font> for more information about the \dQuote{Game Bit} family of fonts.
#' @examples
#' dfb <- data.frame(piece_side = "board_face", x= 3, y = 3, suit = 3)
#' dfsw <- data.frame(piece_side = "bit_back",
#'                    x = c(1:5, 1:5, 4:5),
#'                    y = rep.int(1:3, c(5L, 5L, 2L)),
#'                    suit = 6L)
#' dfsb <- data.frame(piece_side = "bit_back",
#'                    x = c(1:5, 1:5, 1:2),
#'                    y = rep.int(5:3, c(5L, 5L, 2L)),
#'                    suit = 2L)
#' df <- rbind(dfb, dfsw, dfsb)
#' df$cfg <- "alquerque"
#' s <- str_piece(df)
#' is.character(s)
#' cat(s, sep = "\n")
#' @export
str_piece <- function(df, color = NULL, reorient = "none", annotate = FALSE, ...,
                      annotation_scale = NULL,
                      style = c("Unicode", "Game Bit Mono", "Game Bit Duo"),
                      xbreaks = NULL, ybreaks = NULL) {
    str_piece_helper(df, ..., color = color, reorient = reorient, annotate = annotate, ...,
                     annotation_scale = annotation_scale, style = style,
                     xbreaks = xbreaks, ybreaks = ybreaks)
}
str_piece_helper <- function(df, color = NULL, reorient = "none", annotate = FALSE, ...,
                             xoffset = NULL, yoffset = NULL,
                             annotation_scale = NULL,
                             style = "Unicode", xbreaks = NULL, ybreaks = NULL) {
    annotation_scale <- annotation_scale %||% attr(df, "scale_factor") %||% 1
    color <- color %||% FALSE
    if (nrow(df) == 0) {
        return(character(0))
    }
    style <- get_style(style = style[1])
    df <- clean_df(df)
    if (isTRUE(reorient) || reorient == "all") df$angle <- 0

    lr <- range_heuristic(df)
    offset <- get_df_offsets(df, lr, xoffset, yoffset, annotate)
    df$x <- df$x + offset$x
    df$y <- df$y + offset$y
    nc <- 2 * (lr$xmax + offset$x) + 1
    nr <- 2 * (lr$ymax + offset$y) + 1
    cm <- list(char = matrix(style$space, nrow = nr, ncol = nc),
               fg = matrix("black", nrow = nr, ncol = nc))

    for (rr in seq(nrow(df))) {
        ps <- as.character(df[rr, "piece_side"])
        suit <- as.numeric(df[rr, "suit"])
        rank <- as.numeric(df[rr, "rank"])
        x <- 2*as.numeric(df[rr, "x"])+1
        y <- 2*as.numeric(df[rr, "y"])+1
        angle <- as.numeric(df[rr, "angle"])
        cfg <- as.character(df[rr, "cfg"])
        cm <- add_piece(cm, ps, suit, rank, x, y, angle, cfg, reorient, style)
    }
    cm <- annotate_text(cm, nc, nr, offset$x, offset$y, annotate, annotation_scale, xbreaks, ybreaks)
    cm <- color_text(cm, color)
    text <- rev(apply(cm$char, 1, function(x) paste(x, collapse = "")))
    text <- paste(text, collapse = "\n")
    if (color == "html") {
        assert_suggested("fansi")
        text <- fansi::sgr_to_html(text)
        # text <- cli::ansi_html(text)
    }
    paste0(text, "\n")
}

get_style <- function(style = "Unicode") {
    style <- tolower(style)
    style <- gsub("-", "", style)
    style <- gsub(" ", "", style)
    style <- match.arg(style, c("unicode", "gamebitduo", "gamebitmono"))

    if (style == "gamebitduo") {
        space <- "  " ####
    } else {
        space <- " "
    }

    list(rotate = get_style_rotate(style),
         rs = get_style_rs(style),
         rs_big = get_style_rs(style, big = TRUE),
         ss = get_style_ss(style),
         ss_big = get_style_ss(style, big = TRUE),
         fg = get_style_fg(style),
         combining = get_style_combining(style),
         space = space,
         has_pua_box_drawing = style != "unicode"
         )
}

get_style_combining <- function(style) {
    if (style == "unicode")
        coin <- "\u20dd"
    else
        coin <- "\U000FCE50"

    if (style == "unicode")
        pawn <- "\u20df"
    else
        pawn <- "\U000FCDE0"

    die_suits <- rep("\u20de", 6)
    if (style == "unicode") {
        piecepack_suits <- die_suits
        french_suits_black <- die_suits
        french_suits_white <- die_suits
    } else {
        piecepack_suits    <- intToUtf8(utf8ToInt("\U000FCE00") + 0:3, multiple = TRUE)
        french_suits_black <- intToUtf8(utf8ToInt("\U000FCE20") + 0:3, multiple = TRUE)
        french_suits_white <- intToUtf8(utf8ToInt("\U000FCE30") + 0:3, multiple = TRUE)
    }
    die <- list(piecepack = piecepack_suits,
                playing_cards_expansion = french_suits_black,
                dual_piecepacks_expansion = french_suits_white,
                subpack = piecepack_suits,
                dice = die_suits,
                dice_fudge = die_suits,
                dice_numeral = die_suits)

    list(coin = coin, die = die, pawn = pawn)
}

get_style_rs <- function(style, big = FALSE) {

    if (style == "unicode") {
        dominoes_ranks <- c(" ", "\u00b7", "\u280c", "\u22f0", "\u2237", "\u2059", "\u283f")
    } else {
        dominoes_ranks <- c("\U000FCA00", "\U000FCA01", "\U000FCA02", "\U000FCA03", "\U000FCA04",
                            "\U000FCA05", "\U000FCA06", "\U000FCA07", "\U000FCA08", "\U000FCA09",
                            "\U000FCA0A", "\U000FCA0B", "\U000FCA0C", "\U000FCA0D", "\U000FCA0E",
                            "\U000FCA0F", "\U000FCA10", "\U000FCA11", "\U000FCA12")
    }

    if (style == "unicode") {
        piecepack_ranks <- c("n", "a", "2", "3", "4", "5")
    } else {
        if (big)
            piecepack_ranks <- intToUtf8(utf8ToInt("\U000FCB50") + 0:11, multiple = TRUE)
        else
            piecepack_ranks <- intToUtf8(utf8ToInt("\U000FCC50") + 0:11, multiple = TRUE)
    }
    if (style == "unicode")
        dice_fudge <- c("\u2212", " ", "+", "+", " ", "\u2212")
    else
        dice_fudge <- c("\uff0d", "\U000FCA00", "\uff0b", "\uff0b", "\U000FCA00", "\uff0d")

    rs <- list(piecepack = piecepack_ranks,
               playing_cards_expansion = piecepack_ranks,
               dual_piecepacks_expansion = piecepack_ranks,
               subpack = piecepack_ranks,
               checkers1 = c(rep_len("\u26c3", 5L), "\u26c1"),
               checkers2 = c(rep_len("\u26c3", 5L), "\u26c1"),
               chess1 = c("\u265f", "\u265e", "\u265d", "\u265c", "\u265b", "\u265a"),
               chess2 = c("\u265f", "\u265e", "\u265d", "\u265c", "\u265b", "\u265a"),
               dice = dominoes_ranks[-1],
               dice_fudge = dice_fudge,
               dice_numeral = as.character(1:6),
               dominoes = dominoes_ranks,
               dominoes_black = dominoes_ranks,
               dominoes_blue = dominoes_ranks,
               dominoes_green = dominoes_ranks,
               dominoes_red = dominoes_ranks,
               dominoes_white = dominoes_ranks,
               dominoes_yellow = dominoes_ranks,
               icehouse_pieces = rep(" ", 6L),
               alquerque = rep_len("\u25cf", 6L),
               go = rep_len("\u25cf", 6L),
               marbles = rep_len("\u25cf", 9L),
               morris = rep_len("\u25cf", 9L),
               reversi = c(rep_len("\u26c3", 5L), "\u26c1"))
    rs
}

get_style_ss <- function(style, big = FALSE) {
    # nolint start
    # Use Half-circle for Moons? \u25d0
    # Use Arrows for Arms?
    # nolint end
    if (style == "unicode") {
        dominoes_ranks <- c(" ", "\u00b7", "\u280c", "\u22f0", "\u2237", "\u2059", "\u283f")
        piecepack_suits <- c("\u2600", "\u263e", "\u265b", "\u2e38")
        french_suits_black <- c("\u2665", "\u2660", "\u2663", "\u2666")
        french_suits_white <- c("\u2661", "\u2664", "\u2667", "\u2662")
    } else {
        dominoes_ranks <- c("\U000FCA00", "\U000FCA01", "\U000FCA02", "\U000FCA03", "\U000FCA04",
                            "\U000FCA05", "\U000FCA06", "\U000FCA07", "\U000FCA08", "\U000FCA09")
        if (big) {
            piecepack_suits    <- intToUtf8(utf8ToInt("\U000FCB00") + 0:3, multiple = TRUE)
            french_suits_black <- intToUtf8(utf8ToInt("\U000FCB20") + 0:3, multiple = TRUE)
            french_suits_white <- intToUtf8(utf8ToInt("\U000FCB30") + 0:3, multiple = TRUE)
        } else {
            piecepack_suits    <- intToUtf8(utf8ToInt("\U000FCC00") + 0:3, multiple = TRUE)
            french_suits_black <- intToUtf8(utf8ToInt("\U000FCC20") + 0:3, multiple = TRUE)
            french_suits_white <- intToUtf8(utf8ToInt("\U000FCC30") + 0:3, multiple = TRUE)
        }
    }

    ss <- list(piecepack = piecepack_suits,
               playing_cards_expansion = french_suits_black,
               dual_piecepacks_expansion = french_suits_white,
               subpack = piecepack_suits,
               checkers1 = c(rep_len("\u26c2", 5L), "\u26c0", rep_len("\u26c2", 2L)),
               checkers2 = c(rep_len("\u26c2", 5L), "\u26c0", rep_len("\u26c2", 2L)),
               chess1 = "",
               chess2 = "",
               dice = rep_len(" ", 8L),
               dice_fudge =  rep_len(" ", 8L),
               dice_numeral =  rep_len(" ", 8L),
               dominoes = dominoes_ranks,
               dominoes_black = dominoes_ranks,
               dominoes_blue = dominoes_ranks,
               dominoes_green = dominoes_ranks,
               dominoes_red = dominoes_ranks,
               dominoes_white = dominoes_ranks,
               dominoes_yellow = dominoes_ranks,
               icehouse_pieces = c(rep_len("\u25b2", 5L), "\u25b3", rep_len("\u25b2", 2L)),
               alquerque = c(rep_len("\u25cf", 5L), "\u25cb", rep_len("\u25cf", 2L)),
               go = c(rep_len("\u25cf", 5L), "\u25cb", rep_len("\u25cf", 2L)),
               marbles = c(rep_len("\u25cf", 5L), "\u25cb", rep_len("\u25cf", 2L)),
               morris = c(rep_len("\u25cf", 5L), "\u25cb", rep_len("\u25cf", 2L)),
               reversi = c(rep_len("\u26c3", 5L), "\u26c1", rep_len("\u26c3", 2L)))
    ss
}

# We usually use non-solid version of glyph for "white" hence "black" is appropriate
# For dice/dominoe/icehouse pips use "br_black" as an hack for inability to do inverted black/white pips
#### For Game Bit font style use inverted pip feature?
suit_colors <- c("red", "black", "green", "blue", "yellow", "black", "cyan", "magenta")
dice_colors <- suit_colors
dice_colors[2] <- "br_black"

get_style_fg <- function(style) {
    fg <- list(piecepack = suit_colors,
               dual_piecepacks_expansion = suit_colors,
               playing_cards_expansion = suit_colors[c(1L, 2L, 2L, 1L)],
               subpack = suit_colors,
               chess1 = suit_colors,
               chess2 = suit_colors,
               checkers1 = suit_colors,
               checkers2 = suit_colors,
               dice = dice_colors,
               dice_fudge = dice_colors,
               dice_numeral = dice_colors,
               dominoes = rep_len("black", 7L),
               dominoes_black = rep_len(dice_colors[2L], 7L),
               dominoes_blue = rep_len(dice_colors[4L], 7L),
               dominoes_green = rep_len(dice_colors[3L], 7L),
               dominoes_red = rep_len(dice_colors[1L], 7L),
               dominoes_white = rep_len(dice_colors[6L], 7L),
               dominoes_yellow = rep_len(dice_colors[5L], 7L),
               icehouse_pieces = dice_colors,
               alquerque = suit_colors,
               go = suit_colors,
               marbles = suit_colors,
               morris = suit_colors,
               reversi = suit_colors)
    fg
}

color_text <- function(cm, color) {
    if (color == "html") # always colorize if we'll be converting to html
        rlang::local_options(cli.num_colors = 256L)
    if (!isFALSE(color)) {
        for (rr in seq.int(nrow(cm$char))) {
            for (cc in seq.int(ncol(cm$char))) {
                fg <- col_cli(cm$fg[rr, cc])
                colorize <- cli::combine_ansi_styles(fg, cli::bg_br_white)
                cm$char[rr, cc] <- colorize(cm$char[rr, cc])
            }
        }
    }
    cm
}

col_cli <- function(col = c("black", "blue", "cyan", "green", "magenta", "red", "white", "yellow",
                            "grey", "silver", "none",
                            "br_black", "br_blue", "br_cyan", "br_green", "br_red", "br_white", "br_yellow")) {
    col <- match.arg(col)
    get(paste0("col_", col), envir = getNamespace("cli"))
}

annotate_text <- function(cm, nc, nr, xoffset, yoffset, annotate, annotation_scale,
                          xbreaks, ybreaks) {
    if (isFALSE(annotate) || annotate == "none") return(cm)
    step <- 2 * annotation_scale

    if (is.null(xbreaks)) {
        x <- seq(1 + step + 2 * xoffset, nc, by = step)
    } else {
        xbreaks <- as.integer(xbreaks)
        x <- seq(1 + step + 2 * xoffset, by = step, length.out = max(xbreaks))
    }
    if (annotate == "cartesian") {
        x <- utils::head(x, 9)
        xt <- as.character(seq_along(x))
    } else {
        if (length(x) > 26) x <- x[1:26]
        xt <- letters[seq_along(x)]
    }
    if (!is.null(xbreaks)) {
        x <- x[xbreaks]
        xt <- xt[xbreaks]
    }
    cm$char[1, x] <- xt

    if (is.null(ybreaks)) {
        y <- seq(1 + step + 2 * yoffset, nr, by= step)
    } else {
        ybreaks <- as.integer(ybreaks)
        y <- seq(1 + step + 2 * yoffset, by= step, length.out = max(ybreaks))
    }
    yt <- as.character(seq_along(y))
    if (length(yt) > 9) {
        yt <- stringr::str_pad(yt, 2, "right")
        cm$char[y[-seq(9)], 2L] <- substr(yt[-seq(9)], 2, 2)
    }
    if (!is.null(ybreaks)) {
        y <- y[ybreaks]
        yt <- yt[ybreaks]
    }
    cm$char[y, 1L] <- substr(yt, 1L, 1L)
    cm
}

clean_df <- function(df) {
    if (!hasName(df, "cfg")) df$cfg <- "piecepack"
    df$cfg <- ifelse(is.na(df$cfg), "piecepack", df$cfg)
    if (!hasName(df, "rank")) df$rank <- NA_integer_
    df$rank <- ifelse(is.na(df$rank), 1L, df$rank)
    if (!hasName(df, "suit")) df$suit <- NA_integer_
    df$suit <- ifelse(is.na(df$suit), 1L, df$suit)
    if (!hasName(df, "angle")) df$angle <- NA_real_
    df$angle <- ifelse(is.na(df$angle), 0, df$angle %% 360)

    # Adjust board sizes
    # checkers/chess boards rank is number of cells
    df$rank <- ifelse(df$rank == 1L & str_detect(df$piece_side, "^board") & str_detect(df$cfg, "[12]$"),
                      8L,
                      df$rank)
    # go board rank is number of lines
    df$rank <- ifelse(str_detect(df$piece_side, "^board") & df$cfg == "go",
                      ifelse(df$rank == 1L, 18L, df$rank - 1),
                      df$rank)
    # marbles board rank is number of holes
    df$rank <- ifelse(str_detect(df$piece_side, "^board") & df$cfg == "marbles",
                      ifelse(df$rank == 1L, 4L, df$rank),
                      df$rank)
    # alquerque board always has four "cells"
    df$rank <- ifelse(str_detect(df$piece_side, "^board") & df$cfg == "alquerque",
                      4L,
                      df$rank)
    # morris rank is number of men
    df$rank <- ifelse(str_detect(df$piece_side, "^board") & df$cfg == "morris",
                      ifelse(df$rank == 1L, 9L, df$rank),
                      df$rank)

    # Go stones and marbles should be "bit_back"
    bit_back_cfgs <- c("alquerque", "go", "marbles", "morris")
    df$piece_side <- ifelse(df$piece_side == "bit_face" & df$cfg %in% bit_back_cfgs,
                            "bit_back",
                            df$piece_side)
    # reversi
    reversi_flip <- df$cfg == "reversi" & df$piece_side == "bit_back"
    df$piece_side <- ifelse(reversi_flip, "bit_face", df$piece_side)
    df$suit <- ifelse(reversi_flip, c(7L, 6L, 8L, 5L, 4L, 2L, 1L, 3L)[df$suit], df$suit)

    attr(df, "was_cleaned") <- TRUE
    df
}

get_df_offsets <- function(df, lr, xoffset, yoffset, annotate = FALSE) {
    if (!(isFALSE(annotate) || annotate == "none")) {
        xlbound <- ifelse(lr$ymax >= 10, 1.0, 0.5)
        ylbound <- 0.5
    } else {
        xlbound <- 0
        ylbound <- 0
    }
    if (is.null(xoffset)) xoffset <- min2offset(lr$xmin, xlbound)
    if (is.null(yoffset)) yoffset <- min2offset(lr$ymin, ylbound)
    list(x = xoffset, y = yoffset)
}

min2offset <- function(min, lbound = 0.5) {
    if (is.na(min)) {
        NA_real_
    } else if (min < lbound) {
        lbound - min
    } else {
        0
    }
}


add_piece <- function(cm, piece_side, suit, rank, x, y, angle, cfg, reorient = "none", style = get_style()) {
    if (piece_side %in% c("tile_back", "coin_face", "card_back", "board_face", "board_back")) {
        fg <- "black"
    } else {
        if (grepl("pyramid", piece_side)) cfg <- "icehouse_pieces"
        if (piece_side == "tile_face")
            ss <- style$ss_big[[cfg]][suit]
        else
            ss <- style$ss[[cfg]][suit]
        if (piece_side == "pyramid_top") ss <- top_subs[[ss]]
        if (!grepl("matchstick", piece_side))
            ss <- style$rotate(ss, angle, reorient)
        fg <- style$fg[[cfg]][suit]
    }
    if (!(piece_side %in% c("tile_back", "coin_back", "card_back",
                            "pawn_face", "pawn_back", "board_face", "board_back"))) {
        if (piece_side == "tile_face")
            rs <- style$rs_big[[cfg]][rank]
        else
            rs <- style$rs[[cfg]][rank]
        if (grepl("chess", cfg) && suit == 6L) rs <- unicode_chess_white[rank]
        if (grepl("reversi", cfg) && suit == 6L) rs <- "\u26c1"
        if (grepl("checkers", cfg) && suit == 6L) rs <- "\u26c1"
        if (!grepl("matchstick", piece_side)) rs <- style$rotate(rs, angle, reorient)
    }
    if (grepl("2", cfg)) {
        cell <- 2
    } else {
        cell <- 1
    }
    if (cfg == "morris") {
        morris_widths <- c(6, 2, 2, 2, 4, 4, 4, 6, 6, 6, 6, 6)
        board_width <- morris_widths[rank]
        board_height <- morris_widths[rank]
    } else {
        board_width <- cell * rank
        board_height <- cell * rank
    }
    switch(piece_side,
           coin_back = add_coin_back(cm, ss, x, y, angle, fg, style),
           coin_face = add_coin_face(cm, rs, x, y, angle, fg, style),
           die_face = add_die_face(cm, rs, x, y, angle, fg, cfg, style, suit),
           pawn_face = add_pawn_face(cm, ss, x, y, angle, fg, style),
           pawn_back = add_pawn_back(cm, ss, x, y, angle, fg, style),
           tile_face = add_tile_face(cm, ss, rs, x, y, angle, fg, cfg, style),
           tile_back = add_tile_back(cm, x, y, angle, cfg, style),
           bit_back = add_bit_back(cm, ss, x, y, fg),
           bit_face = add_bit_face(cm, rs, x, y, fg),
           board_back = add_board(cm, x, y, board_width, board_height, cell, cfg, style, rank),
           board_face = add_board(cm, x, y, board_height, board_height, cell, cfg, style, rank),
           matchstick_back = add_matchstick_face(cm, x, y, angle, fg, rank),
           matchstick_face = add_matchstick_face(cm, x, y, angle, fg, rank),
           pyramid_top = add_pyramid_top(cm, ss, x, y, angle, fg, rank),
           pyramid_face = add_pyramid_face(cm, ss, x, y, angle, fg, rank),
           pyramid_left = add_pyramid_face(cm, ss, x, y, angle, fg, rank),
           pyramid_right = add_pyramid_face(cm, ss, x, y, angle, fg, rank),
           pyramid_back = add_pyramid_face(cm, ss, x, y, angle, fg, rank),
           { # nolint
               warning("Don't know how to draw ", piece_side)
               cm
           })
}
add_matchstick_face <- function(cm, x, y, angle, fg, rank) {
    switch(rank,
           add_matchstick_face1(cm, x, y, angle, fg),
           add_matchstick_face2(cm, x, y, angle, fg),
           add_matchstick_face3(cm, x, y, angle, fg),
           add_matchstick_face4(cm, x, y, angle, fg),
           add_matchstick_face5(cm, x, y, angle, fg),
           add_matchstick_face6(cm, x, y, angle, fg),
           abort(paste("Don't know how to draw matchstick of rank", rank),
                 class = "unicode_diagram"))
}
abort_angle <- function(angle) {
    abort(paste("Can't handle angle", angle),
          class = "unicode_diagram",
          angle = angle)

}
add_matchstick_face1 <- function(cm, x, y, angle, fg) {
    if (angle %in% c(0, 90, 180, 270)) {
        cm$char[y, x] <- "\u25a0"
    } else if (angle %in% c(45, 135, 225, 315)) {
        cm$char[y, x] <- "\u25c6"
    } else {
        abort_angle(angle)
    }
    cm$fg[y, x] <- fg
    cm
}
add_matchstick_face2 <- function(cm, x, y, angle, fg) {
    if (angle %in% c(0, 180)) {
        cm$char[y, x] <- "\u2503"
    } else if (angle %in% c(90, 270)) {
        cm$char[y, x] <- "\u2501"
    } else if (angle %in% c(45, 225)) {
        cm$char[y, x] <- "\u2572"
    } else if (angle %in% c(135, 315)) {
        cm$char[y, x] <- "\u2571"
    } else {
        abort_angle(angle)
    }
    cm$fg[y, x] <- fg
    cm
}
add_matchstick_face3 <- add_matchstick_face2

add_matchstick_face4 <- function(cm, x, y, angle, fg) {
    if (angle %in% c(0, 180)) {
        cm$char[y+-1:1, x] <- "\u2503"
        cm$fg[y+-1:1, x] <- fg
    } else if (angle %in% c(90, 270)) {
        cm$char[y, x+-1:1] <- "\u2501"
        cm$fg[y, x+-1:1] <- fg
    } else if (angle %in% c(45, 225)) {
        cm$char[y+1, x+-1] <- "\u2572"
        cm$fg[y+1, x+-1] <- fg
        cm$char[y, x] <- "\u2572"
        cm$fg[y, x] <- fg
        cm$char[y-1, x+1] <- "\u2572"
        cm$fg[y-1, x+1] <- fg
    } else if (angle %in% c(135, 315)) {
        cm$char[y+-1, x+-1] <- "\u2571"
        cm$fg[y+-1, x+-1] <- fg
        cm$char[y, x] <- "\u2571"
        cm$fg[y, x] <- fg
        cm$char[y+1, x+1] <- "\u2571"
        cm$fg[y+1, x+1] <- fg
    } else if (angle %in% c(60, 240)) {
        cm$char[y, x] <- "\u2572"
        cm$fg[y, x] <- fg
    } else if (angle %in% c(120, 300)) {
        cm$char[y, x] <- "\u2571"
        cm$fg[y, x] <- fg
    } else {
        abort_angle(angle)
    }
    cm
}
add_matchstick_face5 <- add_matchstick_face4

add_matchstick_face6 <- function(cm, x, y, angle, fg) {
    if (angle %in% c(0, 180)) {
        cm$char[y+-2:2, x] <- "\u2503"
        cm$fg[y+-2:2, x] <- fg
    } else if (angle %in% c(90, 270)) {
        cm$char[y, x+-2:2] <- "\u2501"
        cm$fg[y, x+-2:2] <- fg
    } else if (angle %in% c(45, 225)) {
        cm$char[y+1, x+-1] <- "\u2572"
        cm$fg[y+1, x+-1] <- fg
        cm$char[y, x] <- "\u2572"
        cm$fg[y, x] <- fg
        cm$char[y-1, x+1] <- "\u2572"
        cm$fg[y-1, x+1] <- fg
    } else if (angle %in% c(135, 315)) {
        cm$char[y+-1, x+-1] <- "\u2571"
        cm$fg[y+-1, x+-1] <- fg
        cm$char[y, x] <- "\u2571"
        cm$fg[y, x] <- fg
        cm$char[y+1, x+1] <- "\u2571"
        cm$fg[y+1, x+1] <- fg
    } else {
        abort_angle(angle)
    }
    cm
}
add_bit_face <- function(cm, rs, x, y, fg) {
    cm$char[y, x] <- rs
    cm$fg[y, x] <- fg
    cm
}
add_bit_back <- function(cm, ss, x, y, fg) {
    cm$char[y, x] <- ss
    cm$fg[y, x] <- fg
    cm
}
add_coin_back <- function(cm, ss, x, y, angle, fg, style) {
    enclosing_coin <- style$rotate(style$combining$coin, angle)
    cm$char[y, x] <- paste0(ss, enclosing_coin)
    cm$fg[y, x] <- fg
    cm
}
add_coin_face <- function(cm, rs, x, y, angle, fg, style) {
    enclosing_coin <- style$rotate(style$combining$coin, angle)
    cm$char[y, x] <- paste0(rs, enclosing_coin)
    cm$fg[y, x] <- fg
    cm
}
add_die_face <- function(cm, rs, x, y, angle, fg, cfg, style, suit) {
    enclosing_die <- style$rotate(style$combining$die[[cfg]][suit], angle)
    # nolint start
    # ds <- die_subs[[char]]
    # if (!is.null(ds)) char <- ds
    # nolint end
    char <- paste0(rs, enclosing_die)
    cm$char[y, x] <- char
    cm$fg[y, x] <- fg
    cm
}
add_pawn_face <- function(cm, ss, x, y, angle, fg, style) {
    enclosing_pawn <- style$rotate(style$combining$pawn, angle)
    cm$char[y, x] <- paste0(ss, enclosing_pawn)
    cm$fg[y, x] <- fg
    cm
}
add_pawn_back <- function(cm, ss, x, y, angle, fg, style) {
    enclosing_pawn <- style$rotate(style$combining$pawn, angle)
    cm$char[y, x] <- paste0(ss, enclosing_pawn)
    cm$fg[y, x] <- fg
    cm
}
add_pyramid_face <- function(cm, ss, x, y, angle, fg, rank = 1) {
    # nolint start
    # if (angle %% 90 == 0) {
    #     cm$char[y, x] <- paste0(ss, "\u20de")
    # } else {
    #     cm$char[y, x] <- paste0(ss, "\u20df")
    # }
    # nolint end
    cm$char[y, x] <- paste0(ss, get_dots(rank))
    cm$fg[y, x] <- fg
    cm
}
# top dots U+0307 U+0308 U+20db U+20dc
# bottom dots U+0323 U+0324 U+20ef
get_dots <- function(rank) {
    switch(rank, "\u0323", "\u0324", "\u20e8", "\u0324\u0308", "\u20e8\u0308", "\u20e8\u20db",
           abort(paste("Doesn't support", rank, "dots")), class = "unicode_diagram")
}
add_pyramid_top <- function(cm, ss, x, y, angle, fg, rank = 1) {
    # nolint start
    # if (angle %% 90 == 0) {
    #     cm$char[y, x] <- paste0(ss, "\u20de")
    # } else {
    #     cm$char[y, x] <- paste0(ss, "\u20df")
    # }
    # nolint end
    cm$char[y, x] <- paste0(ss, get_dots(rank))
    cm$fg[y, x] <- fg
    cm
}
add_tile_back <- function(cm, x, y, angle, cfg, style) {
    if (angle %% 90 != 0) abort_angle(angle)

    if (cfg == "subpack") {
        add_tile_back_subpack(cm, x, y, style)
    } else if (grepl("dominoes", cfg)) {
        add_tile_back_dominoes(cm, x, y, angle, style)
    } else {
        add_tile_back_piecepack(cm, x, y, style)
    }
}
add_tile_back_dominoes <- function(cm, x, y, angle, style) {
    if (angle %% 180 == 0) { # vertical
        cm$fg[y+-2:2, x+-1:1] <- "black"
        cm <- add_border(cm, x, y, width = 1, height = 2, space = style$space)
        cm
    } else if (angle %% 90 == 0) { # horizontal
        cm$fg[y+-1:1, x+-2:2] <- "black"
        cm <- add_border(cm, x, y, width = 2, height = 1, space = style$space)
        cm
    }
}
add_tile_back_piecepack <- function(cm, x, y, style) {
    cm$fg[y+-2:2, x+-2:2] <- "black"
    cm <- add_border(cm, x, y, space = style$space)
    cm <- add_gridlines(cm, x, y, has_pua_box_drawing = style$has_pua_box_drawing)
    cm
}
add_tile_back_subpack <- function(cm, x, y, style) {
    cm$fg[y+-1:1, x+-1:1] <- "black"
    cm <- add_border(cm, x, y, 1, 1, space = style$space)
    cm <- add_gridlines(cm, x, y, 1, 1, 0.5,
                        has_pua_box_drawing = style$has_pua_box_drawing)
    cm
}
add_tile_face <- function(cm, ss, rs, x, y, angle, fg, cfg, style) {
    if (angle %% 90 != 0) abort_angle(angle)

    if (cfg == "subpack") {
        add_tile_face_subpack(cm, rs, x, y, fg, style)
    } else if (grepl("dominoes", cfg)) {
        add_tile_face_dominoes(cm, ss, rs, x, y, angle, fg, style)
    } else {
        add_tile_face_piecepack(cm, ss, rs, x, y, angle, fg, style)
    }
}
add_tile_face_subpack <- function(cm, rs, x, y, fg, style) {
    cm$fg[y+-1:1, x+-1:1] <- "black"
    cm <- add_border(cm, x, y, 1, 1, space = style$space)
    cm$char[y, x] <- rs
    cm$fg[y, x] <- fg
    cm
}
add_tile_face_dominoes <- function(cm, ss, rs, x, y, angle, fg, style) {
    if (angle == 0) {
        cm$fg[y+-2:2, x+-1:1] <- "black"
        cm <- add_border(cm, x, y, width = 1, height = 2, space = style$space)
        cm$char[y+-1:1, x] <-  c(ss, "\u2501", rs)
        cm$fg[y+-1:1, x] <- fg
    } else if (angle == 90) {
        cm$fg[y+-1:1, x+-2:2] <- "black"
        cm <- add_border(cm, x, y, width = 2, height = 1, space = style$space)
        cm$char[y, x+-1:1] <-  c(rs, "\u2503", ss)
        cm$fg[y, x+-1:1] <- fg
    }
    if (angle == 180) {
        cm$fg[y+-2:2, x+-1:1] <- "black"
        cm <- add_border(cm, x, y, width = 1, height = 2, space = style$space)
        cm$char[y+-1:1, x] <-  c(rs, "\u2501", ss)
        cm$fg[y+-1:1, x] <- fg
    } else if (angle == 270) {
        cm$fg[y+-1:1, x+-2:2] <- "black"
        cm <- add_border(cm, x, y, width = 2, height = 1, space = style$space)
        cm$char[y, x+-1:1] <-  c(ss, "\u2503", rs)
        cm$fg[y, x+-1:1] <- fg
    }
    cm
}
add_tile_face_piecepack <- function(cm, ss, rs, x, y, angle, fg, style) {
    cm$fg[y+-2:2, x+-2:2] <- "black"
    cm <- add_border(cm, x, y, space = style$space)
    # rank symbol
    cm$char[y, x] <- rs
    cm$fg[y, x] <- fg
    # suit symbol
    if (angle == 0) {
        cm$char[y+1, x-1] <- ss
        cm$fg[y+1, x-1] <- fg
    } else if (angle == 90) {
        cm$char[y-1, x-1] <- ss
        cm$fg[y-1, x-1] <- fg
    } else if (angle == 180) {
        cm$char[y-1, x+1] <- ss
        cm$fg[y-1, x+1] <- fg
    } else if (angle == 270) {
        cm$char[y+1, x+1] <- ss
        cm$fg[y+1, x+1] <- fg
    }
    cm
}

add_board <- function(cm, x, y, width = 8, height = 8, cell = 1,
                      cfg = "checkers1",
                      style = get_style("Unicode"),
                      rank = 8L) {
    cm$fg[y+-height:height, x+-width:width] <- "black"
    if (cfg != "morris")
        cm <- add_border(cm, x, y, width, height, space = style$space)
    cm <- switch(cfg,
                 alquerque = add_alquerque_board(cm, x, y, width, height, cell),
                 marbles = add_holes(cm, x, y, width, height, cell),
                 morris = add_morris_board(cm, x, y, width, height, cell, style, rank),
                 add_gridlines(cm, x, y, width, height, cell)
                 )
    cm
}

add_morris_board <- function(cm, x, y, width = 2, height = 2, cell = 1,
                             style = get_style("Unicode"), rank = 9L) {
    hv <- 1L # light
    if (rank == 2L) { # three men's morris without diagonals
        cm <- add_border(cm, x, y, width, height, space = style$space)
        cm <- add_gridlines(cm, x, y, width, height, cell = 1, heavy = FALSE)
    } else if (rank < 5L) { # three men's morris
        cm <- add_border(cm, x, y, width, height, space = style$space)
        cm <- add_alquerque_board(cm, x, y, width, height, cell)
    } else if (rank < 7L) { # six men's morris
        cm <- add_border(cm, x, y, width, height, space = style$space)
        cm <- add_border(cm, x, y, 2L, 2L, space = style$space)
        cm$char[y, x + c(-3, 3)] <- "\u2500" # light horizontal line
        cm$char[y + c(-3, 3), x] <- "\u2502" # light vertical line
        # intersection gridlines and border line
        cm <- add_box_edge(cm, x-width, y, c(1L, hv, 1L, NA)) # left
        cm <- add_box_edge(cm, x+2, y, c(1L, hv, 1L, NA)) # left
        cm <- add_box_edge(cm, x+width, y, c(1L, NA, 1L, hv)) # right
        cm <- add_box_edge(cm, x-2, y, c(1L, NA, 1L, hv)) # right
        cm <- add_box_edge(cm, x, y+height, c(NA, 1L, hv, 1L)) # top
        cm <- add_box_edge(cm, x, y-2, c(NA, 1L, hv, 1L)) # top
        cm <- add_box_edge(cm, x, y-height, c(hv, 1L, NA, 1L)) # bottom
        cm <- add_box_edge(cm, x, y+2, c(hv, 1L, NA, 1L)) # bottom
    } else if (rank == 7L) { # seven men's morris
        cm <- add_border(cm, x, y, width, height, space = style$space)
        cm <- add_border(cm, x, y, 2L, 2L, space = style$space)
        cm <- add_gridlines(cm, x, y, width, height, cell = 2, heavy = FALSE)
        cm$char[y, x + c(-2L, 2L)] <- "\u253c" # light crosses
        cm$char[y + c(-2L, 2L), x] <- "\u253c" # light crosses
    } else { # 9 men's morris
        cm <- add_border(cm, x, y, width, height, space = style$space)
        cm <- add_border(cm, x, y, 4L, 4L, space = style$space)
        cm <- add_border(cm, x, y, 2L, 2L, space = style$space)
        cm$char[y, x + c(-5, -3, 3, 5)] <- "\u2500" # light horizontal line
        cm$char[y + c(-5, -3, 3, 5), x] <- "\u2502" # light vertical line
        cm$char[y, x + c(-4L, 4L)] <- "\u253c" # light crosses
        cm$char[y + c(-4L, 4L), x] <- "\u253c" # light crosses
        cm <- add_box_edge(cm, x-width, y, c(1L, hv, 1L, NA)) # left
        cm <- add_box_edge(cm, x+2, y, c(1L, hv, 1L, NA)) # left
        cm <- add_box_edge(cm, x+width, y, c(1L, NA, 1L, hv)) # right
        cm <- add_box_edge(cm, x-2, y, c(1L, NA, 1L, hv)) # right
        cm <- add_box_edge(cm, x, y+height, c(NA, 1L, hv, 1L)) # top
        cm <- add_box_edge(cm, x, y-2, c(NA, 1L, hv, 1L)) # top
        cm <- add_box_edge(cm, x, y-height, c(hv, 1L, NA, 1L)) # bottom
        cm <- add_box_edge(cm, x, y+2, c(hv, 1L, NA, 1L)) # bottom
        if (rank > 10L) { # 12 men's morris
            cm$char[x - 5, y - 5] <- "\u2571" # up to right diagonal
            cm$char[x - 3, y - 3] <- "\u2571" # up to right diagonal
            cm$char[x + 3, y + 3] <- "\u2571" # up to right diagonal
            cm$char[x + 5, y + 5] <- "\u2571" # up to right diagonal
            cm$char[x + 5, y - 5] <- "\u2572" # up to left diagonal
            cm$char[x + 3, y - 3] <- "\u2572" # up to left diagonal
            cm$char[x - 3, y + 3] <- "\u2572" # up to left diagonal
            cm$char[x - 5, y + 5] <- "\u2572" # up to left diagonal

        }
    }
    cm
}

add_alquerque_board <- function(cm, x, y, width = 4, height = 4, cell = 1) {
    stopifnot(width %% 2 == 0, height %% 2 == 0)
    cm <- add_gridlines(cm, x, y, width, height, cell, heavy = FALSE)
    xl <- x - width
    xr <- x + width
    yb <- y - height
    yt <- y + height
    xur <- rep(seq.int(xl + 1L, xr - 1L, by = 4L), height / 2)
    yur <- rep(seq.int(yb + 1L, yt - 1L, by = 4L), each = 2L)
    cm$char[xur, yur] <- "\u2571"
    xur <- rep(seq.int(xl + 3L, xr - 1L, by = 4L), height / 2)
    yur <- rep(seq.int(yb + 3L, yt - 1L, by = 4L), each = 2L)
    cm$char[xur, yur] <- "\u2571"
    xul <- rep(seq.int(xl + 1L, xr - 1L, by = 4L), height / 2)
    yul <- rep(seq.int(yb + 3L, yt - 1L, by = 4L), each = 2L)
    cm$char[xul, yul] <- "\u2572"
    xul <- rep(seq.int(xl + 3L, xr - 1L, by = 4L), height / 2)
    yul <- rep(seq.int(yb + 1L, yt - 1L, by = 4L), each = 2L)
    cm$char[xul, yul] <- "\u2572"
    cm
}

add_holes <- function(cm, x, y, width = 2, height = 2, cell = 1) {
    xgs <- x + seq(cell - width,  width - cell,  2 * cell)
    ygs <- y + seq(cell - height, height - cell, 2 * cell)
    # cm$char[ygs, xgs] <- "\u25ce"
    cm$char[ygs, xgs] <- "\u25cc"
    cm
}

add_gridlines <- function(cm, x, y, width = 2, height = 2, cell = 1,
                          has_pua_box_drawing = FALSE, heavy = TRUE) {
    # gridlines
    xgs <- x + seq(2 * cell - width, width - 2 * cell, 2 * cell)
    ygs <- y + seq(2 * cell - height, height - 2 * cell, 2 * cell)
    xo <- x + seq(1 - width, width - 1)
    yo <- y + seq(1 - height, height - 1)

    if (heavy) {
        cm$char[ygs, xo] <- "\u2501" # horizontal lines
        cm$char[yo, xgs] <- "\u2503" # vertical lines
        cm$char[ygs, xgs] <- "\u254b" # crosses
        hv <- ifelse(has_pua_box_drawing, 3L, 2L)
    } else { # "light"
        cm$char[ygs, xo] <- "\u2500" # horizontal lines
        cm$char[yo, xgs] <- "\u2502" # vertical lines
        cm$char[ygs, xgs] <- "\u253c" # crosses
        hv <- 1L
    }

    # intersection gridlines and border line
    for (xg in xgs) {
        cm <- add_box_edge(cm, xg, y+height, c(NA, 1L, hv, 1L)) # top
        cm <- add_box_edge(cm, xg, y-height, c(hv, 1L, NA, 1L)) # bottom
    }
    for (yg in ygs) {
        cm <- add_box_edge(cm, x+width, yg, c(1L, NA, 1L, hv)) # right
        cm <- add_box_edge(cm, x-width, yg, c(1L, hv, 1L, NA)) # left
    }
    cm
}

add_border <- function(cm, x, y, width = 2, height = 2, space = " ") {
    for (i in seq(1 - height, height - 1)) {
        for (j in seq(1 - width, width - 1)) {
            cm$char[y + i, x + j] <- space
        }
    }
    for (i in seq(1 - width, width - 1)) {
        cm <- add_box_edge(cm, x+i, y+height, c(NA, 1, 0, 1)) # top side
        cm <- add_box_edge(cm, x+i, y-height, c(0, 1, NA, 1)) # bottom side
    }
    for (j in seq(1 - height, height - 1)) {
        cm <- add_box_edge(cm, x+width, y+j, c(1, NA, 1, 0)) # right side
        cm <- add_box_edge(cm, x-width, y+j, c(1, 0, 1, NA)) # left side
    }
    cm <- add_box_edge(cm, x-width, y+height, c(NA, 1, 1, NA)) # ul corner
    cm <- add_box_edge(cm, x+width, y+height, c(NA, NA, 1, 1)) # ur corner
    cm <- add_box_edge(cm, x-width, y-height, c(1, 1, NA, NA)) # ll corner
    cm <- add_box_edge(cm, x+width, y-height, c(1, NA, NA, 1)) # lr corner
    cm
}

add_box_edge <- function(cm, x, y, box_info) {
    # [top, right, bottom, left] 0-none 1-light 2-heavy 3-matted-heavy
    bi <- char2bi[[cm$char[y, x]]]
    if (is.null(bi)) bi <- c(0, 0, 0, 0)
    ind <- which(!is.na(box_info))
    for (ii in ind) {
        bi[ii] <- box_info[ii]
    }
    cm$char[y, x] <- box2char[[paste(bi, collapse = "")]]
    cm
}

get_style_rotate <- function(style = "unicode") {
    rl <- list(r45 = r45, r90 = r90, r135 = r135,
               r180 = r180, r225 = r225, r270 = r270, r315 = r315)

    if (style == "gamebitmono") {
        r90[["\u283f"]] <- "\u3000\u20db\u20e8"
        r270[["\u283f"]] <- "\u3000\u20db\u20e8"
    }

    function(char, angle, reorient = "none") {
        if (angle == 0 || reorient == "symbols") {
            rchar <- char
        } else if (angle == 45) {
            rchar <- rl$r45[[char]]
        } else if (angle == 90) {
            rchar <- rl$r90[[char]]
        } else if (angle == 135) {
            rchar <- rl$r135[[char]]
        } else if (angle == 180) {
            rchar <- rl$r180[[char]]
        } else if (angle == 225) {
            rchar <- rl$r225[[char]]
        } else if (angle == 270) {
            rchar <- rl$r270[[char]]
        } else if (angle == 315) {
            rchar <- rl$r315[[char]]
        } else {
            rchar <- NULL
        }
        if (is.null(rchar)) {
            warning(paste("Can't rotate", char, angle, "degrees"))
            char
        } else {
            rchar
        }
    }
}
