#' Is a vector empty
#'
#' @description
#'
#' `r lifecycle::badge("defunct")`
#'
#' This function is defunct, please use [vec_is_empty()].
#'
#' @param x An object.
#'
#' @keywords internal
#' @export
vec_empty <- function(x) {
  stop_defunct(paste_line(
    "`vec_empty()` is defunct as of vctrs 0.2.0.",
    "Please use `vec_is_empty()` instead."
  ))
}

#' Deprecated type functions
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' These functions have been renamed:
#'
#' * `vec_type()` => [vec_ptype()]
#' * `vec_type2()` => [vec_ptype2()]
#' * `vec_type_common()` => [vec_ptype_common()]
#'
#' @param x,y,...,.ptype Arguments for deprecated functions.
#'
#' @keywords internal
#' @export
vec_type <- function(x) {
  warn_deprecated(c("`vec_type()` has been renamed to `vec_ptype()`."))
  vec_ptype(x)
}
#' @rdname vec_type
#' @export
vec_type_common <- function(..., .ptype = NULL) {
  warn_deprecated(c("`vec_type_common()` has been renamed to `vec_ptype_common()`."))
  vec_ptype_common(..., .ptype = .ptype)
}
#' @rdname vec_type
#' @export
vec_type2 <- function(x, y, ...) {
  warn_deprecated(c("`vec_type2()` has been renamed to `vec_ptype2()`."))
  vec_ptype2(x, y, ...)
}

#' Convert to an index vector
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' `vec_as_index()` has been renamed to [vec_as_location()] and is
#' deprecated as of vctrs 0.2.2.
#'
#' @inheritParams vec_as_location
#'
#' @keywords internal
#' @export
vec_as_index <- function(i, n, names = NULL) {
  signal_soft_deprecated(paste_line(
    "`vec_as_index()` is deprecated as of vctrs 0.2.2.",
    "Please use `vec_as_location() instead.`"
  ))
  n <- vec_cast(n, integer())
  vec_assert(n, integer(), 1L)
  i <- vec_as_subscript(i)

  .Call(
    vctrs_as_location,
    i = i,
    n = n,
    names = names,
    loc_negative = "invert",
    loc_oob = "error",
    loc_zero = "remove",
    missing = "propagate",
    arg = NULL
  )
}

#' Expand the length of a vector
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `vec_repeat()` has been replaced with [vec_rep()] and [vec_rep_each()] and is
#' deprecated as of vctrs 0.3.0.
#'
#' @param x A vector.
#' @param each Number of times to repeat each element of `x`.
#' @param times Number of times to repeat the whole vector of `x`.
#' @return A vector the same type as `x` with size `vec_size(x) * times * each`.
#' @keywords internal
#' @export
vec_repeat <- function(x, each = 1L, times = 1L) {
  signal_soft_deprecated(paste_line(
    "`vec_repeat()` is deprecated as of vctrs 0.3.0.",
    "Please use either `vec_rep()` or `vec_rep_each()` instead."
  ))

  vec_assert(each, size = 1L)
  vec_assert(times, size = 1L)

  idx <- rep(vec_seq_along(x), times = times, each = each)
  vec_slice(x, idx)
}
