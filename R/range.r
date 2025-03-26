range_heuristic <- function(df) {
    if (nrow(df) == 0) return(list(xmin = NA_real_, xmax = NA_real_, ymin = NA_real_, ymax = NA_real_))
    if (!isTRUE(attr(df, "was_cleaned"))) df <- clean_df(df)

    # piecepack
    is_tile <- grepl("tile", df$piece_side)
    xleft  <- ifelse(is_tile, df$x-1, df$x-0.5)
    xright <- ifelse(is_tile, df$x+1, df$x+0.5)
    ybot   <- ifelse(is_tile, df$y-1, df$y-0.5)
    ytop   <- ifelse(is_tile, df$y+1, df$y+0.5)

    # subpack
    is_subpack <- is_tile & df$cfg == "subpack"
    xleft  <- ifelse(is_subpack, df$x-0.5, xleft)
    xright <- ifelse(is_subpack, df$x+0.5, xright)
    ybot   <- ifelse(is_subpack, df$y-0.5, ybot)
    ytop   <- ifelse(is_subpack, df$y+0.5, ytop)

    # dominoes
    is_dominoes_horizontal <- is_tile & grepl("dominoes", df$cfg) & (df$angle == 90 | df$angle == 270)
    ybot   <- ifelse(is_dominoes_horizontal, df$y-0.5, ybot)
    ytop   <- ifelse(is_dominoes_horizontal, df$y+0.5, ytop)
    is_dominoes_vertical <- is_tile & grepl("dominoes", df$cfg) & (df$angle == 0 | df$angle == 180)
    xleft  <- ifelse(is_dominoes_vertical, df$x-0.5, xleft)
    xright <- ifelse(is_dominoes_vertical, df$x+0.5, xright)

    # boards
    is_board <- grepl("board", df$piece_side)
    xleft  <- ifelse(is_board, df$x-0.5*df$rank, xleft)
    xright <- ifelse(is_board, df$x+0.5*df$rank, xright)
    ybot   <- ifelse(is_board, df$y-0.5*df$rank, ybot)
    ytop   <- ifelse(is_board, df$y+0.5*df$rank, ytop)

    is_board2 <- is_board & grepl("2", df$cfg)
    xleft  <- ifelse(is_board2, df$x-df$rank, xleft)
    xright <- ifelse(is_board2, df$x+df$rank, xright)
    ybot   <- ifelse(is_board2, df$y-df$rank, ybot)
    ytop   <- ifelse(is_board2, df$y+df$rank, ytop)

    morris_offset <- c(3, 1, 1, 1, 2, 2, 3, 3, 3, 3, 3, 3)[df$rank]
    is_morris_board <- is_board & df$cfg == "morris"
    xleft  <- ifelse(is_morris_board, df$x-morris_offset, xleft)
    xright <- ifelse(is_morris_board, df$x+morris_offset, xright)
    ybot   <- ifelse(is_morris_board, df$y-morris_offset, ybot)
    ytop   <- ifelse(is_morris_board, df$y+morris_offset, ytop)

    # matchsticks
    m_offset <- pmax(floor(df$rank / 2) - 1, 0) / 2 # 1:6 -> 0, 0, 0, 0.5, 0.5, 1
    is_matchsticks_horizontal <- grepl("matchstick", df$piece_side) &
        (df$angle == 90 | df$angle == 270)
    xleft  <- ifelse(is_matchsticks_horizontal, df$x - m_offset, xleft)
    xright <- ifelse(is_matchsticks_horizontal, df$x + m_offset, xright)

    is_matchsticks_vertical <- grepl("matchstick", df$piece_side) &
        (df$angle == 0 | df$angle == 180)
    ybot <- ifelse(is_matchsticks_vertical, df$y - m_offset, ybot)
    ytop <- ifelse(is_matchsticks_vertical, df$y + m_offset, ytop)

    m_offset_d <- floor(df$rank / 4) # 1:6 -> 0, 0, 0, 1, 1, 1
    is_matchsticks_diagonal <- grepl("matchstick", df$piece_side) &
        !is_matchsticks_horizontal & !is_matchsticks_vertical
    xleft  <- ifelse(is_matchsticks_diagonal, df$x - m_offset_d, xleft)
    xright <- ifelse(is_matchsticks_diagonal, df$x + m_offset_d, xright)
    ybot   <- ifelse(is_matchsticks_diagonal, df$y - m_offset_d, ybot)
    ytop   <- ifelse(is_matchsticks_diagonal, df$y + m_offset_d, ytop)

    list(xmin = min(xleft), xmax = max(xright), ymin = min(ybot), ymax = max(ytop))
}
