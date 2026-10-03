# Small internal helpers (prototype). The shared single-case machinery
# (rbind_fill, first_last, open_png, nap, phase plot) now lives in PhysioAppKit.

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a
